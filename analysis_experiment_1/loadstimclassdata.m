function [eegs,stims] = loadstimclassdata(eegpth,sbj)
% Load the data from Emily Teoh's stimulus classification experiment
% (NZ, 4/12/2018)

% Initial variables
eFs = 128; % sampling rate of the EEG
nchan = 128; % number of channels
ntr = 100; % number of trials per stimulus
nstim = 30; % number of stimuli
stimdur = 2; % number of seconds per stimulus

% Preallocate an array to store EEG data
eegs = NaN(eFs*stimdur,nchan,ntr,nstim);
stims = cell(nstim,1); % names of each of the stimuli

% Get the set of folders (one for each stimulus)
stimcnt = 1; % counter for the different stimuli
flds = dir([eegpth sbj]);
for f = 1:length(flds) % for each item in the subject directory...
    if flds(f).isdir % ...if it's a directory...
        minnmind = min([length(flds(f).name) 4]); % get 4 (length of 'stim') or the last index of the directory name
        if strcmp(flds(f).name(1:minnmind),'stim') % ...and if it contains stimulus responses...
            respdir = [eegpth sbj '/' flds(f).name];
            % Load the eeg in each trial and save in the eeg array
            fls = what(respdir);
            mats = fls.mat; % mat files in the directory
            if length(mats)>100,
                disp(['Check: ' flds(f).name]);
                keyboard;
            end
            for m = 1:length(mats),
                d = load([respdir '/' mats{m}]); % load the mat file
                % get the eeg data specifically
                dvars = fieldnames(d);
                eegdataidx = cellfun(@(x) strcmp(x(1:4),'clip'),dvars); % find the variable with eeg data
                eval(['eegs(:,:,m,stimcnt) = d.' dvars{eegdataidx} ''';']);
            end
            % Check if all trials have been run
            if length(mats)~=ntr, warning(['Not all trials were run for stim ' flds(f).name]); end
            % Store the stimulus name
            stims{stimcnt} = flds(f).name;
            % Show that the stimulus data has been loaded
            disp(flds(f).name);
            stimcnt = stimcnt + 1; % increment for the next stimulus
        end
    end
end