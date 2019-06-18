% Rank the classification accuracies for each subject and determine if
% there is a significant difference between them
% addpath('C:\Users\nzuk\Projects\ITDSweep\PsychPhys_fullresults\Analysis\');
nsbj = 10;
fl_prefix = 'StimClassLDA_timelag_';

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

ntm = 39; % number of time indexes

% Load classification rankings for each subject
nstims = length(typelbl); % number of stimuli
acc = NaN(nstims,ntm,nsbj); % classification accuracies
z_acc = NaN(nstims,ntm,nsbj); % z-scored classification accuracies
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/timelag/';
fls = what(resdir);
mats = fls.mat; % subject results
sbj_idx = 1; % index to store the subject results
for m = 1:length(mats)
    maxlen = min([length(fl_prefix) length(mats{m})]);
    if strcmp(mats{m}(1:maxlen),fl_prefix) % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{sbj_idx} = mats{m}(length(fl_prefix)+1:end); % get the subject tag
        acc(:,:,sbj_idx) = r.corr;
        % zscore the accuracies
        ACC = reshape(acc(:,:,sbj_idx),numel(acc(:,:,sbj_idx)),1);
        ZACC = zscore(ACC);
        z_acc(:,:,sbj_idx) = reshape(ZACC,size(acc,1),size(acc,2));
        disp(mats{m});
        sbj_idx = sbj_idx + 1;
    end
end

% Get the time array 
t_iter = r.t_iter;
trange = r.trange;

% Plot the average z-scored accuracy for each type of stimulus (error bars
% across subjects)
typenms = {'Music','Speech','Onset','Synth Music','Synth Speech','Synth Onset'};
% z_acc = permute(z_acc,[2,1,3]); % make time 1st dim, stim 2nd dim
acc = permute(acc,[2,1,3]);
allsbj_acc = reshape(acc,size(acc,1),size(acc,2)*size(acc,3));
% allsbj_acc = reshape(z_acc,size(z_acc,1),size(z_acc,2)*size(z_acc,3));

replbl = repmat(typelbl,nsbj,1); % repeat stimulus labels across all subjects
    % to appropriately label the stimuli in allsbj_acc

figure
cmap = colormap('hsv');
plt_leg = NaN(3,1); % to store line arrays
% plot responses to originals first
subplot(2,1,1);
for ii = 1:3,
    md_acc = median(allsbj_acc(:,replbl==ii),2); % get the median of the z-scored accuracies,
        % avoids outlier performance
    % quantiles of z-scored accuracies
    uq_acc = quantile(allsbj_acc(:,replbl==ii),0.75,2);
    lq_acc = quantile(allsbj_acc(:,replbl==ii),0.25,2);
    clr_idx = floor((ii-1)/3*64)+1;
    disp(cmap(clr_idx,:));
    shaded_plt = shadedErrorBar(t_iter+trange/1000/2,md_acc',[uq_acc-md_acc, md_acc-lq_acc]',...
        'lineprops',{'-','Color',cmap(clr_idx,:)});
    plt_leg(ii) = shaded_plt.mainLine;
end
xlabel('Time (ms)');
ylabel('Z-scored accuracy');
legend(plt_leg,typenms(1:3));
title('Originals');
% plot responses to synth
plt_leg = NaN(3,1);
subplot(2,1,2)
for ii = 4:6,
    md_acc = median(allsbj_acc(:,replbl==ii),2); % get the median of the z-scored accuracies,
        % avoids outlier performance
    % quantiles of z-scored accuracies
    uq_acc = quantile(allsbj_acc(:,replbl==ii),0.75,2);
    lq_acc = quantile(allsbj_acc(:,replbl==ii),0.25,2);
    clr_idx = floor((ii-4)/3*64)+1;
    disp(cmap(clr_idx,:));
    shaded_plt = shadedErrorBar(t_iter+trange/1000/2,md_acc',[uq_acc-md_acc, md_acc-lq_acc]',...
        'lineprops',{'--','Color',cmap(clr_idx,:)});
    plt_leg(ii-3) = shaded_plt.mainLine;
end 
xlabel('Time (ms)');
ylabel('Z-scored accuracy');
legend(plt_leg,typenms(4:6));
title('Synths');