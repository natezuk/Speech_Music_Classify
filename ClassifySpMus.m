% Load the subject data for EEG responses to various times of sounds (ET
% experiment), and create a classifier to classify each of the different
% types of sounds
% (NZ, 4/12/2018)

eegpth = 'A:\TeohSpMus\SpMusDiscrim\'; % contains Teoh's eeg data
sbj = 'SN'; % subject name
vexpthres = 95;
niter = 200;
eFs = 128;

disp('Loading eeg data...');
[eegs,stims] = loadspmusdata(eegpth,sbj);

disp('Filtering out data...');
stimtype = 'M-'; % specify only music stimuli
usetype = cellfun(@(x) strcmp(x(1:2),stimtype),stims); % identify stimuli with the stimtype prefix
unqstims = checkidentsource(stims); % identify stimuli from sources that aren't present in other stimuli
useeegs = eegs(:,:,:,usetype&unqstims); % only take stimuli with stimtype from unique sources
usestims = stims(usetype&unqstims);
disp([num2str(sum(usetype&unqstims)) ' stimuli included']);

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(useeegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
rshpeeg = reshape(useeegs,[ntm*nchan ntr*nstims]);
lbl = repelem(1:nstims,ntr);

% Do multi-class LDA
[conf,cf,sc,maxpc] = stimclasslda(rshpeeg,lbl,'vexpthres',vexpthres,'niter',niter);

mconf = mean(conf,3); % average confusion matrix across iterations
figure
imagesc(mconf');
colorbar
set(gca,'XTick',1:length(usestims),'XTickLabel',usestims,'YTick',1:length(usestims),'YTickLabel',usestims,...
    'TickLabelInterpreter','none','XTickLabelRotation',90.0);
title(sbj,'Interpreter','none');
xlabel('Actual');
ylabel('Predicted');

% % Compute the average EEG waveform for each stimulus type
% pceeg = rshpeeg'*cf(:,1:maxpc);
% stimmeeg = NaN(ntm,nchan,length(stims));
% for s = 1:length(stims),
%     spc = mean(pceeg(lbl==s,:),1); % compute the average PC waveforms across trials for the stimulus
%     seeg = spc*cf(:,1:maxpc)'; % transform back into EEG signal
%     stimmeeg(:,:,s) = reshape(seeg,[ntm nchan]); % reshape back into time x channel
% end

% Save the results
disp('Saving results...');
respth = 'C:\Users\nzuk\Data\TeohSpMusClass\';
resfl = sprintf('SpMusClassLDA_%s_%s',sbj,stimtype(1));
save([respth resfl],'conf','sc','maxpc','lbl','usestims','vexpthres','niter');