% Run ICA analysis on EEG
% (Run SpMusGen_rcnstr first)
addpath('~/FastICA_25/');
addpath(genpath('~/eeglab14_0_0b/functions'));

[icasig,A] = icaexamineeeg(EEG,eFs);