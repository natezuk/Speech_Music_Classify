% Load the subject data for EEG responses to various times of sounds (ET
% experiment), and create a classifier to classify each of the different
% types of sounds
% (NZ, 4/12/2018)

eegpth = '/Volumes/Untitled/NaturalSounds_ExpI/eegs/'; % contains Teoh's eeg data
sbj = 'SN'; % subject name
vexpthres = 95;
eFs = 128;
maxdur = 1; % maximum duration (in s)

disp('Loading eeg data...');
[eegs,stims] = loadnewnatclassdata(eegpth,sbj);
% Reduce the eeg duration
eegs = eegs(1:maxdur*eFs,:,:,:);

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
rshpeeg = reshape(eegs,[ntm*nchan ntr*nstims]);
lbl = repelem(1:nstims,ntr);
stimtypelbl;
types = unique(typelbl);

% Do multi-class LDA
[conf,cf,sc,maxpc,mu] = stimclasslda(rshpeeg,lbl,'vexpthres',vexpthres);

% Sort the stimulus types
[srttype,idx] = sort(typelbl);

mconf = mean(conf,3); % average confusion matrix across iterations
figure
imagesc(mconf(idx,idx)');
colorbar
set(gca,'XTick',1:30,'XTickLabel',stims(idx),'YTick',1:30,'YTickLabel',stims(idx),...
    'TickLabelInterpreter','none','XTickLabelRotation',90.0);
title(sbj,'Interpreter','none');
xlabel('Actual');
ylabel('Predicted');

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/NaturalSounds/SbjResults/1sdur/';
resfl = sprintf('StimClassLDA_%s',sbj);
save([respth resfl],'conf','sc','maxpc','mu','lbl','vexpthres');