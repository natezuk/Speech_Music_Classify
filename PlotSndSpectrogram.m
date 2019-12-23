% Plot spectrogram for one of the 2-second sounds from the classification
% experiment
% addpath('~/Documents/MATLAB/spectrotemporal-synthesis-v2-master/Sound_Texture_Synthesis_Toolbox/');
addpath('~/Documents/Matlab/Sound_Texture_Synthesis_Toolbox');

% usedsnds = {'stim80_chopping_food.wav','stim399_walking_on_hard_surface.wav'};
% sndsfromexperiment = {'norm_stim81_chopping_wood.wav',...
%    'norm_stim85_clipping_hair.wav',...
%    'norm_stim216_knuckle_cracking.wav',...
%    'norm_stim399_walking_on_hard_surface.wav',...
%    'norm_stim401_walking_with_heels.wav'};
snd = 'synth_stim399_walking_on_hard_surface.wav';
% snd = 'synth_stim268_piano.wav';
% snd = 'synth_stim174_girl_speaking.wav';
% snd = 'stim399_walking_on_hard_surface.wav';
sndpth = '/Volumes/Untitled/TeohSpMus/OrigScrambExp/';

% Load the sound file
[y,Fs] = audioread([sndpth snd]);

% Make the cochleogram (aka. subbands, McDermott & Simoncelli, 2011)
[audio_filts, audio_cutoffs_Hz] = make_erb_cos_filters(length(y), ...
    Fs, 30, 20, 10000);
% # audio channels = 30
% lowest audio = 20 Hz
% highest audio = 10 kHz
subbands = generate_subbands(y, audio_filts);
% Hilbert transform and apply compression
subband_envs = abs(hilbert(subbands));
subband_envs = subband_envs.^0.3; % power compression with 0.3
% ds_factor=Fs/P.env_sr;
subband_envs = resample(subband_envs,400,Fs); % downsample to 400 Hz
subband_envs(subband_envs<0)=0;

% Plot the cochleogram
t = (0.5:size(subband_envs,1)-0.5)/400;
figure
% cmap = colormap('gray');
cmap = colormap('jet');
% colormap(flipud(cmap)); % plot as in McDermott & Simoncelli, with black for higher 
    % magnitude and white for lower magnitude
imagesc(t,1:length(audio_cutoffs_Hz)-2,subband_envs(:,2:end-1)');
axis('xy');
axis('square');
colorbar
hz_idx = [2 15 31]; % frequencies to display on the y-axis
set(gcf,'Position',[180 400 400 300]);
set(gca,'FontSize',16,'YTick',hz_idx-1,'YTickLabel',round(audio_cutoffs_Hz(hz_idx)));
xlabel('Time (s)');
ylabel('Cochlear channel (Hz)');

% Get the power spectrogram
% frqs = logspace(log10(100),log10(8000),50);
% [~,F,T,P] = spectrogram(y,Fs/20,[],frqs,Fs);
% 
% fidx = find(F>=100&F<=8000); % plot a specific range of frequencies
% 
% % Plot the spectrogram
% figure
% imagesc(T,1:length(fidx),10*log10(P(fidx,:)));
% axis('xy');
% lblfrq_idx = [1 round(length(fidx)/2) length(fidx)];
% set(gca,'FontSize',16,'YTick',lblfrq_idx,'YTickLabel',round(F(fidx(lblfrq_idx))));
% colorbar;
% xlabel('Time (s)');
% ylabel('Frequency (Hz)');
% title(snd,'Interpreter','none');