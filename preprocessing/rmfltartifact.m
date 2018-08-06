function neweeg = rmfltartifact(eeg,Fs,varargin)
% Remove artifacts at the start and end of the eeg signal caused by the
% filtering process.
% Inputs:
% - eeg = eeg signal (time x channel)
% - Fs = sampling frequency (Hz)
% Outputs:
% - neweeg = eeg with artifacts removed

% Filter parameters
Fstop1 = 0.75;               % Lower stopband frequency (Hz)
Fpass1 = 1;                 % Lower passband frequency (Hz)
Fpass2 = 45;                 % Upper passband frequency (Hz)
Fstop2 = 60;                % Upper stopband frequency (Hz)
Astop  = 60;                % Stopband attenuation (dB)
Apass  = 1;                 % Passband attenuation (dB)

if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Remove artifacts produced by the filter using linear regression
dltstart = [1; zeros(size(eeg,1)-1,1)]; %starting artifact
artfct = prefiltereeg(dltstart,Fs,'Fstop1',Fstop1,'Fpass1',Fpass1,'Fpass2',Fpass2,...
    'Fstop2',Fstop2,'Astop',Astop,'Apass',Apass);
b = artfct \ eeg;
neweeg = eeg-artfct*b;

dltend = [zeros(size(eeg,1)-1,1); 1]; %ending artifact
artfct = prefiltereeg(dltend,Fs,'Fstop1',Fstop1,'Fpass1',Fpass1,'Fpass2',Fpass2,...
    'Fstop2',Fstop2,'Astop',Astop,'Apass',Apass);
b = artfct \ neweeg;
neweeg = neweeg-artfct*b;