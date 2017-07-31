function [stimuli, pIndex] = sampleNoisePatchForExperiment(ImgStats, targetKeyStr, binIndex, binContrast, nTrials, nLevels, nBlocks, sampleMethod)
%SAMPLEPATCHESFOREXPERIMENT Sample patches for use in the detection experiment
% 
% Example: 
%  [stimiuli pIndex] = SAMPLEPATCHESFOREXPERIMENT(ImgStats, 'gabor', [5 5 5], 'uniform'); 
%
% v1.0, 1/5/2016, R. Calen Walshe <calen.walshe@utexas.edu>

%% Set up

if(nargin < 7)
    sampleMethod = 'uniform';
end


targetKeyIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetKeyStr);
nPatches = nBlocks*nLevels*nTrials;
maskContrast = binContrast(binIndex(2));

%% Load, crop and save images
stimuli = zeros(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, nTrials, nLevels, nBlocks);

for iTrials = 1:nTrials
    for iLevels = 1:nLevels
        for iBlocks = 1:nBlocks                                                         
            nPatch = lib.pink_noise_2d(241, 241, 60);
            
            nPatch = (nPatch - min(nPatch(:)));
            nPatch= round((nPatch./ max(nPatch(:))) .* (2^16 - 1));

            nPatch = (nPatch - mean(nPatch(:))) ./ std(nPatch(:)) .* maskContrast .* floor((2^16 - 1)/2) + floor((2^16 - 1)/2);
            
            stimuli(:,:, iTrials, iLevels, iBlocks) = ...
                nPatch;            
        end
    end
end

pIndex = zeros([nTrials, nLevels, nBlocks]);

