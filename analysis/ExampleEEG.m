% Load the subject data for EEG responses to various times of sounds, 
% and create a classifier to classify each of the different
% types of sounds. This is done iteratively for each channel
% (NZ, 16-1-2019)
addpath('~/Projects/Speech_Music_Classify/');
addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/'; % contains eeg data
stimpth = '/Volumes/Untitled/SpeechMusicClassify/stims/'; % contains labeling for the sound clips and the stimuli
respth = '/Volumes/ZStore/SpeechMusicClassify/';
sbj = 'HGWLOI'; % subject name
eFs = 128;
% trange = 200; % range of times to include in the classifier (in ms)
% tstep = 100; % step size between time ranges (in ms)

disp('Loading eeg data...');
[eegs,stims] = loadscrmbclassdata(eegpth,sbj,stimpth);

% Compute the principal components
resfl = sprintf('StimClassLDA_%s',sbj);
res = load([respth resfl]);
pc = d.sc(:,1:d.maxpc);

ComputeTwoBack;

% Concatenate 5 EEG segments together
ntrial = 1;
first_stim = 10;
nclips = 5;
stim_use = clip_order((0:nclips-1)+first_stim,ntrial);
eeg_use = NaN(size(eegs,1),size(eegs,2),nclips);
for n = 1:nclips,
    % get the rep # of the stimulus (how many of the same type came before
    % it?)
    rep = sum(clip_order(1:n-1+first_stim,ntrial)==stim_use(n));
    eeg_use(:,:,n) = eegs(:,:,rep,stim_use(n));
end
eeg_use = zscore(eeg_use); % normalize each channel to the same mean and variance, for visibility in the plot

% Plot the EEG, separate channels, color code so that the middle segment is red
chan_use = 1:30:size(eegs,2); % channels to plot
sep_amount = 5; % amount of separation between channels in the plot, in standard deviations
t = (0:size(eegs,1)*5-1)/eFs;
figure
hold on
for n = 1:nclips,
    tidx = (n-1)*size(eegs,1)+(1:size(eegs,1));
    eeg_for_plot = eeg_use(:,chan_use,n)+repelem(1:length(chan_use),size(eeg_use,1),1)*sep_amount;
        % eeg after adding values to separate channels
    if n==ceil(nclips/2)
        plot(t(tidx),eeg_for_plot,'r');
    else
        plot(t(tidx),eeg_for_plot,'k');
    end
end
set(gca,'FontSize',16);
xlabel('Time (s)');
ylabel('Channel');

% Plot the principal components for the clip shown in red
figure
set(gcf,'Position',[360,422,400,250]);
tr_to_plot = first_stim+(ceil(nclips/2)-1);
plot(pc(tr_to_plot,:),'k');
set(gca,'FontSize',16,'XLim',[0 300])
xlabel('Principal component');
ylabel('Weight');