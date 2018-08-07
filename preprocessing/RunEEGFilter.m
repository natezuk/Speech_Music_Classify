% Load the EEG file and filter

% Paths to add
addpath('~/eeglab14_0_0b/plugins/Biosig3.1.0/biosig/t250_ArtifactPreProcessingQualityControl/');
addpath('~/eeglab14_0_0b/plugins/Biosig3.1.0/biosig/t200_FileAccess/');
% addpath('~/gammatonegram/');
% addpath('C:\Users\nzuk\Projects\Speech_Music_Classify\analysis\');
addpath('~/FastICA_25/');

clear ARTFCT INTRPCH

nchan = 128;
mastoidchans = [135 136];

% Load a bdf file and filster it

eegpth = '/scratch/nzuk/SpeechMusicClassify/';
eegfnm = 'pilotHGWLOI.bdf';

disp('Loading EEG...');
% [fulleeg,fulltrigs,eFs] = sopen([eegpth eegfnm]);
% Using sopen now because readbdf is outdated
hdr = sopen([eegpth eegfnm]);
[fulleeg,hdr] = sread(hdr);
% Make fulltrig
fulltrigs = zeros(size(fulleeg,1),1);
POS = hdr.BDF.Trigger.POS;
TYP = hdr.BDF.Trigger.TYP;
trigadj = sum(2.^(0:15).*[0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1]);
TYP = TYP-trigadj; % adjust trigger values because some parallel port bits are constantly set to 1
for ii = 1:length(TYP)-1,
    if TYP(ii)>0, fulltrigs(POS(ii):POS(ii+1)-1)=TYP(ii); end
end
eFs = hdr.SPR; % sampling rate
sclose(hdr);

% Remove average of mastoid references
disp('Removing the mastoid reference...');
mastref = mean(fulleeg(:,mastoidchans),2);
fulleeg = fulleeg(:,1:nchan)-(mastref*ones(1,nchan));
% fulleeg = fulleeg(:,1:128);

% Remove a linear trend in the eeg signal (DC drift)
fulleeg = detrend(fulleeg);

% Filter the eeg between 1 Hz and 45 Hz (see Teoh thesis)
disp('Filtering EEG...');
fulleeg = prefiltereeg(fulleeg,eFs); % already edited with appropriate parameters
fulleeg = rmfltartifact(fulleeg,eFs);

% Splice the signal
disp('Splicing the EEG signal...');
stimcodes = 1:40;
[EEG,trig,stim] = splicebdf(fulleeg,fulltrigs,stimcodes,256,eFs);

% Show the variance of the eeg
v = var(fulleeg);
% EEG{1} = fulleeg;
clear fulleeg