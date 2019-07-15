% Load the subject data for EEG responses to various times of sounds, 
% and create a classifier to classify each of the different
% types of sounds. Use only the first 1 s of the response.
% (NZ, 4/12/2018)
addpath('~/Projects/Speech_Music_Classify/');
addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/'; % contains eeg data
stimpth = '/Volumes/Untitled/SpeechMusicClassify/stims/'; % contains labeling for the sound clips and the stimuli
sbj = 'ZLIDEI'; % subject name
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

% Use only the first second of the response
disp('Retaining only the first second...');
eegs = eegs(1:eFs,:,:,:);

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
colormap('gray');
imagesc(mconf(idx,idx)');
colorbar
set(gca,'XTick',1:30,'XTickLabel',stims(idx),'YTick',1:30,'YTickLabel',stims(idx),...
    'TickLabelInterpreter','none','XTickLabelRotation',90.0);
title(sbj,'Interpreter','none');
xlabel('Actual');
ylabel('Predicted');

% Plot the average EEG in response to the sounds
EEG = mean(mean(eegs,4,'omitnan'),3,'omitnan');
tm = (0:size(EEG,1)-1)/eFs;
figure
imagesc(tm,1:128,EEG');
set(gca,'FontSize',16);
xlabel('Time (s)');
ylabel('Channel');

% plot the topo of the response around 200 ms
tm_idx = tm>0.2&tm<=0.3;
figure
topoplot(mean(EEG(tm_idx,:),1),'~/Projects/EEGanly/chanlocs.xyz');
set(gca,'FontSize',16);
title('200 - 300 ms');

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/SpeechMusicClassify/1sdur/';
resfl = sprintf('StimClassLDA_%s',sbj);
save([respth resfl],'conf','sc','maxpc','mu','lbl','vexpthres','cf');