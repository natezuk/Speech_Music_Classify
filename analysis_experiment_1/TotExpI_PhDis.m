% Compute and analyze the phase dissimilarity for each stimulus (experiment I)
% Nate Zuk (2019)

% Load the stimulus labels
stimtypelbl;
types = unique(typelbl);

ntm = 256;
nchan = 128;
nstims = length(typelbl);

% Use the frequency bin corresponding to 4-8 Hz
use_freq_bin = 2;

% Load classification rankings for each subject
freq_edges = 0:4:40;
phdis = NaN(length(freq_edges)-1,nstims,6); % classification accuracies
rnk_ph = NaN(nstims,6);
sbjs = cell(6,1);
resdir = '/Volumes/ZStore/TeohStimClass/SbjResults/phdis_exp1/';
fls = what(resdir);
mats = fls.mat; % subject results
for m = 1:length(mats)
    if strcmp(mats{m}(1:15),'StimClassPhDis_') % make sure it's the appropriate results file
        r = load([resdir mats{m}]); % load the results file
        sbjs{m} = mats{m}(16:end); % get the subject tag
        % zscore the erp, relative to all data points for the subject
        phdis(:,:,m) = r.phdis;
        % rank the phase dissimilarity at 4-8 Hz
        [~,idx] = sort(squeeze(phdis(use_freq_bin,:,m))); % sort accuracies
        rnk = 1:nstims; % assign ranks for each stimulus
        rnk_ph(idx,m) = rnk; % save the rank for each stimulus
        disp(mats{m});
    end
end

% Plot phase dissimilarity as a function of frequency
allPH = reshape(phdis,[length(freq_edges)-1 nstims*length(sbjs)]);
figure
set(gcf,'Position',[360,350,560,400]);
md = median(allPH,2,'omitnan');
uq = quantile(allPH,0.75,2);
lq = quantile(allPH,0.25,2);
errorbar(1:length(freq_edges)-1,md,md-lq,uq-md,'b','LineWidth',2);
set(gca,'FontSize',16,'XTick',0.5:1:length(freq_edges)-0.5,'XTickLabel',freq_edges,...
    'XLim',[-0.5 length(freq_edges)+0.5]);
xlabel('Frequency (Hz)');
ylabel('Phase dissimilarity');

% Plot phase dissimilarity for speech and music as a function of frequency
typenms = {'Environmental','Mechanical','Music','Non-speech vocal','Non-vocal human',...
    'Speech','Animal'};
type_idx = [3 6]; % for speech and music respectively
type_clr = {'b','r'};
reptype = repmat(typelbl,[1 6]);
reptype = reshape(reptype,[numel(reptype) 1]);
figure
hold on
for n = 1:length(type_idx)
    md = median(allPH(:,reptype==type_idx(n)),2,'omitnan');
    uq = quantile(allPH(:,reptype==type_idx(n)),0.75,2);
    lq = quantile(allPH(:,reptype==type_idx(n)),0.25,2);
    errorbar(1:length(freq_edges)-1,md,md-lq,uq-md,type_clr{n},'LineWidth',2);
end
set(gca,'FontSize',16,'XTick',0.5:1:length(freq_edges)-0.5,'XTickLabel',freq_edges,...
    'XLim',[-0.5 length(freq_edges)+0.5]);
xlabel('Frequency (Hz)');
ylabel('Phase dissimilarity');
legend(typenms(type_idx));

% Plot ranked phase dissimilarity
% typenms = {'Environmental','Mechanical','Music','Non-speech vocal','Non-vocal human',...
%     'Speech','Animal'};
% reptype = repmat(typelbl,[1 6]);
% reptype = reshape(reptype,[numel(reptype) 1]);
PHDIS = reshape(rnk_ph,[nstims*length(sbjs) 1]);
% PHDIS = reshape(phdis(use_freq_bin,:,:),[nstims*length(sbjs) 1]);
dot_median_plot(reptype,PHDIS);
set(gcf,'Position',[360,298,560,400]);
set(gca,'FontSize',16,'XTickLabel',typenms,'XTickLabelRotation',45);
ylabel('Phase dissimilarity ranking');

% Compute stats
[pkw,tbl,stats] = kruskalwallis(PHDIS,reptype);
figure
cmp = multcompare(stats,'ctype','dunn-sidak');