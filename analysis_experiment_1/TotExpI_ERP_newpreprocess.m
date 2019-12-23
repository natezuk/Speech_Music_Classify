% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
% Nate Zuk (2019)

addpath('~/Documents/Matlab/shadedErrorBar/');
addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));

% Load the stimulus labels
stimtypelbl;
types = unique(typelbl);

ntm = 256;
nchan = 128;
nstims = length(typelbl);

% Load classification rankings for each subject
erps = NaN(ntm,nchan,nstims,6); % classification accuracies
M = NaN(6,1);
ST = NaN(6,1);
av_gfp = NaN(nstims,6);
rnk_gfp = NaN(nstims,6);
sbjs = cell(6,1);
resdir = '/Volumes/ZStore/NaturalSounds/SbjResults/erps_exp1/';
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
typenms = {'Environmental','Mechanical','Music','Non-speech vocal','Non-vocal human',...
    'Speech','Animal'};
reptype = repmat(typelbl,[1 6]);
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
%     sterp = squeeze(std(ERPS(:,:,typechk),[],2));
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

% % All mean ERPs for all stimuli
% figure
% hold on
% cmap = colormap('jet');
% av_erp_plt = NaN(length(typenms),1);
% for ii = 1:length(typenms),
%     clr_idx = floor((ii-1)/length(typenms)*64)+1;
%     typechk = typelbl==ii; % identify stimuli that are of the correct type,
%         % in the listing of classifiction ranking
%     % plot all bars, but set the bars that aren't the correct stimuli to 0
%     merp = mean(erps(:,:,typechk,:),2);
%     plt = plot(tm,squeeze(mean(merp,4)),'LineWidth',1.5,'Color',cmap(clr_idx,:));
%     av_erp_plt(ii) = plt(1); % get the handle for the main line
% end
% set(gcf,'Position',[180 370 615 310]);
% set(gca,'FontSize',16);
% xlabel('Time (s)');
% ylabel('ERP averaged across channels');
% legend(av_erp_plt,typenms);
% 
% % All GFPs for all stimuli
% figure
% hold on
% cmap = colormap('jet');
% av_erp_plt = NaN(length(typenms),1);
% for ii = 1:length(typenms),
%     clr_idx = floor((ii-1)/length(typenms)*64)+1;
%     typechk = typelbl==ii; % identify stimuli that are of the correct type,
%         % in the listing of classifiction ranking
%     % plot all bars, but set the bars that aren't the correct stimuli to 0
%     sterp = std(erps(:,:,typechk,:),[],2);
%     plt = plot(tm,squeeze(mean(sterp,4)),'LineWidth',1.5,'Color',cmap(clr_idx,:));
%     av_erp_plt(ii) = plt(1); % get the handle for the main line
% end
% set(gcf,'Position',[180 370 615 310]);
% set(gca,'FontSize',16);
% xlabel('Time (s)');
% ylabel('ERP averaged across channels');
% legend(av_erp_plt,typenms);

% Determine if there is a significant difference in stimuli when ranked by
% average GFP
RNK = reshape(rnk_gfp,[numel(reptype) 1]);
[pkw,tbl,stats] = kruskalwallis(RNK,reptype);
set(gca,'XTickLabel',typenms,'XTickLabelRotation',45);
% [pMW,MW] = mannwhitneycmp(RNK,reptype);
figure
cmp = multcompare(stats,'ctype','dunn-sidak');
% Plot rankings as individual dots
dot_median_plot(reptype,RNK);
set(gcf,'Position',[600 275 750 420]);
set(gca,'XTickLabel',typenms,'XTickLabelRotation',45,'FontSize',16);
ylabel('Global field power ranking');