% Examine the classification accuracy for each channel, and plot using
% topoplot
% Nate Zuk (2019)

addpath(genpath('~/Documents/MATLAB/eeglab13_6_5b/functions'));
addpath('~/Documents/Matlab/fdr_bh');
addpath('~/Projects/Speech_Music_Classify/');

nsbj = 15;
fl_prefix = 'StimClassLDA_chan_';

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

nchan = 128; % number of time indexes

% Load classification rankings for each subject
ntr = NaN(nsbj,1);
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
        ntr(m) = length(r.lbl);
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
    
% Identify channels where the average classification accuracy across all
% stimuli and subjects is above chance (p < 0.001)
ComputeTwoBack; % compute the two-back stimuli in order to determine how many trials were left out
ntargets = sum(sum(tag_cliprep));
ntest = round((ntr-ntargets)/4);
thres = binoinv(0.999,ntest,1/nstims)./ntest;
pass = allsbj_acc>mean(thres);

% Identify the 10 channels that pass significance for the most number of stimuli/subjects
[npass,idx] = sort(sum(pass,2),'descend');
use_chans = false(length(idx),1);
use_chans(idx(1:20)) = true;
cmap = [0 1]'*ones(1,3);
figure
set(gcf,'Position',[60 425 1100 250]);
topoplot(use_chans,'chanlocs.xyz','style','map','conv','on');
colormap(flipud(cmap));
caxis([0 1]);
title('Channels included for significance testing');

% Test for significant difference in average classification for those channels
pdiff = NaN(3,1);
stat_diff = cell(3,1);
for ii = 1:3,
    orig_acc = mean(allsbj_acc(use_chans,replbl==ii),1);
    synth_acc = mean(allsbj_acc(use_chans,replbl==ii+3),1);
    [pdiff(ii),~,stat_diff{ii}] = ranksum(orig_acc',synth_acc');
end

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