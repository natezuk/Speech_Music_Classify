% Compare the rankings for music with a 2s duration to the rankings for
% music with a 1s duration

% Load the stimulus labels
stimtypelbl;
types = unique(typelbl);
nstims = length(typelbl); % number of stimuli
reptype = repmat(typelbl,[1 6]); % repeat the labels for each subject
    % for labeling the ranks across all subjects
reptype = reshape(reptype,[numel(reptype) 1]);

compare_types = {'music','speech'};
compare_lbls = [3 6]; % labels for these particular stimulus types
compare_clrs = [0 0 0; 1 0 0]; % colors to use for each type

% Load classification rankings for each subject, 2-s duration
disp('** 2-s dur **');
mrnk_2sdur = NaN(nstims,6); % classification rankings
acc_2sdur = NaN(nstims,6);
sbjs = cell(6,1);
resdir = '/Volumes/ZStore/NaturalSounds/SbjResults/';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:13),'StimClassLDA_') % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(14:end); % get the subject tag
        conf = mean(r.conf,3); % average the confusion matrix across iterations
        acc_2sdur(:,m) = diag(conf); % get the classification accuracy for each stimulus
        [~,idx] = sort(acc_2sdur(:,m)); % sort accuracies
        rnk = 1:length(acc_2sdur(:,m)); % assign ranks for each stimulus
        mrnk_2sdur(idx,m) = rnk; % save the rank for each stimulus
        disp(mats{m});
    end
end
% organize the ranks into a single vector
RNK_2sdur = reshape(mrnk_2sdur,[numel(reptype) 1]);
ACC_2sdur = reshape(acc_2sdur,[numel(reptype) 1]);

% Load classification rankings for each subject, 2-s duration
disp('** 1-s dur **');
mrnk_1sdur = NaN(nstims,6); % classification rankings
acc_1sdur = NaN(nstims,6);
npcs = NaN(6,1);
sbjs = cell(6,1);
resdir = '/Volumes/ZStore/NaturalSounds/SbjResults/1sdur/';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:13),'StimClassLDA_') % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(14:end); % get the subject tag
        conf = mean(r.conf,3); % average the confusion matrix across iterations
        acc_1sdur(:,m) = diag(conf); % get the classification accuracy for each stimulus
        [~,idx] = sort(acc_1sdur(:,m)); % sort accuracies
        rnk = 1:length(acc_1sdur(:,m)); % assign ranks for each stimulus
        mrnk_1sdur(idx,m) = rnk; % save the rank for each stimulus
        npcs(m) = r.maxpc;
        disp(mats{m});
    end
end
% organize the ranks into a single vector
RNK_1sdur = reshape(mrnk_1sdur,[numel(reptype) 1]);
ACC_1sdur = reshape(acc_1sdur,[numel(reptype) 1]);

% Do a Wilcoxon rank-sum test to compare the rankings for 2-s to 1-s
% typelbl=3 --> Music
disp('Music:');
[p,~,st] = ranksum(RNK_2sdur(reptype==3),RNK_1sdur(reptype==3));
fprintf('Wilcoxon rank-sum: z = %.3f, p = %.3f\n',st.zval,p);

% typelbl=6 --> Speech
disp('Speech:');
[p,~,st] = ranksum(RNK_2sdur(reptype==6),RNK_1sdur(reptype==6));
fprintf('Wilcoxon rank-sum: z = %.3f, p = %.3f\n',st.zval,p);

disp('Music:');
[p,~,st] = signrank(ACC_2sdur(reptype==compare_lbls(1))-ACC_1sdur(reptype==compare_lbls(1)));
fprintf('Wilcoxon sign-rank: z = %.3f, p = %.3f\n',st.zval,p);

% typelbl=2 --> Speech
disp('Speech:');
[p,~,st] = signrank(ACC_2sdur(reptype==compare_lbls(2))-ACC_1sdur(reptype==compare_lbls(2)));
fprintf('Wilcoxon sign-rank: z = %.3f, p = %.3f\n',st.zval,p);

disp('Is the change in classification accuracy significantly different for speech vs music?');
mus_diff = ACC_2sdur(reptype==compare_lbls(1))-ACC_1sdur(reptype==compare_lbls(1));
sp_diff = ACC_2sdur(reptype==compare_lbls(2))-ACC_1sdur(reptype==compare_lbls(2));
[pdiff,~,stdiff] = ranksum(mus_diff,sp_diff);
fprintf('Wilcoxon rank-sum: z = %.3f, p = %.3f\n',stdiff.zval,pdiff);

% Use a dot-median plot to show the classification ranks
use_stim_idx = reptype==compare_lbls(1)|reptype==compare_lbls(2);
[md_plts,midlines] = dot_median_plot(reptype(use_stim_idx),[RNK_2sdur(use_stim_idx) RNK_1sdur(use_stim_idx)],...
    compare_clrs,'jit_span',0.3,'med_span',0.6,'tot_span',0.8);
set(gca,'XTickLabel',compare_types,'XTickLabelRotation',45);
ylabel('Classification ranking');
legend(md_plts,'2 s duration','1 s duration');

% Plot classification accuracies
[md_plts,~] = dot_median_plot(reptype(use_stim_idx),[ACC_2sdur(use_stim_idx) ACC_1sdur(use_stim_idx)],...
    compare_clrs,'jit_span',0.3,'med_span',0.6,'tot_span',0.8);
set(gca,'XTickLabel',compare_types,'XTickLabelRotation',45);
ylabel('Classification accuracy');
legend(md_plts,'2 s duration','1 s duration');

% Plot and connect the classification accuracies
dot_connect_plot(reptype(use_stim_idx),[ACC_2sdur(use_stim_idx) ACC_1sdur(use_stim_idx)],...
    'jit_span',0,'med_span',0.6,'tot_span',0.8);
set(gcf,'Position',[360 340 450 355]);
set(gca,'XTickLabel',compare_types,'XTickLabelRotation',45);
ylabel('Classification accuracy');
title('2-s to 1-s classification accuracies');