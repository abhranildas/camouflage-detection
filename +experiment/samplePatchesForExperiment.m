function [stimuli, pIndex] = samplePatchesForExperiment(ImgStats, targetKeyStr, binIndex, nTrials, nLevels, nBlocks, sampleMethod, simTypeStr, imgTypeStr)
%SAMPLEPATCHESFOREXPERIMENT Sample patches for use in the detection experiment
% 
% Example: 
%  [stimiuli pIndex] = SAMPLEPATCHESFOREXPERIMENT(ImgStats, 'gabor', [5 5 5], 'uniform'); 
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>

%% Set up

if(nargin < 7)
    sampleMethod = 'uniform';
end

if(nargin < 9)
    simTypeStr = 'amplitude';
end

if(nargin < 9)
    imgTypeStr = 'all';
end


if(sum(binIndex > 10 | binIndex < 1))
    error('binIndex out of range. Use 1-10');
end

filePathIn = ImgStats.Settings.imgFilePathExperiment;

targetKeyIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetKeyStr);
nPatches = nBlocks*nLevels*nTrials;

if(strcmp(simTypeStr,'amplitude'))
    patchIndexBin = ...
        ImgStats.patchIndex{targetKeyIndex}{binIndex(1), binIndex(2), binIndex(3)};
else
    patchIndexBin = ...
        ImgStats.patchIndexSs{targetKeyIndex}{binIndex(1), binIndex(2), binIndex(3)};
end

%% Sample patches across all bins, 
% keep image order, but randomize the coordinate order

if(~strcmp(imgTypeStr,'all'))
    [~, iIndex] = ind2sub(size(ImgStats.L),patchIndexBin);
    nIndex = find(ImgStats.imgType(iIndex) == imgTypeStr);
    patchIndexBin = patchIndexBin(nIndex);
end
    
if(strcmp(sampleMethod, 'uniform'))
    patchIndexBin = patchIndexBin(randperm(length(patchIndexBin)));

    nCoords = size(ImgStats.L,1);
    nImages = size(ImgStats.L,2);

    [~, iIndexRand] = ind2sub([nCoords nImages], patchIndexBin);
    [~, sortedIndex] = sort(iIndexRand);

    patchIndexBin = patchIndexBin(sortedIndex);
    pIndex = patchIndexBin(round(linspace(1, length(patchIndexBin), nPatches)));
    pIndex = pIndex(randperm(length(pIndex)));
else
    pIndex = randsample(patchIndexBin, nPatches);
end

pIndex = reshape(pIndex, [nTrials, nLevels nBlocks]);

%% Load, crop and save images
stimuli = zeros(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, nTrials, nLevels, nBlocks);

for iTrials = 1:nTrials
    for iLevels = 1:nLevels
        for iBlocks = 1:nBlocks
            stimuli(:,:, iTrials, iLevels, iBlocks) = ...
                lib.loadPatchAtIndex(ImgStats, pIndex(iTrials, iLevels, iBlocks), filePathIn, 0, 0);
        end
    end
end

