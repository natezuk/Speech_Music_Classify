% Load the subject data for EEG responses to various times of sounds (ET
% experiment), and create a classifier to classify each of the different
% types of sounds
% (NZ, 4/12/2018)

eegpth = 'A:\TeohSpMus\Preprocessed\'; % contains Teoh's eeg data
sbj = 'SN_1_45'; % subject name
vexpthres = 95;
eFs = 128;
% maxdur = 1; % maximum duration (in s)

disp('Loading eeg data...');
[eegs,stims] = loadstimclassdata(eegpth,sbj);
% Reduce the eeg duration
% eegs = eegs(1:maxdur*eFs,:,:,:);

% Reshape the eegs into timeXchannels by trialsXstimuli for PCA and MDS
% analysis
disp('Reshaping the eeg array...');
dims = size(eegs);
ntm = dims(1); nchan = dims(2); ntr = dims(3); nstims = dims(4);
rshpeeg = reshape(eegs,[ntm*nchan ntr*nstims]);
lbl = repelem(1:nstims,ntr);
stimtypelbl;
% lbl = repelem(typelbl,ntr);
types = unique(typelbl);

% disp('Doing PCA...');
% [cf,sc,lat,tsq,vexp] = pca(rshpeeg');
% clear rshpeeg
% 
% % Plot the first two principal components
% figure
% hold on
% cmap = colormap('jet');
% for s = 1:nstims,
%     clrind = round(((s-1)/nstims)*size(cmap,1))+1; % get index for particular color
%     plot(sc(lbl==s,1),sc(lbl==s,2),'.','Color',cmap(clrind,:),'MarkerSize',10);
% end
% xlabel('1st PC');
% ylabel('2nd PC');

% disp('Doing MDS...');
% usetrs = setxor(1:ntr*nstims,302); % remove 302 because it is all NaN values
% rshpeeg = rshpeeg(:,usetrs);
% lbl = lbl(usetrs);
% D = pdist(rshpeeg'); % compute Euclidian distances
% Z = squareform(D);
% [Y,stress,dissim] = mdscale(Z,2,'Start','random'); % MDS in 2 dimensions
% 
% % Plot the first two principal components
% ntypes = length(types);
% figure
% hold on
% cmap = colormap('jet');
% for s = 1:ntypes,
%     clrind = round(((s-1)/ntypes)*size(cmap,1))+1; % get index for particular color
%     plot(Y(lbl==typelbl(s),1),Y(lbl==typelbl(s),2),'.','Color',cmap(clrind,:),'MarkerSize',10);
% end
% xlabel('1st dimension');
% ylabel('2nd dimension');

% disp('Do multi-class LDA...');
% % Find the number of PCs that explain 95% of the variance
% pcind = find(cumsum(vexp)>95,1,'first');
% niter = 100; % number of times to repeat classification and prediction
% ntrn = round(0.75*length(lbl)); % number of trials to include for training
% conf = NaN(length(stims),length(stims),niter); % to store number of % correct responses
% % Do multi-class LDA
% for n = 1:niter,
%     trialinds = randperm(length(lbl)); % randomly rearrange trials
%     trninds = trialinds(1:ntrn); tstinds = trialinds(ntrn+1:end); % get training and testing trials
%     mdl = fitcdiscr(sc(trninds,1:pcind),lbl(trninds)); % create the model
%     prd = predict(mdl,sc(tstinds,1:pcind)); % compute the prediction for testing trials
%     tstlbl = lbl(tstinds); % get testing labels;
%     % Compute the confusion matrix
%     for ii = 1:length(stims), % actual
%         for jj = 1:length(stims), % prediction
%             tstlbl = lbl(tstinds)';
%             conf(ii,jj,n) = sum(tstlbl==ii&prd==jj)/sum(tstlbl==ii);
%         end
%     end
% end

% Do multi-class LDA
[conf,cf,sc,maxpc,mu] = stimclasslda(rshpeeg,lbl,'vexpthres',vexpthres);

% Sort the stimulus types
[srttype,idx] = sort(typelbl);

mconf = mean(conf,3); % average confusion matrix across iterations
figure
imagesc(mconf(idx,idx)');
colorbar
set(gca,'XTick',1:30,'XTickLabel',stims(idx),'YTick',1:30,'YTickLabel',stims(idx),...
    'TickLabelInterpreter','none','XTickLabelRotation',90.0);
title(sbj,'Interpreter','none');
xlabel('Actual');
ylabel('Predicted');

% Track classification accuracy as a function of delay
% tm = (0:ntm-1)/eFs;
% dlyidx = 1:1:length(tm)/2;
% % dlystep = tm(dlyidx); % step every 62.5 ms
% dlyconf = NaN(size(conf,1),size(conf,2),length(dlystep)-1); % to store confusion matrices each step
% dlyacc = NaN(length(stims),length(dlystep)-1);
% for t = 1:length(dlyidx)-1,
%     disp([num2str(tm(dlyidx(t))) ' s']);
%     useidx = dlyidx(t):dlyidx(t+1)-1; % select time points to use
%     dlyeeg = reshape(eegs(useidx,:,:,:),[length(useidx)*nchan ntr*nstims]);
%     c = stimclasslda(dlyeeg,lbl,'vexpthres',vexpthres); % compute classification performance
%     dlyconf(:,:,t) = mean(c,3); % store the confusion matrix
%     dlyacc(:,t) = diag(dlyconf(:,:,t));
% end
% 
% dlytype = NaN(length(types),length(dlystep)-1);
% for ii = 1:length(types),
%     dlytype(ii,:) = median(dlyacc(typelbl==ii,:),1);
% end

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
respth = 'C:\Users\nzuk\Data\TeohStimClass\SbjResults\';
resfl = sprintf('StimClassLDA_%s',sbj);
save([respth resfl],'conf','sc','maxpc','mu','lbl','vexpthres');