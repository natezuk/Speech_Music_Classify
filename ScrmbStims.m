% Compute the statistics of each sound from TeohSpMus

sndpth = '/Volumes/Untitled/TeohSpMus/OrigScrambExp/origstim/';
dwnsmpth = '/Volumes/Untitled/TeohSpMus/test_synth/dwnsmp/';
scrmbpth = '/Volumes/Untitled/TeohSpMus/test_synth/synth/';
fls = dir(sndpth);
% quilt_wnd = 40; % quilt window, in ms
% expFs = 20000;

% Load general parameters for calculating the stimulus statistics (based on
% McDermott & Simoncelli (2011)
synthesis_parameters;

sndfl = {}; % to store sound filename
modc2 = []; % to store c2 correlations
for n = 1:length(fls),
    if ~fls(n).isdir,
        sndfl = [sndfl {fls(n).name}];
        % Load the sound
        [y,Fs] = audioread([sndpth sndfl{end}]);

        % Downsample the sound to the expected sampling rate, specified in P
        expFs = P.audio_sr;
        y = resample(y,expFs,Fs);
        audiowrite([dwnsmpth sndfl{end}],y,expFs);
        
        dur = length(y)/expFs;
        
        % Set the initial parameters
        P.orig_sound_filename = sndfl{end};
        P.orig_sound_folder = dwnsmpth;
        P.max_orig_dur_s = dur;
        P.desired_synth_dur_s = dur;
        P.output_folder = scrmbpth;
        P.save_figures = 1;
        P.display_figures = 1;
        P.end_criterion_db = 30; % db 
        P.constraint_set.mod_C2 = 1; % contrain mod C2, which defined the non-vocal human sounds
% 
        % Compute the statistics
        synth = run_synthesis(P);
        
        disp(sndfl);
        keyboard;
    end
end