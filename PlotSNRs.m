% Display average SNRs for the synthesized stimuli (specifically those that are
% constrained during synthesis)
load('SynthStats');

% Get a reordering of the synthesized stimuli, so that music, speech, and
% impact are grouped separately
% I have to specify the order here, because the order of stims is not the
% same as in scrmblbls
stims = {'stim72_cello.wav',...
    'stim81_chopping_wood.wav',...
    'stim85_clipping_hair.wav',...
    'stim174_girl_speaking.wav',...
    'stim216_knuckle_cracking.wav',...
    'stim268_piano.wav',...
    'stim315_saxophone_jazz_solo.wav',...
    'stim332_angry_shouting.wav',...
    'stim399_walking_on_hard_surface.wav',...
    'stim401_walking_with_heels.wav',...
    'stim461_latin_music.wav',...
    'stim501_spanish.wav',...
    'stim503_italian.wav',...
    'stim504_german.wav',...
    'stim524_cartoon_sound_effects.wav'};
% 1 = music, 2 = speech, 3 = impact
stimlbl = [1,...% cello
    3,...%chopping wood
    3,...%clipping hair
    2,...%girl speaking
    3,...%knuckle cracking
    1,...%piano
    1,...%saxophone
    2,...%angry shouting
    3,...%walking on hard surface
    3,...%walking with heels
    1,...%latin music
    2,...%spanish
    2,...%italian
    2,...%german
    1]; %cartoon sound effects
[srtlbl,idx] = sort(stimlbl); % sort labels in order to group by type

for n = 1:length(stims)
    stim_idx = idx(n); % identify the stimulus to display, so that they are grouped by type
    % parameters to display are chosen based on the constraint set
    fprintf('%s: \tSubband = %.2f, Env = %.2f, Mod = %.2f\n',...
        stims{stim_idx},SNRs{stim_idx}.subband_var,...
        mean([SNRs{stim_idx}.env_mean,SNRs{stim_idx}.env_var,SNRs{stim_idx}.env_skew,SNRs{stim_idx}.env_C]),...
        mean([SNRs{stim_idx}.mod_power,SNRs{stim_idx}.mod_C1,SNRs{stim_idx}.mod_C2]));
end