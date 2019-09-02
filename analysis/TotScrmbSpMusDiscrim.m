% Rank the classification accuracies for each subject and determine if
% there is a significant difference between speech and music
% Nate Zuk (2019)

addpath('~/Projects/Speech_Music_Classify/');

nsbj = 15;
fl_prefix = 'SpMusDiscrim_';
stim_sets = {'Music','Speech'}; % stimulus groups to classify
stim_lbl = [1 2];

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);
use_idx = find(types==stim_lbl(1)|types==stim_lbl(2));

% Load classification rankings for each subject
nstims = length(stim_lbl); % number of stimuli
% ntr = NaN(nsbj,1);
ntst = NaN(nsbj,1);
ndim = NaN(nsbj,1); % number of dimensions retained
acc = NaN(nstims,nsbj); % classification accuracies
mrnk = NaN(nstims,nsbj); % classification rankings
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/spmusdiscrim_expII/';
fls = what(resdir);
mats = fls.mat; % subject results
sbj_idx = 1; % index to store the subject results
for m = 1:length(mats)
    maxlen = min([length(fl_prefix) length(mats{m})]);
    if strcmp(mats{m}(1:maxlen),fl_prefix) % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        ndim(m) = r.maxpc;
        sbjs{sbj_idx} = mats{m}(length(fl_prefix)+1:end); % get the subject tag
        conf = mean(r.conf,3); % average the confusion matrix across iterations
        acc(:,m) = diag(conf); % get the classification accuracy for each stimulus
        [~,idx] = sort(acc(:,m)); % sort accuracies
        rnk = 1:length(acc(:,m)); % assign ranks for each stimulus
        mrnk(idx,sbj_idx) = rnk; % save the rank for each stimulus
%         ntr(m) = length(r.lbl);
        ntst(m) = median(r.ntst);
        disp(mats{m});
        sbj_idx = sbj_idx + 1;
    end
end

% Compute the 95% confidence threshold for correct classification
ComputeTwoBack; % compute the two-back stimuli in order to determine how many trials were left out
use_cliprep = tag_cliprep(use_idx,1);
ntargets = sum(sum(tag_cliprep));
thres = binoinv(0.95,ntst,0.5)./ntst;
pass = acc>(ones(nstims,1)*thres'); % identify accuracies above this threshold
