% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
addpath('~/Projects/Speech_Music_Classify/');

nsbj = 15;
fl_prefix = 'StimClassLDA_';

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
ntr = NaN(nsbj,1);
ndim = NaN(nsbj,1); % number of dimensions retained
acc = NaN(nstims,nsbj); % classification accuracies
mrnk = NaN(nstims,nsbj); % classification rankings
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/';
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
        ntr(m) = length(r.lbl);
        disp(mats{m});
        sbj_idx = sbj_idx + 1;
    end
end

% Compute the 95% confidence threshold for correct classification
ComputeTwoBack; % compute the two-back stimuli in order to determine how many trials were left out
ntargets = sum(sum(tag_cliprep));
ntest = round((ntr-ntargets)/4);
thres = binoinv(0.95,ntest,1/nstims)./ntest;
pass = acc>(ones(nstims,1)*thres'); % identify accuracies above this threshold

% Run a kruskal wallis test, significant differences between stimulus
% types?
typenms = {'Music','Speech','Impact','Scrambled Music','Scrambled Speech','Scrambled Impact'};
reptype = repmat(typelbl,[1 nsbj]);
reptype = reshape(reptype,[numel(reptype) 1]);
RNK = reshape(mrnk,[numel(reptype) 1]);
[pkw,tbl,stats] = kruskalwallis(RNK,reptype);
set(gca,'XTickLabel',typenms,'XTickLabelRotation',45);
ylabel('Average classification accuracy ranking');
% [pMW,MW] = mannwhitneycmp(RNK,reptype);
figure
cmp = multcompare(stats);

% Use a dot-median plot to show the classification ranks
newlbl = NaN(length(typelbl),1); % use a new labeling that puts original next to scrambled
newlblvals = [1 3 5 2 4 6];
for ii = 1:length(typenms),
    typeidx = typelbl==ii;
    newlbl(typeidx) = newlblvals(ii);
end
% dot_median_plot(newlbl,mrnk);
dot_median_plot(repmat(newlbl,[nsbj 1]),RNK);
[~,newnmidx] = sort(newlblvals);
set(gca,'XTickLabel',typenms(newnmidx),'XTickLabelRotation',45);
ylabel('Classification ranking');

% Determine if the rankings for speech are significantly reduced in the
% scrambled version
prs = NaN(3,1);
strs = cell(3,1);
for ii = 1:3,
    [prs(ii),~,strs{ii}] = ranksum(RNK(reptype==ii),RNK(reptype==ii+3));
end