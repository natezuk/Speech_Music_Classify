% Compute the number of interpolated channels for each subject

% Experiment 1
eegpth_expI = '/Volumes/Untitled/NaturalSounds_ExpI/eegs/';
sbj_expI = {'AB','JOS','MC','MM','MO','SN'};

ninterp_expI = NaN(length(sbj_expI),1);
for s = 1:length(sbj_expI),
    d = load([eegpth_expI sbj_expI{s} '_removed']);
    ninterp_expI(s) = length(d.interpchans);
    disp(sbj_expI{s});
end

% Experiment 2
eegpth_expII = '/Volumes/Untitled/SpeechMusicClassify/eegs/';
sbj_expII = {'BIJVZD','EFFEUS','GQEVXE','HGWLOI','HITXMV','HNJUPJ',...
    'NFICHK','RHQBHE','RMAALZ','TQZHZT','TUZEZT','UOBXJO',...
    'WWDVDF','YMKSWS','ZLIDEI'};

ninterp_expII = NaN(length(sbj_expII),1);
for s = 1:length(sbj_expII),
    d = load([eegpth_expII sbj_expII{s} '_removed']);
    ninterp_expII(s) = length(d.interpchans);
    disp(sbj_expII{s});
end

fprintf('Max interp chans: %d\n',max([ninterp_expI; ninterp_expII]));
fprintf('Median interp chans: %d\n',median([ninterp_expI; ninterp_expII]));