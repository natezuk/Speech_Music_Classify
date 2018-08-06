function results = ShortClipTwoBack_test(varargin)
% Subjects are presented with a series of 2-seconds clips of speech, music,
% and "non-vocal human" stimuli with high cross-frequency modulation
% correlations.  Subjects are asked to press the spacebar each time they
% hear a sound clip that is identical the sound two sounds back (aka.
% "two-back"). Our goal will be to try to classify the different stimuli
% based on the 2-s of recorded EEG (based on the experiment by Emily Teoh).
% Nate Zuk (2018)

% Initial variables
sbj = '';
stimdir = 'A:\TeohSpMus\SpeechMusicScrmbStimuli\test\';
orderdir = 'A:\TeohSpMus\SpeechMusicScrmbStimuli\test\stim_order\';
Fs = 20000; % should be the same sampling rate as the stimuli
scrnnum = 0;
nclips = 60; % number of clips per stimulus

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Get a list of stimuli and determine the number of trials
% (each track will be presented once)
wavfls = dir(stimdir);
trknms = {}; % to store track names
for f = 1:length(wavfls),
    if ~wavfls(f).isdir,
        nm = wavfls(f).name;
        % remove the extension
        [~,flnm,ext] = fileparts(nm);
        if strcmp(ext,'.wav'), % make sure it's a wav file
            trknms = [trknms {flnm}];
        end
    end
end
% For each track, load the order of sound clips presented
clip_order = NaN(nclips,length(trknms));
for ii = 1:length(trknms),
    disp(trknms{ii});
    fid = fopen([orderdir trknms{ii} '.txt']);
    for n = 1:nclips, % for each possible number of vibratos
        ln = fgetl(fid); % load the vibrato times on that line
        clip_order(n,ii) = sscanf(ln,'%d'); % store the times
    end
    fclose(fid);
end

%% Initialize audio port
InitializePsychSound();
% % Check available sound devices
% dev = PsychPortAudio('GetDevices');
% Open audio port
% audioprt = PsychPortAudio('Open',10,1,1,Fs,2);
audioprt = PsychPortAudio('Open',3,1,1,Fs,2);
% Using Sound Blaster Audio speaker output (NZ, 1/29/2018)

%% Initialize the parallel port interface
% prllprt = daq.createSession('ni')
% ch = addDigitalChannel(prllprt,'Dev1', 'Port2/Line0:7', 'OutputOnly') % specify the channels to use
%     % (port 2 is connected with the USB receiver)
% outputSingleScan(prllprt, [0 0 0 0 0 0 0 0]) % reset parallel port to 0
prllprt = [];

%% Setup the screen
% Start text
objs.start.type = 'dsc';
objs.start.txt = ['In each trial, you will hear a series of 2-s sounds in succession, lasting 2 min in total.\n', ...
    'While the sounds are being played, please fixate your eyes on the crosshair shown at the center of the screen.\n', ...
    'When you detect a sound that is identical to the sound before the previous one, press the spacebar.\n', ...
    '\n', ...
    'There are ' num2str(length(trknms)) ' trials.\n', ...
    'Press the spacebar when you''re ready.'];
objs.start.active = 1;
% Crosshair shown during trial
objs.cross.type = 'crs';
objs.cross.active = 0;
% Break text
objs.break.type = 'dsc';
objs.break.txt = ['You correctly detected x repeats.\n',...
    '\n',...
    'Trial x/n complete!\n',...
    '\n',...
    'Press any key when you''re ready.'];
objs.break.active = 0;
% End text
objs.end.type = 'dsc';
objs.end.txt = ['Congrats, you have finished the experiment!\n',...
    '\n',...
    'Press any key to exit.'];
objs.end.active = 0;

%% Make the screen and display initial instructions
[wS,objs] = gen_screen(objs,[],'dsp',scrnnum);
[wS,objs] = waitscreen(wS,objs);
objs.start.active = 0; % turn off instruction text

% Reset random number generator
rng('shuffle')

%% Create filename
if isempty(sbj),
    sval = randi([65,90],1,6); % randomly pick 6 uppercase letters (ASCII values)
    sbj = char(sval); % convert the values to ASCII
end
datafn = ['ShortClipTwoBack_res_sbj' sbj '_' date];

%% Setup the trial order
trkorder = randperm(length(trknms)); % randomly rearrange tracks

corr = cell(length(trkorder),1); % cell array to store the correct detections
resptms = cell(length(trkorder),1); % cell arrya to store response times
dettms = cell(length(trkorder),1);

for jj = 1:length(trkorder), % for each block    
    %% Start the experiment
    % Load the stimulus
    [stim,Fs] = audioread([stimdir trknms{trkorder(jj)} '.wav']);
    % Apply a 15 ms onset and offset ramp to the stimulus
    stim = rampstim(stim,Fs);
    aborted = 0; % flag to signify if the experiment was aborted
    % Show the track name
    disp(trknms{trkorder(jj)});
    % run the trial
    objs.cross.active = 1; % show the crosshair
    % Compute the times that should be detected
    clips = clip_order(:,trkorder(jj));
    detreps = find(clips(3:end)==clips(1:end-2))+2; % indexes where a two-back occurs
    dettms{jj} = (detreps-1)*2; % times where a two-back occurs
    [corr{jj},resptms{jj}] = targetdetect_trial(stim,Fs,dettms{jj},...
        'wS',wS,'objs',objs,'audioprt',audioprt,'prllprt',prllprt,...
        'stimtrig',trkorder(jj),'detecttol',2.3);
        % set detect tolerance to 2.3 seconds, 300 ms longer than the duration of a sound clip
    if isnan(corr{jj}),
        aborted = 1; % set aborted flag
        break
    end
    objs.cross.active = 0; % turn off the crosshair

    % Show performance on wobble detection
    fprintf('%d/%d detected\n',sum(corr{jj}),length(dettms{jj}));
    
    % Save the results
    results.corr = corr;
    results.resptms = resptms;
    results.trkorder = trkorder;
    results.trknms = trknms;
    results.dettms = dettms;
    results.aborted = aborted;
    save(datafn,'results');
    
    % Display trial number completed and correct responses
    if jj<length(trkorder), % if it's not the last trial
        objs.break.txt = [sprintf('You correctly detected %d/%d repeats.\n',sum(corr{jj}),length(dettms{jj})),...
            '\n',...
            sprintf('Trial %d/%d complete!\n',jj,length(trkorder)),...
            '\n',...
            'Press any key when you''re ready.'];
        objs.break.active = 1;
        [wS,objs] = waitscreen(wS,objs);
        objs.break.active = 0; % turn off 
    else % if it is the last trial
        objs.end.txt = [sprintf('You correctly detected %d/%d repeats.\n',sum(corr{jj}),length(dettms{jj})),...
            '\n',...
            'Congrats, you have finished the experiment!\n',...
            '\n',...
            'Press any key to exit.'];
        objs.end.active = 1;
        [wS,objs] = waitscreen(wS,objs);
    end
end
%% Close Psych stuff
PsychPortAudio('Close',audioprt);
Screen('Close',wS.ptr);
%% Close parallel port
clear prllprt ch