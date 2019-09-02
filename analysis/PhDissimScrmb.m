% Load the subject data for EEG responses to various times of sounds, 
% and save the phase dissimilarity as a function of frequency for each of the sounds
% (NZ, 15-7-2019)
addpath('~/Projects/Speech_Music_Classify/');
addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/'; % contains eeg data
stimpth = '/Volumes/Untitled/SpeechMusicClassify/stims/'; % contains labeling for the sound clips and the stimuli
sbj = 'ZLIDEI'; % subject name
eFs = 128;

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

% Compute the phase dissimilarity
freq_edges = 0:4:40; % edges between frequency bins, in Hz
% average eeg across channels
avgeeg = squeeze(mean(eegs,2,'omitnan'));
[~,~,phdis] = phaseDissimilarity(avgeeg,eFs,'freq_edges',freq_edges);

% Plot the phase dissimilarity
figure
cnts = freq_edges(1:end-1)+diff(freq_edges)/2;
plot(cnts,phdis,'k.','MarkerSize',16);
set(gca,'FontSize',16);
xlabel('Frequency (Hz)');
ylabel('Phase dissimilarity');

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/SpeechMusicClassify/phdis_exp2/';
resfl = sprintf('StimClassPhDis_%s',sbj);
save([respth resfl],'phdis','freq_edges');