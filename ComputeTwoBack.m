% Compute the number of two-back repeats of the sound clips in each
% stimulus
% Nate Zuk (2018)

orderdir = '/Volumes/Untitled/SpeechMusicClassify/stim_order/';
nclips = 60;
nstim = 40;
nback = 2; % # for #-back repeats

clip_order = NaN(nclips,nstim);
num_twoback = NaN(nstim,1);
tag_cliprep = false(nclips/2,nstim);
for ii = 1:nstim,
    % Get the order of the clips
    flnm = sprintf('stim%d.txt',ii);
    fid = fopen([orderdir flnm]);
    clip_order(:,ii) = fscanf(fid,'%d'); % store the times
    fclose(fid);
    % Compute the number of two-back repeats
    detrep = clip_order(nback+1:end,ii)==clip_order(1:end-nback,ii);
    num_twoback(ii) = sum(detrep);
    % Identify which clips were targets, and tag those repeats
    target_clips = clip_order(find(detrep)+2,ii);
    tag_cliprep(target_clips,ii) = true;
    % Display the result
    fprintf('%s: %d repeats\n',flnm,num_twoback(ii));
end