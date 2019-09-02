% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
% Nate Zuk (2019)

% Load the stimulus labels
stimtypelbl;
types = unique(typelbl);

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
ndim = NaN(6,1);
acc = NaN(nstims,6); % classification accuracies
mrnk = NaN(nstims,6); % classification rankings
ntr = NaN(6,1);
sbjs = cell(6,1);
resdir = '/Volumes/ZStore/TeohStimClass/SbjResults/';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:13),'StimClassLDA_') % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(14:end); % get the subject tag
        conf = mean(r.conf,3); % average the confusion matrix across iterations
        acc(:,m) = diag(conf); % get the classification accuracy for each stimulus
        [~,idx] = sort(acc(:,m)); % sort accuracies
        rnk = 1:length(acc(:,m)); % assign ranks for each stimulus
        mrnk(idx,m) = rnk; % save the rank for each stimulus
        ndim(m) = r.maxpc;
        ntr(m) = length(r.lbl);
        disp(mats{m});
    end
end

% Compute the 95% confidence threshold for correct classification
ntest = round(ntr/4);
thres = binoinv(0.95,ntest,1/nstims)./ntest;
pass = acc>(ones(nstims,1)*thres'); % identify accuracies above this threshold

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
cmp = multcompare(stats,'ctype','dunn-sidak');
% Plot rankings as individual dots
% dot_median_plot(typelbl,mrnk);
dot_median_plot(reptype,RNK);
set(gcf,'Position',[50 300 370 240]);
set(gca,'XTickLabel',typenms,'XTickLabelRotation',45);
ylabel('Classification ranking');

% Get the stimulus names
load('stim_names');
% Plot the average classification accuracy ranking, sorted by rank
[sort_rnk,sortstim_idx] = sort(mean(mrnk,2),'descend');
ordered_idx = 1:length(sort_rnk);
figure
hold on
cmap = colormap('jet');
for ii = 1:length(typenms),
    clr_idx = floor((ii-1)/length(typenms)*64)+1;
    typechk = typelbl(sortstim_idx)==ii; % identify stimuli that are of the correct type,
        % in the listing of classifiction ranking
    % plot all bars, but set the bars that aren't the correct stimuli to 0
    h = zeros(length(sort_rnk),1);
    h(typechk) = sort_rnk(typechk);
    bar(ordered_idx,h,'FaceColor',cmap(clr_idx,:));
end
set(gcf,'Position',[50 300 265 440]);
set(gca,'FontSize',16,'XTick',1:length(sort_rnk),'XTickLabel',stims(sortstim_idx),...
    'XTickLabelRotation',90,'TickLabelInterpreter','none');
ylabel('Average classification ranking');
legend(typenms);