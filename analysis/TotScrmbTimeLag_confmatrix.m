% Examine how the confusion matrices change as a function of time, and plot
% the classification accuracy for each stimulus type as a function of time
addpath('~/Documents/MATLAB/shadedErrorBar/');
addpath('~/Documents/MATLAB/fdr_bh/');
addpath('~/Documents/MATLAB/MCP/');

nsbj = 15;
fl_prefix = 'StimClassLDA_timelag_';
nperm = 1000;

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

ntm = 19; % number of time indexes

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
acc = NaN(nstims,ntm,nsbj); % classification accuracies
ndim = NaN(ntm,nsbj);
conf = NaN(nstims,nstims,ntm,nsbj); % confusion matrices
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/timelag/';
fls = what(resdir);
mats = fls.mat; % subject results
sbj_idx = 1; % index to store the subject results
for m = 1:length(mats)
    maxlen = min([length(fl_prefix) length(mats{m})]);
    if strcmp(mats{m}(1:maxlen),fl_prefix) % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        ndim(:,m) = cell2mat(r.maxpc);
        sbjs{sbj_idx} = mats{m}(length(fl_prefix)+1:end); % get the subject tag
        conf(:,:,:,sbj_idx) = r.mn_conf; % get the confusion matrix as a function of time
        for n = 1:ntm, % for each time point,
            acc(:,n,sbj_idx) = diag(conf(:,:,n,sbj_idx)); % get the classification accuracies for the stimuli
        end
        disp(mats{m});
        sbj_idx = sbj_idx + 1;
    end
end

% Get the time array 
t_iter = r.t_iter;
trange = r.trange;

% Show the distribution of all accuracies, averaged across subjects
C = mean(conf,4);
Carray = reshape(C,[numel(C) 1]);
bins = 0:0.005:max(Carray)+0.005;
h = histcounts(Carray,bins);
% plot the distribution
figure
cnts = bins(1:end-1)+diff(bins)/2;
bar(cnts,h,1,'k');
xlabel('Classification accuracy');
ylabel('# predicted-actual pairs');

% Plot the confusion matrices for select time points
tidx_use = 1:2:length(t_iter);
t_select = t_iter(tidx_use); % use every other time point
figure
for ii = 1:length(t_select),
    subplot(2,ceil(length(t_select)/2),ii);
    % plot the confusion matrix for that time range
    imagesc(mean(conf(:,:,tidx_use(ii),:),4));
    cmap = colormap('gray');
    colormap(flipud(cmap));
    caxis([0 0.1]); % set to a value that shows the effect of the diagonal, without being scaled by outliers
    tle = sprintf('%d - %d ms',round(t_select(ii)*1000),round(t_select(ii)*1000)+trange);
    axis('square');
    title(tle);
    xlabel('Actual');
    ylabel('Predicted');
end
colorbar;

typenms = {'Music','Speech','Impact','Synth Music','Synth Speech','Synth Impact'};
acc = permute(acc,[2,1,3]);
allsbj_acc = reshape(acc,size(acc,1),size(acc,2)*size(acc,3));
% allsbj_acc = reshape(z_acc,size(z_acc,1),size(z_acc,2)*size(z_acc,3));

replbl = repmat(typelbl,nsbj,1); % repeat stimulus labels across all subjects
    % to appropriately label the stimuli in allsbj_acc
    
% Plot the median accuracy for the original speech and music as a function of time, and
% compare to the median accuracy for synth music & synth speech across all
% time
figure
hold on
clrs = {'b','r'};
plt_leg = NaN(2,1);
pval = NaN(length(t_iter),2);
stats_rs = cell(length(t_iter),2);
zval = NaN(length(t_iter),2);
permzval = NaN(nperm,length(t_iter),2);
for ii = 1:2,
    md_acc = median(allsbj_acc(:,replbl==ii),2);
    uq_acc = quantile(allsbj_acc(:,replbl==ii),0.75,2);
    lq_acc = quantile(allsbj_acc(:,replbl==ii),0.25,2);
    plt = shadedErrorBar(t_iter*1000+trange/2,md_acc,[uq_acc-md_acc, md_acc-lq_acc]',...
         'lineprops',{'-','Color',clrs{ii},'LineWidth',2});
    plt_leg(ii) = plt.mainLine;
%     plt_leg(ii) = plot(t_iter*1000+trange/2,md_acc,clrs{ii},'LineWidth',2);
    % plot the averaged synth accuracy
    SYNTHall = reshape(allsbj_acc(:,replbl==ii+3),[nsbj*5*ntm 1]);
    synth_acc = median(SYNTHall);
    synth_uq = quantile(SYNTHall,0.75);
    synth_lq = quantile(SYNTHall,0.25);
%     shadedErrorBar(t_iter([1 end])*1000+trange/2,synth_acc*ones(1,2),[synth_uq-synth_acc; synth_acc-synth_lq]*ones(1,2),...
%          'lineprops',{'--','Color',clrs{ii}});
%     plot(t_iter([1 end])*1000+trange/2,synth_acc*ones(1,2),'--','Color',clrs{ii});
    errorbar(t_iter([1 end])*1000+trange/2,synth_acc*ones(1,2),(synth_uq-synth_acc)*ones(1,2),...
        (synth_acc-synth_lq)*ones(1,2),'--','Color',clrs{ii},'LineWidth',2);
    % is the distribution of accuracies significantly different than the synth
    % distribution?
    for t = 1:length(t_iter),
        orig_acc = allsbj_acc(t,replbl==ii);
        [pval(t,ii),~,stats_rs{t,ii}] = ranksum(orig_acc',SYNTHall);
%         [pval(t,ii),~,stats_rs{t,ii}] = ranksum(allsbj_acc(t,replbl==ii)',allsbj_acc(t,replbl==ii+3)');
        zval(t,ii) = stats_rs{t,ii}.zval;
        combined_acc = [orig_acc'; SYNTHall];
        % randomly permute the reconstruction accuracies
        for n = 1:nperm,
            idx = randperm(length(combined_acc));
            nullvals = combined_acc(idx(1:length(orig_acc)));
            nullcmp = combined_acc(idx(length(orig_acc)+1:end));
            [~,~,stats_perm] = ranksum(nullvals,nullcmp);
            permzval(n,t,ii) = stats_perm.zval;
        end
    end
end
set(gca,'FontSize',16)
xlabel('Time (ms)');
ylabel('Classification accuracy');
legend(plt_leg,typenms(1:2));

[h,pcrit] = fdr_bh(pval,0.001,'dep');

% Compute a permuted distribution of z-values for each 
chanlocs.X = 1;
chanlocs.Y = 1;
chanlocs.Z = 1;
for ii = 1:2,
    [clusters,bSum,clusters_corrected,pCluster]=...
        MCP_clusters(zval(:,ii)',pval(:,ii)',permzval(:,:,ii),chanlocs);
end