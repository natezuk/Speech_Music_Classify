% Compute the statistics of each sound from TeohSpMus
% addpath('~/Documents/Matlab/spectrotemporal-synthesis-v2-master/Sound_Texture_Synthesis_Toolbox');
addpath('~/Documents/Matlab/Sound_Texture_Synthesis_Toolbox');

sndpth = '/Volumes/Untitled/TeohSpMus/Natural Sounds - Stimuli/';
% sndpth = '/Volumes/Untitled/TeohSpMus/test_synth/synth/';

% List of all stimulus names
% stims = {'stim174_girl_speaking.wav'};
stims = {'stim107_dial_tone.wav'};
%     'stim315_saxophone_jazz_solo.wav',...
%     'stim461_latin_music.wav',...
%     'stim524_cartoon_sound_effects.wav',...
%     'stim72_cello.wav',...
%     'stim174_girl_speaking.wav',...
%     'stim332_angry_shouting.wav',...
%     'stim501_spanish.wav',...
%     'stim503_italian.wav',...
%     'stim504_german.wav',...
%     'stim216_knuckle_cracking.wav',...
%     'stim399_walking_on_hard_surface.wav',...
%     'stim401_walking_with_heels.wav',...
%     'stim81_chopping_wood.wav',...
%     'stim85_clipping_hair.wav'};

% Load general parameters for calculating the stimulus statistics (based on
% McDermott & Simoncelli (2011)
synthesis_parameters;
P.constraint_set.mod_C2 = 1; % to make sure the mod_C2 stats are right

sndfl = cell(length(stims),1); % to store sound filename
SNRs = cell(length(stims),1);
for n = 1:length(stims),
    %%% Original sound stats
    % Load the sound
    sndfl{n} = stims{n};
    [y,Fs] = audioread([sndpth sndfl{n,1}]);

    % Set the initial parameters
    P.orig_sound_filename = sndfl{n,1};
    P.orig_sound_folder = sndpth;
    dur = length(y)/Fs;
    P.max_orig_dur_s = dur;
    P.desired_synth_dur_s = dur;

    % Compute the statistics
    % use raised-cosine measurement window for original
    meas_win = set_measurement_window(length(y), P.measurement_windowing, P);
    normS = measure_texture_stats(y,P,meas_win);
    normS = edit_measured_stats(normS,P);

    disp(sndfl{n});
end