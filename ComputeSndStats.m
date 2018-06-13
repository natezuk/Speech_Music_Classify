% Compute the statistics of each sound from TeohSpMus

sndpth = 'A:\SamNHSounds\';
% sndpth = 'A:\TeohSpMus\Natural Sounds - Stimuli\';
fls = dir(sndpth);

% Load general parameters for calculating the stimulus statistics (based on
% McDermott & Simoncelli (2011)
synthesis_parameters;

sndfl = {}; % to store sound filename
modc2 = []; % to store c2 correlations
for n = 1:length(fls),
    if ~fls(n).isdir,
        sndfl = [sndfl {fls(n).name}];
        % Load the sound
        [y,Fs] = audioread([sndpth sndfl{end}]);

        % Set the initial parameters
        P.orig_sound_filename = sndfl{end};
        P.orig_sound_folder = sndpth;

        % Downsample the sound to the expected sampling rate, specified in P
        expFs = P.audio_sr;
        y = resample(y,expFs,Fs);

        % Compute the statistics
        S = measure_texture_stats(y,P);
        
        % Save stats
        modc2(:,:,length(sndfl)) = [S.mod_C2(:,:,1) S.mod_C2(:,:,2)];
        
        disp(sndfl{end});
    end
end

% Compute the average modc2 for real and imaginary components
MN = NaN(length(sndfl),2);
srtmn = NaN(length(sndfl),2);
idxmn = NaN(length(sndfl),2);
MN(:,1) = squeeze(mean(mean(modc2(:,1:6,:))));
MN(:,2) = squeeze(mean(mean(modc2(:,7:12,:))));
[srtmn(:,1),idxmn(:,1)] = sort(MN(:,1));
[srtmn(:,2),idxmn(:,2)] = sort(MN(:,2));

% Plot the sorted C2 values
figure
hold on
plot(srtmn(:,1),'b'); plot(srtmn(:,2),'r');
xlabel('Sound index');
ylabel('Mean C2');
legend('Real','Imaginary');

% Mark the two non-vocal human sounds that were included in Teoh's stimuli
usedsnds = {'stim80_chopping_food.wav','stim399_walking_on_hard_surface.wav'};
xidxused = NaN(length(usedsnds),2);
for jj = 1:length(usedsnds),
    uidx = find(strcmp(sndfl,usedsnds{jj}));
    xidxused(jj,1) = find(idxmn(:,1)==uidx); % x index in plot for real
    xidxused(jj,2) = find(idxmn(:,2)==uidx); % x index in plot for imaginary
end
plot(xidxused(:,1),srtmn(xidxused(:,1),1),'bx','MarkerSize',14);
plot(xidxused(:,2),srtmn(xidxused(:,2),2),'rx','MarkerSize',14);