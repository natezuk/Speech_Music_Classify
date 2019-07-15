% Examine the classification accuracy for each channel, and plot using
% topoplot

addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));
addpath('~/Documents/Matlab/fdr_bh');

nsbj = 15;
fl_prefix = 'StimClassLDA_chan_';

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

nchan = 128; % number of time indexes

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
acc = NaN(nstims,nchan,nsbj); % classification accuracies
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/chan/';
fls = what(resdir);
mats = fls.mat; % subject results
sbj_idx = 1; % index to store the subject results
for m = 1:length(mats)
    maxlen = min([length(fl_prefix) length(mats{m})]);
    if strcmp(mats{m}(1:maxlen),fl_prefix) % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{sbj_idx} = mats{m}(length(fl_prefix)+1:end); % get the subject tag
        conf = r.mn_conf; % get the confusion matrix as a function of time
        for n = 1:nchan, % for each time point,
            acc(:,n,sbj_idx) = diag(conf(:,:,n)); % get the classification accuracies for the stimuli
        end
        disp(mats{m});
        sbj_idx = sbj_idx + 1;
    end
end

% Rearrange the accuracies so the channels are along the first dimension
typenms = {'Music','Speech','Impact','Synth Music','Synth Speech','Synth Impact'};
acc = permute(acc,[2,1,3]);
allsbj_acc = reshape(acc,size(acc,1),size(acc,2)*size(acc,3));

replbl = repmat(typelbl,nsbj,1); % repeat stimulus labels across all subjects
    % to appropriately label the stimuli in allsbj_acc

% Compute if the difference in classification accuracy is different for
% original vs synth, channel by channel
pval = NaN(nchan,3);
stat_rs = cell(nchan,3);
for ii = 1:3,
    for n = 1:nchan,
        orig = allsbj_acc(n,replbl==ii);
        synth = allsbj_acc(n,replbl==ii+3);
        [pval(n,ii),stat_rs{n,ii}] = ranksum(orig,synth);
    end
end    
[h001,pcrit] = fdr_bh(pval,0.001,'dep');
    % only one electrode is significant with q = 0.05 for speech (NZ,
    % 18-1-2019)
[h01,~] = fdr_bh(pval,0.01,'dep');
[h05,~] = fdr_bh(pval,0.05,'dep');
    
% Plot a topography of the median accuracy for the original music, speech,
% and impact sounds
figure
for ii = 1:3,
    subplot(1,3,ii);
    md_acc = median(allsbj_acc(:,replbl==ii),2);
    topoplot(md_acc,'chanlocs.xyz','style','map','conv','on');
    title(typenms{ii});
    colormap('jet');
    set(gcf,'Position',[60 425 1100 250]);
    caxis([0 0.15]);
    colorbar;
end

% Plot topography for synth stimuli
figure
for ii = 1:3,
    subplot(1,3,ii);
    md_acc = median(allsbj_acc(:,replbl==ii+3),2);
    topoplot(md_acc,'chanlocs.xyz','style','map','conv','on');
    title(typenms{ii+3});
    colormap('jet');
    set(gcf,'Position',[60 425 1100 250]);
    caxis([0 0.15]);
    colorbar;
end

% Plot topography of channels that are significantly better than synth
figure
cmap = (0:1/3:1)'*ones(1,3); % manually create a color map with 3 possible values
for ii = 1:3,
    subplot(1,3,ii);
    hold on
    topoplot(h001(:,ii)+h01(:,ii)+h05(:,ii),'chanlocs.xyz','style','map','conv','on');
%     colormap(cmap);
%     topoplot(h05(:,ii),'chanlocs.xyz','style','map');
%     topoplot(h01(:,ii),'chanlocs.xyz','style','map');
%     topoplot(h001(:,ii),'chanlocs.xyz','style','map');
    title(typenms{ii});
    colormap(cmap);
    set(gcf,'Position',[60 425 1100 250]);
    caxis([0 3]);
    colorbar;
end