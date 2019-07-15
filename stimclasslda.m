function [conf,cf,sc,pcind,mu] = stimclasslda(eegdata,lbl,varargin)
% Perform PCA to reduce the dimensionality of the data, then run
% multi-class LDA.
% Inputs:
% - eegdata = eeg data, timeXchannel by trialsXstims. If any columns of
% eegdata are NaN, they are removed.
% - lbl = labels for each of the trials, to identify class (stimulus labels)
% Outputs:
% - conf = confusion matrix: proportion of class identifications (columns) given the actual
% classes (rows). The third dimension is for each repetition
% - cf = transformation matrix calculated by PCA
% - sc = score matrix calculated by PCA
% - pcind = maximum PC to include in the classifier

% Initial variables
niter = 100; % number of times to repeat classification and prediction
vexpthres = 95; % retain PCA components that explain the data variance up to this threshold (in percent)
dopca = true; % flag whether or not to do PCA

% Parse varargin
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Check if any columns of eegdata are NaN, and remove them
nancols = find(sum(isnan(eegdata))>0);
usecols = setxor(1:size(eegdata,2),nancols);
eegdata = eegdata(:,usecols);
lbl = lbl(usecols);
if ~isempty(nancols)
    strrmvcols = sprintf('%d, ',nancols);
    warning(['Removed columns with NaNs: ' strrmvcols]);
end

if dopca,
    disp('Doing PCA...');
    pcatm = tic;
    [cf,sc,~,~,vexp] = pca(eegdata');
    if vexpthres==100,
        pcind = length(vexp); % use all components if vexpthres==100%
    else
        pcind = find(cumsum(vexp)>=vexpthres,1,'first');
    end
    fprintf('%d dimensions retained\n',pcind);
    disp(['PCA completed @ ' num2str(toc(pcatm)) ' s']);
else
    sc = eegdata';
    pcind = size(eegdata,1);
    cf = NaN;
end

nclass = length(unique(lbl)); % number of classes
ntrn = round(0.75*length(lbl)); % number of trials to include for training
conf = NaN(nclass,nclass,niter); % to store number of % correct responses
mu = NaN(nclass,pcind,niter);
% Do multi-class LDA
ldatm = tic;
for n = 1:niter
    if mod(n,10)==0, fprintf('Iteration %d: %.3f s elapsed\n',n,toc(ldatm)); end % show the iteration number every 10 iterations
    trialinds = randperm(length(lbl)); % randomly rearrange trials
    trninds = trialinds(1:ntrn); tstinds = trialinds(ntrn+1:end); % get training and testing trials
    mdl = fitcdiscr(sc(trninds,1:pcind),lbl(trninds)); % create the model
    mu(:,:,n) = mdl.Mu;
    prd = predict(mdl,sc(tstinds,1:pcind)); % compute the prediction for testing trials
    tstlbl = lbl(tstinds)'; % get testing labels;
    % Compute the confusion matrix
    for ii = 1:nclass % actual
        for jj = 1:nclass % prediction
            conf(ii,jj,n) = sum(tstlbl==ii&prd==jj)/sum(tstlbl==ii);
        end
    end
end