% This is a function/script to implement Luo and Poeppel's (2007) phase dissimilarity measure.

% Cphase_ij = (sum_n=1:N(cos(theta_nij))/N)^2 + (sum_n=1:N(sin(theta_nij))/N)^2; theta_nij = phase at freq i, time j, trial n.
% Dissimilarity_i = (sum_j=1:J Cphase_ij, within)/J - (sum_j=1:J Cphase_ij, across)/J;

% speechTrials should have dimensions (trial x channel x time) - we are just going to do this for 4-8 Hz.

% NZ edit (2019) -- eegTrials should have dimensions (time x trial x stimulus)

function [C_within, C_across, D] = phaseDissimilarity(eegTrials,Fs,varargin)
% Compute the phase dissimilarity (see Luo & Poeppel, 2007) in EEG for 
% frequency bins spaced every 4 Hz to 40 Hz (as in Teoh's thesis). Only 
% one channel can be included in the EEG to compute dissimilarity.
% Inputs:
% - eegTrials = EEG data (time x trial x stimulus)
% - Fs = sampling rate of the EEG data
% Outputs:
% - C_within = within stimulus phase coherence (stimulus x freq_bins)
% - C_across = across stimulus phase coherence, each determined by randomly
%   trials across all stimuli (nshuffles x freq_bins, default nshuffles = # stimuli)
% - D = phase dissimilarity, comparing C_withing to mean(C_across) (stimulus x freq_bins)

nshuffles = size(eegTrials,3);
freq_edges = 0:4:40; % ranges of each frequency bin use for computing dissimilarity

if ~isempty(varargin)
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

nstim = size(eegTrials,3);
nfreq_bins = length(freq_edges)-1;

C_within = zeros(nfreq_bins, nstim);
C_across = zeros(nfreq_bins, nshuffles);

% Compute the frequency array
frq = (0:size(eegTrials,1)-1)/size(eegTrials,1)*Fs;

for c = 1:nstim
    
    FEEG = fft(eegTrials(:,:,c)); % compute the fft of the EEG
    ph = angle(FEEG); % get the angles for each frequency bin in each channel
    coh = mean(cos(ph),2,'omitnan').^2 + mean(sin(ph),2,'omitnan').^2;
        % 'omitnan' skips missing trials
    
    for f = 1:nfreq_bins
        idx = frq>=freq_edges(f)&frq<=freq_edges(f+1);
        C_within(f,c) = mean(coh(idx));
    end
    
end
disp('C_within calculated');

% Take all EEG data and combine trials and stimuli on one dimension
ntr = size(eegTrials,2);
alleeg = reshape(eegTrials,[size(eegTrials,1) ntr*nstim]);

for n = 1:nshuffles
    
    % randomly select trials across 
    rnd_trs = randperm(ntr*nstim,ntr);
    rndEEG = alleeg(:,rnd_trs);
    
    FEEG = fft(rndEEG); % compute the fft of the EEG
    ph = angle(FEEG); % get the angles for each frequency bin in each channel
    coh = mean(cos(ph),2,'omitnan').^2 + mean(sin(ph),2,'omitnan').^2;
    
    for f = 1:nfreq_bins
        idx = frq>=freq_edges(f)&frq<=freq_edges(f+1);
        C_across(f,n) = mean(coh(idx));
    end
    
end
disp('C_across calculated');

% Now - compare the crosstrial phase coherence within and between trials
% Use dissimilarity = within-trial coherence - coherence averaged across
% shuffled data

D = C_within - mean(C_across,2)*ones(1,nstim);
