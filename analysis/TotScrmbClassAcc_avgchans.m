% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
nsbj = 7;

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
acc = NaN(nstims,nsbj); % classification accuracies
mrnk = NaN(nstims,nsbj); % classification rankings
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/avgchans/';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:18),'StimClassAvgChans_') % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(14:end); % get the subject tag
        conf = mean(r.conf,3); % average the confusion matrix across iterations
        acc = diag(conf); % get the classification accuracy for each stimulus
        [~,idx] = sort(acc); % sort accuracies
        rnk = 1:length(acc); % assign ranks for each stimulus
        mrnk(idx,m) = rnk; % save the rank for each stimulus
        disp(mats{m});
    end
end

% Run a kruskal wallis test, significant differences between stimulus
% types?
typenms = {'Music','Speech','Onset','Synth Music','Synth Speech','Synth Onset'};
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
dot_median_plot(newlbl,mrnk);
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