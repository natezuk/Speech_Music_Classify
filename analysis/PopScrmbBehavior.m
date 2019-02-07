% Examine population behavioral responses for the Speech-Music
% classification experiment

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