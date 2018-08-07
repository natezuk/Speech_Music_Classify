% Denoise the EEG after running ICA
% Then split the EEG into responses to separate stimuli
% (Run RunICAExamine first)

addpath('~/SpeechMusicClassify/');
desFs = 128; % desired sampling rate of the EEG (in Hz)
eeg_pth = '/scratch/nzuk/SpeechMusicClassify/eegs/';

interpchans = [];
rmvcmps = [1];

eeg = denoiseeeg(EEG,interpchans,icasig,A,rmvcmps);
% Downsample the eeg 
disp('Downsampling the eeg...');
dwneeg = cell(length(eeg),1);
for ii = 1:length(eeg),
    dwneeg{ii} = downsample(eeg{ii},eFs/desFs);
end

% Save the components that were removed
disp('Saving the denoising info...');
a = A(:,rmvcmps);
sigs = icasig(rmvcmps,:);
save([eeg_pth sbj '_removed'],'interpchans','a','sigs');
clear a sigs icasig A

% disp('Saving...');
% svfl = sprintf('sbj%s',sbj);
% %%% Doesn't save because the file is too big.  Need to save as separate
% %%% trials
% save(['/scratch/nzuk/SpeechMusicClassify/eegs/' svfl],'eeg','eFs');

% Load the stimulus order on each trial
order_pth = '/scratch/nzuk/SpeechMusicClassify/stim_order/';
order = get_stim_order(order_pth,stimcodes);

% Go through each trial, find when a particular sound clip was presented,
% and save all EEG data for that sound clip
disp('Splicing the eeg into separate responses for separate sound clips...');
nclips = 30; % number of sound clips
for n = 1:nclips,
    clipeeg = NaN(2*desFs,128,80); 
    % Find all occurrences of the sound clip
    [rw,cl] = find(order==n);
    for ii = 1:length(rw),
        % get the time indexes for the sound clip
        st_idx = (rw(ii)-1)*2*desFs+1;
        ed_idx = rw(ii)*2*desFs;
        tm_idx = desFs+(st_idx:ed_idx);
        clipeeg(:,:,ii) = dwneeg{cl(ii)}(tm_idx,:);
    end
    % Save the eeg
    eegfl = sprintf('%s_clip%d',sbj,n);
    save([eeg_pth eegfl],'clipeeg');
    disp(eegfl);
end

clear dwneeg eeg clipeeg