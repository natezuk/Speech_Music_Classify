% Denoise the EEG after running ICA
% (Run RunICAExamine first)

interpchans = [];
rmvcmps = [2];

eeg = denoiseeeg(EEG,interpchans,icasig,A,rmvcmps);

disp('Saving...');
svfl = sprintf('sbj%s',sbj);
%%% Doesn't save because the file is too big.  Need to save as separate
%%% trials
save(['/scratch/nzuk/SpeechMusicClassify/eegs/' svfl],'eeg','eFs');