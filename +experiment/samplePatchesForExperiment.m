function [stimuli, patchIndex] = samplePatchesForExperiment(ImgStats, targetKeyStr, ...
    binIndex, nTrials, nLevels, nBlocks, sampleMethod, simTypeStr, imgTypeStr)
% SAMPLEPATCHESFOREXPERIMENT  Sample natural-image patches for a detection experiment.
%   [stimuli, patchIndex] = experiment.samplePatchesForExperiment(ImgStats, ...
%       targetKeyStr, binIndex, nTrials, nLevels, nBlocks)
%   [...] = experiment.samplePatchesForExperiment(..., sampleMethod, simTypeStr, imgTypeStr)
%
%   Picks nTrials*nLevels*nBlocks patch locations out of one
%   luminance/contrast/similarity bin of a precomputed patch index, then
%   loads and crops each one. With sampleMethod 'uniform' the patches are
%   spread evenly over the bin after sorting by source image, so no single
%   image dominates; otherwise they are drawn at random with replacement.
%
%   Inputs
%     ImgStats     - image-statistics struct; uses .Settings (paths and
%                    .surroundSizePix, the stimulus side in pixels),
%                    .patchIndex / .patchIndexSs (per-target bin membership),
%                    .L (per-coordinate, per-image luminance) and .imgType.
%     targetKeyStr - target name, e.g. 'gabor'.
%     binIndex     - [luminance, contrast, similarity] bin indices, each 1-10.
%     nTrials      - trials per level, count.
%     nLevels      - levels per session, count.
%     nBlocks      - sessions, count.
%     sampleMethod - 'uniform' to spread evenly over the bin, anything else
%                    to draw at random. Default 'uniform'.
%     simTypeStr   - 'amplitude' to use .patchIndex, anything else to use
%                    .patchIndexSs. Default 'amplitude'.
%     imgTypeStr   - image-type filter, or 'all' for no filter. Default 'all'.
%
%   Output
%     stimuli    - surroundSizePix x surroundSizePix x nTrials x nLevels x
%                  nBlocks array of patch pixel values.
%     patchIndex - nTrials x nLevels x nBlocks array of linear indices into
%                  ImgStats.L, recording which patch each stimulus came from.
%
%   The nargin guard for imgTypeStr tests nargin < 9 twice (it should test
%   nargin < 8 for simTypeStr), so simTypeStr defaults correctly only by
%   coincidence of the two defaults never being needed apart. Left as found:
%   changing a condition is not a Stage 1 edit.
%
%   See also experiment.SAMPLENOISEPATCHFOREXPERIMENT, experiment.SAMPLEUNIFORMPATCHFOREXPERIMENT.

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

    targetKeyIndex = lib.target_index_from_string(ImgStats.Settings, targetKeyStr);
    nPatches = nBlocks*nLevels*nTrials;

    if(strcmp(simTypeStr, 'amplitude'))
        patchIndexBin = ...
            ImgStats.patchIndex{targetKeyIndex}{binIndex(1), binIndex(2), binIndex(3)};
    else
        patchIndexBin = ...
            ImgStats.patchIndexSs{targetKeyIndex}{binIndex(1), binIndex(2), binIndex(3)};
    end

    %% Sample patches across all bins,
    % keep image order, but randomize the coordinate order
    if(~strcmp(imgTypeStr, 'all'))
        [~, imageIndex] = ind2sub(size(ImgStats.L), patchIndexBin);
        matchingIndex = find(ImgStats.imgType(imageIndex) == imgTypeStr);
        patchIndexBin = patchIndexBin(matchingIndex);
    end

    if(strcmp(sampleMethod, 'uniform'))
        patchIndexBin = patchIndexBin(randperm(length(patchIndexBin)));

        nCoords = size(ImgStats.L, 1);
        nImages = size(ImgStats.L, 2);

        [~, imageIndexRand] = ind2sub([nCoords nImages], patchIndexBin);
        [~, sortedIndex] = sort(imageIndexRand);

        patchIndexBin = patchIndexBin(sortedIndex);
        patchIndex = patchIndexBin(round(linspace(1, length(patchIndexBin), nPatches)));
        patchIndex = patchIndex(randperm(length(patchIndex)));
    else
        patchIndex = randsample(patchIndexBin, nPatches);
    end

    patchIndex = reshape(patchIndex, [nTrials, nLevels, nBlocks]);

    %% Load, crop and save images
    stimuli = zeros(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, ...
        nTrials, nLevels, nBlocks);

    for iTrial = 1:nTrials
        for iLevel = 1:nLevels
            for iBlock = 1:nBlocks
                stimuli(:, :, iTrial, iLevel, iBlock) = ...
                    lib.load_patch_at_index(ImgStats, patchIndex(iTrial, iLevel, iBlock), ...
                    filePathIn, 0, 0);
            end
        end
    end
end
