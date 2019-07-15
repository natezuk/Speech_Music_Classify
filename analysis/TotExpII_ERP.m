% Rank the classification accuracies for each subject and determine if
% there is a significant difference between stimuli in experiment II
% (original and synthetic)

addpath('~/Documents/Matlab/shadedErrorBar/');

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

ntm = 256;
nchan = 128;
nstims = length(typelbl);
nsbjs = 15;

% Load classification rankings for each subject
erps = NaN(ntm,nchan,nstims,nsbjs); % classification accuracies
M = NaN(nsbjs,1);
ST = NaN(nsbjs,1);
av_gfp = NaN(nstims,nsbjs);
rnk_gfp = NaN(nstims,nsbjs);
sbjs = cell(nsbjs,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/erps_exp2/';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:13),'StimClassERP_') % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(14:end); % get the subject tag
        % zscore the erp, relative to all data points for the subject
        E = reshape(r.erp,[numel(r.erp) 1]);
        M(m) = mean(E);
        ST(m) = std(E);
        erps(:,:,:,m) = (r.erp-M(m))/ST(m);
        tm = r.tm;
        % compute the average global field power for each stimulus, then
        % rank them
        av_gfp(:,m) = squeeze(mean(std(r.erp,[],2),1));
        [~,idx] = sort(av_gfp(:,m)); % sort accuracies
        rnk = 1:nstims; % assign ranks for each stimulus
        rnk_gfp(idx,m) = rnk; % save the rank for each stimulus
        disp(mats{m});
    end
end

% Plot ERPs, averaged across stimulus types
typenms = {'Music','Speech','Impact','Synth Music','Synth Speech','Synth Impact'};
reptype = repmat(typelbl,[1 nsbjs]);
reptype = reshape(reptype,[numel(reptype) 1]);
ERPS = reshape(erps,[ntm nchan nstims*length(sbjs)]);
figure
hold on
cmap = colormap('jet');
av_erp_plt = NaN(length(typenms),1);
for ii = 1:length(typenms),
    clr_idx = floor((ii-1)/length(typenms)*64)+1;
    typechk = reptype==ii; % identify stimuli that are of the correct type,
        % in the listing of classifiction ranking
    % plot all bars, but set the bars that aren't the correct stimuli to 0
    merp = squeeze(mean(ERPS(:,:,typechk),2));
    md_erp = median(merp,2);
    uq_erp = quantile(merp,0.75,2);
    lq_erp = quantile(merp,0.25,2);
%     plt = shadedErrorBar(tm,md_erp,[uq_erp-md_erp md_erp-lq_erp],...
%         'lineProps',{'LineWidth',2,'Color',cmap(clr_idx,:)});
%     av_erp_plt(ii) = plt.mainLine; % get the handle for the main line
    plt = plot(tm,md_erp,'LineWidth',2,'Color',cmap(clr_idx,:));
    av_erp_plt(ii) = plt(1);
end
set(gcf,'Position',[50 300 750 375]);
set(gca,'FontSize',16);
xlabel('Time (s)');
ylabel('ERP averaged across channels');
legend(av_erp_plt,typenms);

% Plot the average RMS over time
figure
hold on
cmap = colormap('jet');
av_gfp_plt = NaN(length(typenms),1);
for ii = 1:length(typenms),
    clr_idx = floor((ii-1)/length(typenms)*64)+1;
    typechk = reptype==ii; % identify stimuli that are of the correct type,
        % in the listing of classifiction ranking
    % plot all bars, but set the bars that aren't the correct stimuli to 0
    sterp = squeeze(std(ERPS(:,:,typechk),[],2));
    md_gfp = median(sterp,2);
    uq_gfp = quantile(sterp,0.75,2);
    lq_gfp = quantile(sterp,0.25,2);
%     plt = shadedErrorBar(tm,md_gfp,[uq_gfp-md_gfp md_gfp-lq_gfp],...
%         'lineProps',{'LineWidth',2,'Color',cmap(clr_idx,:)});
%     av_gfp_plt(ii) = plt.mainLine; % get the handle for the main line
    plt = plot(tm,md_gfp,'LineWidth',2,'Color',cmap(clr_idx,:));
    av_gfp_plt(ii) = plt(1);
end
set(gcf,'Position',[50 300 750 375]);
set(gca,'FontSize',16);
xlabel('Time (s)');
ylabel('Global field power');
legend(av_gfp_plt,typenms);

% Plot the topoplot of the median ERP for all stimuli between 0
t_range = [0.2 0.3];
tseg = tm>=t_range(1)&tm<=t_range(2);
erp_mag_seg = squeeze(median(mean(ERPS(tseg,:,:),1),3));
figure
topoplot(erp_mag_seg,'chanlocs.xyz','style','map','conv','on');
set(gcf,'Position',[360 400 400 300]);
title(sprintf('%d - %d ms',t_range(1)*1000,t_range(2)*1000));
colorbar;

% % Plot the average RMS over time
% figure
% hold on
% cmap = colormap('jet');
% gfpmn_plt = NaN(length(typenms),1);
% for ii = 1:length(typenms),
%     clr_idx = floor((ii-1)/length(typenms)*64)+1;
%     typechk = reptype==ii; % identify stimuli that are of the correct type,
%         % in the listing of classifiction ranking
%     % plot all bars, but set the bars that aren't the correct stimuli to 0
%     mn_gfp = mean(std(ERPS(:,:,typechk),[],2),3);
%     std_gfp = std(std(ERPS(:,:,typechk),[],2),[],3);
%     mn_plt = plot(tm,mn_gfp,'LineWidth',2,'Color',cmap(clr_idx,:));
%     std_plt = plot(tm,std_gfp,'--','LineWidth',2,'Color',cmap(clr_idx,:));
%     gfpmn_plt(ii) = mn_plt;
% end
% xlabel('Time (s)');
% ylabel('Global field power');
% legend(gfpmn_plt,typenms);

% Determine if there is a significant difference in stimuli when ranked by
% average GFP
RNK = reshape(rnk_gfp,[numel(reptype) 1]);
[pkw,tbl,stats] = kruskalwallis(RNK,reptype);
set(gca,'XTickLabel',typenms,'XTickLabelRotation',45);
% [pMW,MW] = mannwhitneycmp(RNK,reptype);
figure
cmp = multcompare(stats);
% Plot rankings as individual dots
newlbl = NaN(length(reptype),1); % use a new labeling that puts original next to scrambled
newlblvals = [1 3 5 2 4 6];
for ii = 1:length(typenms),
    typeidx = reptype==ii;
    newlbl(typeidx) = newlblvals(ii);
end
dot_median_plot(newlbl,RNK);
[~,newnmidx] = sort(newlblvals);
set(gcf,'Position',[600 275 750 420]);
set(gca,'XTickLabel',typenms(newnmidx),'XTickLabelRotation',45,'FontSize',16);
ylabel('Global field power ranking');

% Determine if the rankings for speech are significantly reduced in the
% scrambled version
prs = NaN(3,1);
strs = cell(3,1);
for ii = 1:3,
    [prs(ii),~,strs{ii}] = ranksum(RNK(reptype==ii),RNK(reptype==ii+3));
end