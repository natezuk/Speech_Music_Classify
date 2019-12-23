% Load the subject data for EEG responses to various times of sounds (ET
% experiment), and compute the evoked response for each sound
% (NZ, 15-7-2019)

addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

eegpth = '/Volumes/Untitled/NaturalSounds_ExpI/eegs/'; % contains Teoh's eeg data
sbj = 'SN'; % subject name
vexpthres = 95;
eFs = 128;
% maxdur = 1; % maximum duration (in s)

disp('Loading eeg data...');
[eegs,stims] = loadnewnatclassdata(eegpth,sbj);

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
rshpeeg = reshape(eegs,[ntm*nchan ntr*nstims]);
lbl = repelem(1:nstims,ntr);
stimtypelbl;
% lbl = repelem(typelbl,ntr);
types = unique(typelbl);

% Compute the ERP
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
respth = '/Volumes/ZStore/NaturalSounds/SbjResults/erps_exp1/';
resfl = sprintf('StimClassERP_%s',sbj);
save([respth resfl],'erp','tm');