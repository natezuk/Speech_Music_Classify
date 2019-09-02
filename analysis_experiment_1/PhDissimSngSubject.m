% Load the subject data for EEG responses to various times of sounds (ET
% experiment), and compute the phase dissimilarity for each sound
% (NZ, 5-8-2019)

addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

eegpth = '/Volumes/Untitled/TeohSpMus/Preprocessed/'; % contains Teoh's eeg data
sbj = 'SN_1_45'; % subject name
eFs = 128;

disp('Loading eeg data...');
[eegs,stims] = loadstimclassdata(eegpth,sbj);

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
lbl = repelem(1:nstims,ntr);
stimtypelbl;
types = unique(typelbl);

% Compute the phase dissimilarity
freq_edges = 0:4:40; % edges between frequency bins, in Hz
% average eeg across channels
avgeeg = squeeze(mean(eegs,2,'omitnan'));
[~,~,phdis] = phaseDissimilarity(avgeeg,eFs,'freq_edges',freq_edges);

% Plot the phase dissimilarity as a function of frequency
figure
cnts = freq_edges(1:end-1)+diff(freq_edges);
plot(cnts,phdis,'k.','MarkerSize',16);
set(gca,'FontSize',16);
xlabel('Frequency (Hz)');
ylabel('Phase dissimilarity');

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/TeohStimClass/SbjResults/phdis_exp1/';
resfl = sprintf('StimClassPhDis_%s',sbj);
save([respth resfl],'phdis','freq_edges');