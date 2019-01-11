% Load the subject data for EEG responses to various times of sounds, 
% and create a classifier to classify each of the different
% types of sounds
% (NZ, 4/12/2018)
addpath('~/Projects/Speech_Music_Classify/');

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/'; % contains eeg data
stimpth = '/Volumes/Untitled/SpeechMusicClassify/stims/'; % contains labeling for the sound clips and the stimuli
sbj = 'WWDVDF'; % subject name
vexpthres = 95;
eFs = 128;
% maxdur = 1; % maximum duration (in s)

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

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
rshpeeg = reshape(eegs,[ntm*nchan ntr*nstims]);
lbl = repelem(1:nstims,ntr);
scrmblbls;
% lbl = repelem(typelbl,ntr);
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
respth = '/Volumes/ZStore/SpeechMusicClassify/';
resfl = sprintf('StimClassLDA_%s',sbj);
save([respth resfl],'conf','sc','maxpc','mu','lbl','vexpthres','cf');