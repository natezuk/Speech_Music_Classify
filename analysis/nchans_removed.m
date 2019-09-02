% Check for the number of channels removed for each subject in
% SpeechMusicClassify
% Nate Zuk (2019)

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/';

fls = what(eegpth); % get the list of all data files
% identify which ones contain removed data
rmv_eeg_idx = cellfun(@(x) strcmp(x(7:end),'_removed.mat'),fls.mat);
rmv_fls = fls.mat(rmv_eeg_idx); % get those files

interp_chans = cell(length(rmv_fls),1); % to store values of interpolated channels
ninterp = NaN(length(rmv_fls),1);
for ii = 1:length(rmv_fls)
    r = load([eegpth rmv_fls{ii}]); % load removed eeg data
    interp_chans{ii} = r.interpchans; % get the interpolated channels
    ninterp(ii) = length(r.interpchans); % get the number of channels interpolated
    disp(rmv_fls{ii});
end