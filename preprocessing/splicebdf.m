function [EEG,trig,stim] = splicebdf(fulleeg,fulltrigs,stimcodes,clicktrig,Fs)
% Split a recorded EEG signal into separate trials.  Each trial starts with
% the first 128 trigger following a stimulus code.  Each trial ends with a
% 126 unpause trigger.
% Inputs:
%   - fulleeg = full EEG signal extracted from bdf data
%   - fulltrigs = all triggers for the extracted bdf data
%   - stimcodes = list of possible stimulus codes
%   - clicktrig = value for trigger in response to click
% Outputs:
%   - EEG = cell array of EEG signal spliced by trial
%   - trig = cell array of triggers for each trial
%   - stim = array of stimulus codes per trial

% Find the timepoints for triggers that are stimulus codes
trigstims = intersect(fulltrigs,stimcodes);

stinds = [];
endinds = [];
for s = 1:length(trigstims) % for each stimulus code...
    % ...identify all instances of the stimulus code trigger
    st = find(trigstims(s)==fulltrigs,1,'first');
    stinds = [stinds st];
    ed = find(trigstims(s)==fulltrigs,1,'last');
    endinds = [endinds ed+Fs]; % set ending time at 1 second past the end of the stimulus
end

stim = NaN(length(stinds),1);
EEG = cell(length(stinds),1);
trig = cell(length(stinds),1);
for ii = 1:length(stinds) % for each stimulus code trigger...
    % ...find the first 128 trigger...
    sndind = find(fulltrigs(stinds(ii):end)==clicktrig,1,'first')+stinds(ii)-1;
    % ...find the trigger for the stimulus code at the end of the trial...
    unpsind = endinds(ii);
    % ...and grab the EEG signal between those indexes
    EEG{ii} = fulleeg(sndind:unpsind,:);
    trig{ii} = fulltrigs(sndind:unpsind);
    stim(ii) = fulltrigs(stinds(ii));
end