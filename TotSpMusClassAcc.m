% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
addpath('C:\Users\nzuk\Projects\ITDSweep\PsychPhys_fullresults\Analysis\');
stimtype = '_S';
nstim = 24;

% Load classification rankings for each subject
% nstims = length(typelbl); % number of stimuli
% acc = NaN(nstims,6); % classification accuracies
% mrnk = NaN(nstims,6); % classification rankings
% sbjs = cell(6,1);
resdir = 'C:\Users\nzuk\Data\TeohSpMusClass\';
fls = what(resdir);
mats = fls.mat; % subject results
mrnk = NaN(nstim,6);
sbjcnt = 1; % counter for each subject
for m = 1:length(mats)
    if strcmp(mats{m}(1:14),'SpMusClassLDA_') && strcmp(mats{m}(end-5:end),[stimtype '.mat']) % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(14:end); % get the subject tag
        conf = mean(r.conf,3); % average the confusion matrix across iterations
        acc = diag(conf); % get the classification accuracy for each stimulus
        [~,idx] = sort(acc); % sort accuracies
        rnk = 1:length(acc); % assign ranks for each stimulus
        mrnk(idx,sbjcnt) = rnk; % save the rank for each stimulus
        stims = r.usestims;
        disp(mats{m});
        sbjcnt = sbjcnt+1; % increase subject counter
    end
end

% Run a kruskal wallis test, significant differences between stimulus
% types?
[pkw,tbl,stats] = kruskalwallis(mrnk');
set(gca,'XTickLabel',stims,'XTickLabelRotation',45);
figure
cmp = multcompare(stats);