function [eegs,stims] = loadnewnatclassdata(eegpth,sbj,stimpth)
% Load the data from Teoh's Natural Sounds experiment (Experiment 1 for the
% Speech/Music classification paper)
% Nate Zuk (2019)

% Initial variables
eFs = 128; % sampling rate of the EEG
nchan = 128; % number of channels
ntr = 100; % number of trials per stimulus
nclip = 30; % number of stimuli
stimdur = 2; % number of seconds per stimulus

% Preallocate an array to store EEG data
eegs = NaN(eFs*stimdur,nchan,ntr,nclip);

% Get the set of folders (one for each stimulus)
for n = 1:nclip % for each item in the subject directory...
    flnm = sprintf('%s_clip%d',sbj,n);
    d = load([eegpth '/' flnm]); % load the mat file
    % get the eeg data specifically
    eegs(:,:,:,n) = d.clipeeg;
    % Check if trials weren't run
    nantrs = sum(sum(isnan(d.clipeeg)));
    % Check if all trials have been run
    if sum(nantrs)>0, warning(['Not all trials were run for clip ' num2str(n)]); end
    % Show that the stimulus data has been loaded
    disp(flnm);
end

% Load the stimulus names
stims = d.unique_stims;