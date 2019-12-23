% Plot spectrogram for one of the 2-second sounds from the classification
% experiment
% addpath('~/Documents/MATLAB/spectrotemporal-synthesis-v2-master/Sound_Texture_Synthesis_Toolbox/');
addpath('~/Documents/Matlab/Sound_Texture_Synthesis_Toolbox');

sndpth = '/Volumes/Untitled/TeohSpMus/OrigScrambExp/';

stims = {'stim268_piano.wav',...
    'stim315_saxophone_jazz_solo.wav',...
    'stim461_latin_music.wav',...
    'stim524_cartoon_sound_effects.wav',...
    'stim72_cello.wav',...
    'stim174_girl_speaking.wav',...
    'stim332_angry_shouting.wav',...
    'stim501_spanish.wav',...
    'stim503_italian.wav',...
    'stim504_german.wav',...
    'stim216_knuckle_cracking.wav',...
    'stim399_walking_on_hard_surface.wav',...
    'stim401_walking_with_heels.wav',...
    'stim81_chopping_wood.wav',...
    'stim85_clipping_hair.wav'};

figure; % initialize the figure for the all cochleograms

for n = 1:length(stims)
    %%% Original sound
    
    % Get the filename for the original sound
    norm_snd = sprintf('norm_%s',stims{n});
    
    % Load the sound file
    [y,Fs] = audioread([sndpth norm_snd]);

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
    plt_idx = floor((n-1)/5)*10+mod((n-1),5)+1;
    subplot(6,5,plt_idx);
    t = (0.5:size(subband_envs,1)-0.5)/400;
    cmap = colormap('jet');
%     colormap(flipud(cmap)); % plot as in McDermott & Simoncelli, with black for higher 
        % magnitude and white for lower magnitude
    imagesc(t,1:length(audio_cutoffs_Hz)-2,subband_envs(:,2:end-1)');
    axis('xy');
    axis('square');
    colorbar
    hz_idx = [2 15 31]; % frequencies to display on the y-axis
    set(gca,'FontSize',10,'YTick',hz_idx-1,'YTickLabel',round(audio_cutoffs_Hz(hz_idx)));
%     xlabel('Time (s)');
%     ylabel('Channel (Hz)');
    
    disp(norm_snd);
    
    %%% Model-matched sound
    
    % Get the filename for the original sound
    synth_snd = sprintf('synth_%s',stims{n});
    
    % Load the sound file
    [y,Fs] = audioread([sndpth synth_snd]);

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
    % compute the row in which to plot the cochleogram
    subplot(6,5,plt_idx+5);
    t = (0.5:size(subband_envs,1)-0.5)/400;
    cmap = colormap('jet');
%     colormap(flipud(cmap)); % plot as in McDermott & Simoncelli, with black for higher 
        % magnitude and white for lower magnitude
    imagesc(t,1:length(audio_cutoffs_Hz)-2,subband_envs(:,2:end-1)');
    axis('xy');
    axis('square');
    colorbar
    hz_idx = [2 15 31]; % frequencies to display on the y-axis
    set(gca,'FontSize',10,'YTick',hz_idx-1,'YTickLabel',round(audio_cutoffs_Hz(hz_idx)));
%     xlabel('Time (s)');
%     ylabel('Channel (Hz)');
    
    disp(synth_snd);
end