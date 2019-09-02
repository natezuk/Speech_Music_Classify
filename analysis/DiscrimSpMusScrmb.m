% Load the subject data for EEG responses to various times of sounds, 
% and create a classifier to discriminate between speech and music sounds
% (not model-matched versions)
% (NZ, 19-7-2018)
addpath('~/Projects/Speech_Music_Classify/');

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/'; % contains eeg data
stimpth = '/Volumes/Untitled/SpeechMusicClassify/stims/'; % contains labeling for the sound clips and the stimuli
sbj = 'ZLIDEI'; % subject name
vexpthres = 95;
eFs = 128;
stim_sets = {'Music','Speech'}; % stimulus groups to classify
stim_lbl = [1 2];

disp('Loading eeg data...');
[eegs,stims] = loadscrmbclassdata(eegpth,sbj,stimpth);

% Remove target clips
ComputeTwoBack;
for ii = 1:length(stims),
    targettrials = tag_cliprep(ii,:); % find trials where this clip was the target
    rmvidx = false(size(eegs,3),1);
    rmvidx(find(targettrials)*2) = true; % set the target in those trials to true (to remove them)
    eegs(:,:,rmvidx,ii) = NaN;
    fprintf('Removed %d EEG epochs from clip %s\n',sum(rmvidx),stims{ii});
end

scrmblbls;
types = unique(typelbl);

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
% [conf,cf,sc,maxpc,mu] = spmusdiscrimlda(rshpeeg,lbl,stim_tag,'vexpthres',vexpthres);
[conf,cf,sc,maxpc,mu,ntst] = spmusdiscrimlda(rshpeeg,lbl,stim_tag,'vexpthres',vexpthres);

% Sort the stimulus types
% [srttype,idx] = sort(lbl(:,1));

mconf = mean(conf,3); % average confusion matrix across iterations
figure
colormap('gray');
imagesc(mconf');
colorbar
set(gca,'XTick',1:2,'XTickLabel',stim_sets,'YTick',1:2,'YTickLabel',stim_sets,...
    'TickLabelInterpreter','none','XTickLabelRotation',90.0);
title(sbj,'Interpreter','none');
xlabel('Actual');
ylabel('Predicted');

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/SpeechMusicClassify/spmusdiscrim_expII/';
resfl = sprintf('SpMusDiscrim_%s',sbj);
save([respth resfl],'conf','maxpc','mu','lbl','vexpthres','cf','ntst');