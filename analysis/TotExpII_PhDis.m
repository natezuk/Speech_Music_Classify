% Compute the phase dissimilarities for experiment II and compare original
% and model-matched rankings of phase dissimilarity
% Nate Zuk (2019)

% Load the stimulus labels
scrmblbls;
types = unique(typelbl);

nchan = 128;
nstims = length(typelbl);

nsbj = 15;

% Use the frequency bin corresponding to 4-8 Hz
use_freq_bin = 2;

% Load classification rankings for each subject
freq_edges = 0:4:40;
phdis = NaN(length(freq_edges)-1,nstims,nsbj); % classification accuracies
rnk_ph = NaN(nstims,nsbj);
sbjs = cell(nsbj,1);
resdir = '/Volumes/ZStore/SpeechMusicClassify/phdis_exp2/';
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

typenms = {'Music','Speech','Impact','Synth Music','Synth Speech','Synth Impact'};
allPH = reshape(phdis,[length(freq_edges)-1 nstims*nsbj]);
figure
set(gcf,'Position',[360,350,560,345]);
md = median(allPH,2);
uq = quantile(allPH,0.75,2);
lq = quantile(allPH,0.25,2);
errorbar(1:length(freq_edges)-1,md,md-lq,uq-md,'r','LineWidth',2);
set(gca,'FontSize',16,'XTick',0.5:1:length(freq_edges)-0.5,'XTickLabel',freq_edges,...
    'XLim',[-0.5 length(freq_edges)+0.5]);
xlabel('Frequency (Hz)');
ylabel('Phase dissimilarity');

% Plot phase dissimilarity for speech and music as a function of frequency
type_idx = [1 2]; % for speech and music respectively
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

% Use a dot-median plot to show the classification ranks
newlbl = NaN(length(typelbl),1); % use a new labeling that puts original next to scrambled
newlblvals = [1 3 5 2 4 6];
for ii = 1:length(typenms),
    typeidx = typelbl==ii;
    newlbl(typeidx) = newlblvals(ii);
end
PHDIS = reshape(rnk_ph,[nstims*nsbj 1]);
dot_median_plot(repmat(newlbl,[nsbj 1]),PHDIS,[],'tot_span',1);
set(gcf,'Position',[360,298,560,400]);
[~,newnmidx] = sort(newlblvals);
set(gca,'XTickLabel',typenms(newnmidx),'XTickLabelRotation',45);
ylabel('Ranked phase dissimilarity');

% Determine if the rankings for speech are significantly reduced in the
% scrambled version
reptype = repmat(typelbl,[1 nsbj]);
reptype = reshape(reptype,[numel(reptype) 1]);
prs = NaN(3,1);
strs = cell(3,1);
for ii = 1:3,
    [prs(ii),~,strs{ii}] = ranksum(PHDIS(reptype==ii),PHDIS(reptype==ii+3));
end