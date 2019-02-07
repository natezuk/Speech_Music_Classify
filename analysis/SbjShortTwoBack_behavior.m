% Load the behavioral data for a particular subject from the
% ShortClipTwoBack experiment (speech/music classification)

addpath('~/Projects/Speech_Music_Classify/');

sbj = 'WWDVDF';
sbj_data = 'ShortClipTwoBack_res_sbjWWDVDF_20-Sep-2018';
behav_folder = '/Volumes/Untitled/SpeechMusicClassify/';
r = load([behav_folder sbj_data]);

% Order the trials by the correct order
trk_nms = r.results.trknms(r.results.trkorder);
nstims = length(trk_nms);

% Get the overall percentage of correct detections
overall_corr = cellfun(@(x) sum(x),r.results.corr); % targets correctly detected
total_targets = cellfun(@(x) length(x),r.results.corr); % total number of targets
prop_corr = sum(overall_corr)./sum(total_targets);

% Organize the correct detections by stimulus type
ComputeTwoBack; % get the targets
% clip_order = order of the sound clips
% tag_cliprep = tags if any of the sound clips are targets
% num_twoback = # of targets
nclips = 30; % reassign nclips to number of unique sound clips (not repeats as in experiment)
clip_corr = zeros(nclips,nstims);
clip_targets = zeros(nclips,nstims);
clip_FA = zeros(nclips,nstims);
trk_idx = NaN(nstims,1);
for ii = 1:nstims,
    trk_idx(ii) = str2double(trk_nms{ii}(5:end)); % get the stimulus number
    order = clip_order(:,trk_idx(ii));
    % compute the targets per sound clip
    clip_targets(:,ii) = tag_cliprep(:,trk_idx(ii));
    % compute the sound clips that were correct detections
    target_idx = round((r.results.dettms{ii}/2-1)); % indexes of the targets in that trial
    corr_idx = target_idx(r.results.corr{ii}); % get only the indexes for correct detections
    clip_corr(order(corr_idx),ii) = 1;
    % compute the sound clips that were false alarms
    all_resp = r.results.resptms{ii}; % get all response times
    all_idx = floor(all_resp/2-1); % round response times to nearest index
    fa_idx = setxor(all_idx,corr_idx); % get all responses that were not correct detections
    % remove false alarms that were before time index 1
    fa_idx(fa_idx<1) = [];
    fa_clips = order(fa_idx); % get the clips during the false alarms
    clip_FA(:,ii) = arrayfun(@(x) sum(fa_clips==x),1:30); % count up the number of false alarms for each clip
end

% Make sure that the number of target is correct
[~,srt_idx] = sort(trk_idx);
sum_targets = sum(clip_targets(:,srt_idx),1)';
if sum(num_twoback~=sum_targets)>0,
    error('Number of calculated targets do not match');
end

% Get the proportion of correct detections and false alarms for each
% stimulus class
% There are 5 clips per type, ordered in groups of 5
prop_type_corr = NaN(6,1);
prop_type_FA = NaN(6,1);
total_type = NaN(6,1);
for ii = 1:6,
    type_idx = (ii-1)*5+1:ii*5; % indexes for the clip type
    type_targets = sum(sum(clip_targets(type_idx,:),2));
    type_nottargets = sum(sum(2-clip_targets(type_idx,:),2));
    type_corr = sum(sum(clip_corr(type_idx,:),2));
    type_fa = sum(sum(clip_FA(type_idx,:),2));
    prop_type_corr(ii) = type_corr/type_targets;
    prop_type_FA(ii) = type_fa/type_nottargets;
    total_type(ii) = type_targets;
end

typenms = {'Music','Speech','Impact','Synth Music','Synth Speech','Synth Impact'};
figure
bar(1:6,[prop_type_corr prop_type_FA]);
set(gca,'FontSize',16,'XTick',1:6,'XTickLabel',typenms);
legend('Correct detection','False alarm');
ylabel('Proportion');
title(sbj);

behavior_pth = '~/Projects/Speech_Music_Classify/behavior_results/';
behavior_fl = sprintf('ShortTwoBack_res_%s',sbj);
save([behavior_pth behavior_fl],'prop_type_corr','prop_type_FA','prop_corr',...
    'clip_corr','clip_targets','clip_FA','trk_idx');