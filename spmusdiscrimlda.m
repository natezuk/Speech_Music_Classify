function [conf,cf,sc,pcind,mu,ntst] = spmusdiscrimlda(eegdata,lbl,stim,varargin)
% Perform PCA to reduce the dimensionality of the data, then run
% multi-class LDA.
% Inputs:
% - eegdata = eeg data, timeXchannel by trialsXstims. If any columns of
% eegdata are NaN, they are removed.
% - lbl = labels for each of the trials, specifying if it's either speech
% or music (there can only be two different values)
% - stim = integers indicating the specific stimulus, which must the be
% same length as lbl
% Outputs:
% - conf = confusion matrix: proportion of class identifications (columns) given the actual
% classes (rows). The third dimension is for each repetition
% - cf = transformation matrix calculated by PCA
% - sc = score matrix calculated by PCA
% - pcind = maximum PC to include in the classifier

% Initial variables
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
stim = stim(usecols);
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

lbl_set = unique(lbl);
nclass = length(lbl_set); % number of classes
% identify which stimulus belongs to which class
[stim_set,idx] = unique(stim);
stim_lbl = lbl(idx);
% nstim = length(stim_set); % number of stimuli
% keep track of which stimuli belong to which class
lbl_idx = cell(2,1);
for ii = 1:length(lbl_set),
    lbl_idx{ii} = find(stim_lbl==lbl_set(ii));
end
niter = length(lbl_idx{1})*length(lbl_idx{2});
conf = NaN(nclass,nclass,niter); % to store number of % correct responses
mu = NaN(nclass,pcind,niter);
ntst = NaN(niter,1); % number of trials used for testing (important for testing significance later)
% Do LDA, leave out a pair of stimuli on each iteration, one of each type,
% and classify which is which (this avoids training and testing on the same
% stimulus type)
ldatm = tic;
for n = 1:niter
    fprintf('Iteration %d: %.3f s elapsed\n',n,toc(ldatm));
    % Identify which stimuli will be used for testing -- step through each
    % stimulus in the first set before each step in the second set
    stimI_idx = mod(n-1,length(lbl_idx{1}))+1; % index of stimulus in the first set
    stimII_idx = floor((n-1)/length(lbl_idx{1}))+1; % index of stimulus in second set
    tst_stim = stim_set([lbl_idx{1}(stimI_idx) lbl_idx{2}(stimII_idx)]);
    tstinds = find(stim==tst_stim(1)|stim==tst_stim(2)); % get the indexes with testing data
    ntst(n) = length(tstinds);
    trninds = setxor(1:length(stim),tstinds); % get the indexes with training data
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