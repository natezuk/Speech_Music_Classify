function flteeg = prefiltereeg(eeg,Fs,varargin)
% Filter the eeg using a standard bandpass chebyshev type II filter with
% zero-phase filtering.  
% Setup for SpeechMusicClassify

Fstop1 = 0.75;               % Lower stopband frequency (Hz)
Fpass1 = 1;                 % Lower passband frequency (Hz)
Fpass2 = 45;                 % Upper passband frequency (Hz)
Fstop2 = 60;                % Upper stopband frequency (Hz)
Astop  = 60;                % Stopband attenuation (dB)
Apass  = 1;                 % Passband attenuation (dB)

% % Generate bandpass filter
h = fdesign.highpass(Fstop1,Fpass1,Astop,Apass,Fs);
hpf = design(h,'cheby2','MatchExactly','stopband');
l = fdesign.lowpass(Fpass2,Fstop2,Apass,Astop,Fs);
lpf = design(l,'cheby2','MatchExactly','stopband');

flteeg = filtfilthd(hpf,eeg);
flteeg = filtfilthd(lpf,flteeg);