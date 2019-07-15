% Load the subject data for EEG responses to various times of sounds, 
% and save the average evoked response (ERP) for each of the sounds
% (NZ, 15-7-2019)
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

erp = squeeze(mean(eegs,3,'omitnan'));

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
respth = '/Volumes/ZStore/SpeechMusicClassify/erps_exp2/';
resfl = sprintf('StimClassERP_%s',sbj);
save([respth resfl],'erp','tm');