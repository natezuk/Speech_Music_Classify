% Load the subject data for EEG responses to various times of sounds, 
% and create a classifier to classify each of the different
% types of sounds. This is done iteratively for each channel
% (NZ, 16-1-2019)
addpath('~/Projects/Speech_Music_Classify/');
addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

eegpth = '/Volumes/Untitled/SpeechMusicClassify/eegs/'; % contains eeg data
stimpth = '/Volumes/Untitled/SpeechMusicClassify/stims/'; % contains labeling for the sound clips and the stimuli
sbj = 'GQEVXE'; % subject name
vexpthres = 95;
eFs = 128;
trange = 200; % range of times to include in the classifier (in ms)
tstep = 100; % step size between time ranges (in ms)

disp('Loading eeg data...');
[eegs,stims] = loadscrmbclassdata(eegpth,sbj,stimpth);

% Remove target clips
ComputeTwoBack;
for ii = 1:length(stims),
    targettrials = tag_cliprep(ii,:); % find trials where this clip was the target
    rmvidx = false(size(eegs,3),1);
    rmvidx(find(targettrials)*2) = true; % set the target in those trials to true (to remove them)
    eegs(:,:,rmvidx,ii) = NaN;
    fprintf('Removed %d EEG epochs from clip %s\n',sum(rmvidx),stims{ii});
end

dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
lbl = repelem(1:nstims,ntr);
scrmblbls;
types = unique(typelbl);

mn_conf = NaN(nstims,nstims,nchan);
corr = NaN(nstims,nchan);
cf = cell(nchan,1);
% sc = cell(length(t_iter),1);
maxpc = cell(nchan,1);
mu = cell(nchan,1);
for n = 1:nchan,
    fprintf('** Iteration %d/%d\n',n,nchan);
    % Get one channe of EEG
    segeeg = eegs(:,n,:,:);
    
    % Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
    % analysis
    disp('Reshaping the eeg array...');
    rshpeeg = reshape(segeeg,[ntm ntr*nstims]);

    % Do multi-class LDA
    [conf,cf{n},~,maxpc{n},mu{n}] = stimclasslda(rshpeeg,lbl,'vexpthres',vexpthres);
    mn_conf(:,:,n) = mean(conf,3);
    corr(:,n) = diag(mn_conf(:,:,n)); % proportion correct classification
end

% Show the topoplots of classification accuracies for each stimulus type
lbls = {'music','speech','impact','synth music','synth speech','synth impact'};
figure
for ii = 1:6,
    subplot(2,3,ii);
    topoplot(mean(corr(typelbl==ii,:),1),'chanlocs.xyz')
    title(lbls{ii});
    colorbar;
end

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/SpeechMusicClassify/chan/';
resfl = sprintf('StimClassLDA_chan_%s',sbj);
save([respth resfl],'mn_conf','maxpc','mu','lbl','vexpthres');