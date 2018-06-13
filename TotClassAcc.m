% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
addpath('C:\Users\nzuk\Projects\ITDSweep\PsychPhys_fullresults\Analysis\');

% Load the stimulus labels
stimtypelbl;
types = unique(typelbl);

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
acc = NaN(nstims,6); % classification accuracies
mrnk = NaN(nstims,6); % classification rankings
sbjs = cell(6,1);
resdir = 'C:\Users\nzuk\Data\TeohStimClass\SbjResults\';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:13),'StimClassLDA_') % make sure it's the appropriate results file
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
typenms = {'Environmental','Mechanical','Music','Non-speech vocal','Non-vocal human',...
    'Speech','Animal'};
reptype = repmat(typelbl,[1 6]);
reptype = reshape(reptype,[numel(reptype) 1]);
RNK = reshape(mrnk,[numel(reptype) 1]);
[pkw,tbl,stats] = kruskalwallis(RNK,reptype);
set(gca,'XTickLabel',typenms,'XTickLabelRotation',45);
% [pMW,MW] = mannwhitneycmp(RNK,reptype);
figure
cmp = multcompare(stats);