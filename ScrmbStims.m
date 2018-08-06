% Compute the statistics of each sound from TeohSpMus

sndpth = 'A:\TeohSpMus\OrigScrambExp\';
dwnsmpth = 'C:\Users\nzuk\Data\TeohStimClass\dwnsmp\';
scrmbpth = 'C:\Users\nzuk\Data\TeohStimClass\synths\';
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

%         P.filt_density = 1; %1 for regular filterbank, 2 for 4x overcomplete
%         P.N_audio_channel = 30;
%         P.audio_low_lim_Hz = 20;
%         P.audio_high_lim_Hz = 10000;
%         P.audio_sr = expFs;

%         % Quilt the stimulus
%         sy = generate_quilt(y,quilt_wnd,1,dur-1,P);
%         
%         % Save the sound 
%         audiowrite([sndfl '_scrmb.wav'],y,expFs);
        
        disp(sndfl);
        keyboard;
    end
end