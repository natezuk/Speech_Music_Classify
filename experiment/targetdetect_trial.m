function [corr,resptms] = targetdetect_trial(stim,Fs,target_times,varargin)

%This test is meant to deliver an audio stimulus to a participant and
%record the times at which the participant hits the button. Each press of
%the button is supposed to represent the time at which the participant
%heard any target in the audio.  The audio can contain multiple targets, so
%the code allows for real time recording of button presses and stores the
%times that they occur into a variable array.  This is then compared to the
%array of target times that is delivered into this function.
%Robert Crews & Nate Zuk (2017-2018)

    %stim = audio
    %Fs = sampling rate (in Hz)
    %target_times = times of the targets (in s)
    
wS = []; % window pointer
objs = []; % objects in window
audioprt = []; % audio port
prllprt = []; % parallel port object, with which to send triggers
sil = 1; % duration of silence before stimulus
clkamp = 0.6; % magnitude of the click (in V)
clkdur = 1; % duration of the click (in ms)
detecttol = 1.5; % duration following event at which the keypress is a correct detection (in s)
dbdrop = -35; % amount to drop the stimulus amplitude in dB V to produce a comfortable
    % sound level for stimulus presentation
stimtrig = 0; % trigger for trial start and end
resptrig = 128; % trigger for subject response

if ~isempty(varargin)
    for n = 2:2:length(varargin)
        eval([varargin{n-1} '=varargin{n};']);
    end
end

if ~isempty(wS) % (if using psychtoolbox)
    % Reset the screen
    [wS,objs] = gen_screen(objs,wS);
    % Render screen
    Screen('Flip',wS.ptr); 
end

if ~isempty(audioprt),
    %% Present stimulus
    % Add click to buffer
    clkidx = round(clkdur/1000*Fs); % duration of the click, in indexes
    clk = [clkamp*ones(clkidx,1); zeros(Fs-clkidx,1)]; % click followed by 1 second of silence
    buf(1) = PsychPortAudio('CreateBuffer',audioprt,ones(2,1)*clk');
    % Add stimulus to buffer
    stim = adjdb(stim,dbdrop); % set the db V of the stimulus so the sound level is comfortable
    buf(2) = PsychPortAudio('CreateBuffer',audioprt,ones(2,1)*stim');
    
    %% Set up audio port schedule with the sound files
    % Add stimulus to schedule
    PsychPortAudio('UseSchedule',audioprt,2);
    PsychPortAudio('AddToSchedule',audioprt,buf(1)); % added click
    PsychPortAudio('AddToSchedule',audioprt,buf(2)); % added stimulus

    % Send a trigger for the start of the trial (1 second before click)
    if ~isempty(prllprt), 
        outputSingleScan(prllprt,dec2binvec(stimtrig,8))
        outputSingleScan(prllprt,dec2binvec(0,8))
    end
    % After silence, start playing the click and then the stimulus
    PsychPortAudio('Start',audioprt,1,GetSecs+sil,1);
    strttm = GetSecs+1; % start time of the stimulus is 1 s after click
    keyhold = 0; % to check if key is being held down
    resptms = []; % store response times relative to sound start
    prtstatus = PsychPortAudio('GetStatus',audioprt);
    % While the audio is running (GetStatus:Active is 1)
    while prtstatus.Active,
        % Check when the subject presses the spacebar
        [keyDown,secs,keyCode] = KbCheck();
        % if the key has been pressed...
        if keyDown,
%             if keyDown==1 && strcmp(KbName(keyCode),'space'),
            % ...check if the key is currently being held down...
            if ~keyhold, %...and if it is...
                % send trigger for keypress
                if ~isempty(prllprt), 
                    outputSingleScan(prllprt,dec2binvec(resptrig,8))
                    outputSingleScan(prllprt,dec2binvec(0,8))
                end
                resptms = [resptms; secs-strttm-prtstatus.PredictedLatency]; % save the response time
                    % adjusted by the start time of the stimulus and
                    % the predicted latency of the system
                keyhold=1; % flag that the key is being held down
            end
        else % if the key is not pressed...
            keyhold=0; % ...flag that the key is not being held down
        end
        prtstatus = PsychPortAudio('GetStatus',audioprt); % update the state of the audio port
    end
    % Wait until it ends
    PsychPortAudio('Stop',audioprt,1);
    % Send a trigger for the end of the trial (1 second before click)
    if ~isempty(prllprt), 
        outputSingleScan(prllprt,dec2binvec(stimtrig,8))
        outputSingleScan(prllprt,dec2binvec(0,8))
    end
else
    warning('PsychPortAudio port not specified, using audioplayer() to play stimuli');
    % Play sound files via Matlab
    stim_player = audioplayer([zeros(1,round(sil*Fs)) stim'],Fs);
    play(stim_player);
end

%% Compute the number of correct detections
corr = false(length(target_times),1);
for ii = 1:length(target_times), % for each vibrato time
    % check the number of key presses that were a correct detection of the
    % vibrato time
    detected = sum(resptms>=target_times(ii) & resptms<=target_times(ii)+detecttol);
    % as long as there's one correct keypress, count it as a correct
    % detection
    corr(ii) = detected>0;
end