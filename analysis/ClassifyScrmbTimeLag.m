% Load the subject data for EEG responses to various times of sounds, 
% and create a classifier to classify each of the different
% types of sounds. This is done iteratively for various time lags, in order
% to identify which time lags produce the largest classification
% accuracies.
% (NZ, 4/12/2018)
addpath('~/Projects/Speech_Music_Classify/');

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

fullt = 0:1/eFs:2-1/eFs; % time array for EEG responses
t_iter = 0:tstep/1000:2-trange/1000; % get the time steps for each iteration
t_iter_idx = round(t_iter*eFs); % convert to index values
idx_range = round(trange/1000*eFs); % range of times to include, in indexes
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
lbl = repelem(1:nstims,ntr);
scrmblbls;
types = unique(typelbl);

mn_conf = NaN(nstims,nstims,length(t_iter));
corr = cell(length(t_iter),1);
cf = cell(length(t_iter),1);
% sc = cell(length(t_iter),1);
maxpc = cell(length(t_iter),1);
mu = cell(length(t_iter),1);
for n = 1:length(t_iter),
    fprintf('** Iteration %d/%d\n',n,length(t_iter));
    % Get a segment of the eeg within the time range
    tidx = t_iter_idx(n)+(1:idx_range);
    segeeg = eegs(tidx,:,:,:);
    
    % Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
    % analysis
    disp('Reshaping the eeg array...');
    rshpeeg = reshape(segeeg,[length(tidx)*nchan ntr*nstims]);

    % Do multi-class LDA
    [conf,cf{n},~,maxpc{n},mu{n}] = stimclasslda(rshpeeg,lbl,'vexpthres',vexpthres);
    mn_conf(:,:,n) = mean(conf,3);
    corr{n} = diag(mn_conf(:,:,n)); % proportion correct classification
end
corr = cell2mat(corr'); % convert corr to matrix

% Sort the stimulus types
[srttype,idx] = sort(typelbl);

% meancorr = NaN(length(t_iter),6);
% stdcorr = NaN(length(t_iter),6);
% for ii = 1:6, % go through each time of stimulus
%     meancorr(:,ii) = cellfun(@(x) mean(x(srttype==ii)),corr); % get the average correct response rate
%     stdcorr(:,ii) = cellfun(@(x) std(x(srttype==ii)),corr); % get the standard deviation across responses
% end
% figure
% errorbar(t_iter'*ones(1,6),meancorr,stdcorr);
lbls = {'music','speech','impact','synth music','synth speech','synth impact'};
figure
hold on
cmap = colormap('jet');
tmacc_plt = NaN(6,1);
for ii = 1:6,
    clr_idx = floor((ii-1)/6*64)+1; % index for color plotting
    plt_handles = plot(t_iter,corr(srttype==ii,:),'Color',cmap(clr_idx,:));
    tmacc_plt(ii) = plt_handles(1);
end
xlabel('Time (s)');
ylabel('Average proportion correct');
legend(tmacc_plt,lbls);

% Save the results
disp('Saving results...');
respth = '/Volumes/ZStore/SpeechMusicClassify/timelag/';
resfl = sprintf('StimClassLDA_timelag_%s',sbj);
save([respth resfl],'mn_conf','maxpc','mu','lbl','vexpthres','t_iter','trange');