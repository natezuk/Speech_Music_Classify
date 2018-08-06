function NEWEEG = denoiseeeg(EEG,interpchans,icasig,A,rmvcmps)
% Denoise the EEG by removing ICA components and interpolating channels (in
% that order)

if nargin<2, % if there are no channels to interpolate...
   interpchans = [];
end
if nargin<3, % if there are no ICA components to remove
   rmvcmps = []; 
end

% Concatenate the EEG across trials
if iscell(EEG),
    disp('Concatenating the trials...');
    eeg = [];
    durs = NaN(length(EEG),1);
    for ii = 1:length(EEG), % concatenate the EEG signal
        eeg = [eeg; EEG{ii}];
        durs(ii) = size(EEG{ii},1);
    end
else
    eeg = EEG;
end

% Remove ICA component(s)
if ~isempty(rmvcmps),
    disp('Removing ICA components...');
    artfct = A(:,rmvcmps)*icasig(rmvcmps,:);
    rmeeg = eeg-artfct';
end

% Remove noisy channels and recompute those channels by computing the
% average of the neighboring channels
disp('Interpolating noisy channels...');
if ~isempty(interpchans)
    interpeeg = sphinterp(rmeeg,interpchans');
    rmeeg(:,interpchans) = interpeeg;
end

% Split up the EEG into separate trials
% Splice the principal components by trial
if iscell(EEG),
    NEWEEG = cell(length(EEG),1);
    for ii = 1:length(EEG),
        ind = sum(durs(1:ii-1))+(1:durs(ii));
        NEWEEG{ii} = rmeeg(ind,:);
    end
else
    NEWEEG = rmeeg;
end