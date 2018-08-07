% Denoise the EEG after running ICA
% (Run RunICAExamine first)

interpchans = [];
rmvcmps = [1];

eeg = denoiseeeg(EEG,interpchans,icasig,A,rmvcmps);

% Display the variance of the eeg channels
plot_chan_var(eeg);