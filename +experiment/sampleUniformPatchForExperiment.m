function [stimuli, pIndex] = sampleUniformPatchForExperiment(ImgStats, binIndex, nTrials, nLevels, nSessions)
%SAMPLEPATCHESFOREXPERIMENT Sample patches for use in the detection experiment
% 
% Example: 
%  [stimiuli pIndex] = SAMPLEPATCHESFOREXPERIMENT(ImgStats, 'gabor', [5 5 5], 'uniform'); 
%
% v1.0, 1/5/2016, R. Calen Walshe <calen.walshe@utexas.edu>

%% Load, crop and save images

binLum = ImgStats.Settings.binCenters.L(binIndex(1)) * (2^16 - 1)/(2^8 - 1);
stimuli = ones(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, nTrials, nLevels, nSessions) * binLum;
pIndex  = zeros([nTrials, nLevels, nSessions]);

