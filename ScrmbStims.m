% Compute the statistics of each sound from TeohSpMus

sndpth = 'A:\TeohSpMus\OrigScrambExp\';
scrmbpth = 'C:\Users\nzuk\Data\TeohStimClass\scrambled\';
fls = dir(sndpth);

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

        % Set the initial parameters
        P.orig_sound_filename = sndfl{end};
        P.orig_sound_folder = sndpth;
        P.desired_synth_dur_s = length(y)/Fs;

        % Downsample the sound to the expected sampling rate, specified in P
        expFs = P.audio_sr;
        y = resample(y,expFs,Fs);

        % Compute the statistics
        synth = run_synthesis(P);
        
        % Save the sound 
        audiowrite([sndfl '_scrmb.wav'],y,expFs);
        
        disp(sndfl);
    end
end