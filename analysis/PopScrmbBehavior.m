% Examine population behavioral responses for the Speech-Music
% classification experiment (experiment II)
% Nate Zuk (2019)

addpath('~/Documents/Matlab/fdr_bh/');

res_fld = '~/Projects/Speech_Music_Classify/behavior_results/';
res_fls = what(res_fld);
mats = res_fls.mat;

all_prop_corr = NaN(6,length(mats));
all_prop_FA = NaN(6,length(mats));
all_pc = NaN(length(mats),1);
for m = 1:length(mats),
    S = load([res_fld mats{m}]);
    % proportion correct for each stimulus type
    all_prop_corr(:,m) = S.prop_type_corr;
    % false alarm rate for each stimulus type
    all_prop_FA(:,m) = S.prop_type_FA;
    % overall correct detection rate
    all_pc(m) = S.prop_corr;
    disp(mats{m})
end

% Compute chance performance (assumes subject randomly selects the correct
% number of targets across all trials)
targets = S.clip_targets;
tot_targets = sum(sum(S.clip_targets));
all_stims = 58*size(targets,2); % 58 possible places to click, 40 trials overall
chance_rate = tot_targets/all_stims;

% Plot as dot-median
typenms = {'Music','Speech','Impact','Synth Music','Synth Speech','Synth Impact'};
reptype = repmat((1:6)',[1,length(mats)]);
TYPE = reshape(reptype,[6*length(mats) 1]);
ALL_CORR = reshape(all_prop_corr,[6*length(mats) 1]);
ALL_FA = reshape(all_prop_FA,[6*length(mats) 1]);
dot_median_plot(TYPE,ALL_CORR);
hold on
plot([1 6],[median(ALL_FA) median(ALL_FA)],'r','LineWidth',2);
plot([1 6],[chance_rate chance_rate],'k--','LineWidth',2);
set(gca,'FontSize',16,'XTickLabel',typenms,'XTickLabelRotation',45);
ylabel('Correct detection rate');

% Is there a significant difference in hit rates across stimulus types?
[pkw,~,stkw] = kruskalwallis(ALL_CORR,TYPE,'off');
[pmw,mw,cond] = mannwhitneycmp(ALL_CORR,TYPE);
h = fdr_bh(pmw,0.05);
fprintf('Variation across hit rates, kruskal wallis: p = %.3f\n',pkw);
% Is there a significant difference across false alarm rates?
[pfa,~,stfa] = kruskalwallis(ALL_FA,TYPE,'off');
fprintf('Variation across false alarm rates, kruskal wallis: p = %.3f\n',pfa);

% Compare originals to model-matched
p_cmp = NaN(3,1);
st_cmp = cell(3,1);
for n = 1:3,
    [p_cmp(n),~,st_cmp{n}] = ranksum(ALL_CORR(TYPE==n),ALL_CORR(TYPE==n+3));
end