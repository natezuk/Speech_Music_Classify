% Load the subject data for EEG responses to various times of sounds (ET
% experiment), and create a classifier to discriminate speech and music
% (NZ, 4/12/2018)

eegpth = '/Volumes/Untitled/TeohSpMus/Preprocessed/'; % contains Teoh's eeg data
sbj = 'SN_1_45'; % subject name
vexpthres = 95;
eFs = 128;
% maxdur = 1; % maximum duration (in s)
stim_sets = {'Music','Speech'}; % stimulus groups to classify
stim_lbl = [3 6];

stimtypelbl;
types = unique(typelbl);

disp('Loading eeg data...');
[eegs,stims] = loadstimclassdata(eegpth,sbj);

% Remove trials that are not speech or music
eegs = eegs(:,:,:,typelbl==stim_lbl(1)|typelbl==stim_lbl(2)); % 1=music, 2=speech
use_lbl = typelbl(typelbl==stim_lbl(1)|typelbl==stim_lbl(2));
use_stims = find(typelbl==stim_lbl(1)|typelbl==stim_lbl(2));

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
lbl = repelem(use_lbl',ntr);
stim_tag = repelem(use_stims',ntr);
rshpeeg = reshape(eegs,[ntm*nchan ntr*nstims]);

% Do multi-class LDA
[conf,cf,~,maxpc,mu,ntst] = spmusdiscrimlda(rshpeeg,lbl,stim_tag,'vexpthres',vexpthres);

mconf = mean(conf,3); % average confusion matrix across iterations
cmap = colormap('gray');
figure
imagesc(mconf');
colormap(flipud(cmap));
colorbar
set(gca,'XTick',1:2,'XTickLabel',stim_sets,'YTick',1:2,'YTickLabel',stim_sets,...
    'TickLabelInterpreter','none','XTickLabelRotation',90.0);
title(sbj,'Interpreter','none');
xlabel('Actual');
ylabel('Predicted');

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/TeohStimClass/SbjResults/spmusdiscrim_expI/';
resfl = sprintf('SpMusDiscrim_%s',sbj);
save([respth resfl],'conf','maxpc','mu','lbl','vexpthres','ntst');