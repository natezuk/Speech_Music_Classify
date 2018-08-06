% Test out using polynomial detrending on the EEG data

% Start by doing linear detrending
dtEEG = cell(length(EEG),1);
mnEEG = cell(length(EEG),1);
for ii = 1:length(EEG),
    dtEEG{ii} = detrend(EEG{ii});
    dtEEG{ii} = nt_detrend(dtEEG{ii},7);
%     mnEEG{ii} = mean(dtEEG{ii},2);
end

% figure
% hold on
% for ii = 1:length(mnEEG), plot(mnEEG{ii}); end