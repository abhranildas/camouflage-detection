function [stimuli, patchIndex] = sample_noise_patch_for_experiment(ImgStats, targetKeyStr, ...
    binIndex, binContrast, nTrials, nLevels, nBlocks, sampleMethod)
% SAMPLE_NOISE_PATCH_FOR_EXPERIMENT  Build 1/f-noise stimuli for a detection experiment.
%   [stimuli, patchIndex] = experiment.sample_noise_patch_for_experiment(ImgStats, ...
%       targetKeyStr, binIndex, binContrast, nTrials, nLevels, nBlocks)
%   [...] = experiment.sample_noise_patch_for_experiment(..., sampleMethod)
%
%   The synthetic-background control condition: instead of cropping natural
%   image patches, every stimulus is a fresh 241 x 241 pink-noise field
%   rescaled to the RMS contrast of the contrast bin named by binIndex(2).
%   No source patches are drawn, so the returned index array is all zeros and
%   exists only to match the signature of the sibling samplers.
%
%   Inputs
%     ImgStats     - image-statistics struct; uses .Settings (for
%                    .surroundSizePix, the stimulus side in pixels) and the
%                    target key list.
%     targetKeyStr - target name, e.g. 'gabor'; resolved to an index but not
%                    otherwise used on this path.
%     binIndex     - [luminance, contrast, similarity] bin indices, each
%                    1-10; only the second is used here.
%     binContrast  - RMS contrast at each contrast-bin centre, dimensionless.
%     nTrials      - trials per level, count.
%     nLevels      - levels per session, count.
%     nBlocks      - sessions, count.
%     sampleMethod - kept for signature compatibility with the sibling
%                    samplers; unused here. Default 'uniform'.
%
%   Output
%     stimuli    - surroundSizePix x surroundSizePix x nTrials x nLevels x
%                  nBlocks array of 16-bit pixel values.
%     patchIndex - nTrials x nLevels x nBlocks array of zeros; there is no
%                  source patch for a synthesised field.
%
%   Note that lib.pink_noise_2d does not exist anywhere in the tree (B2.9), so
%   this function cannot currently run; the call is left as written, since
%   repointing it would be a real change and not a Stage 1 rename. nPatches
%   is likewise computed and never used.
%
%   See also experiment.SAMPLE_PATCHES_FOR_EXPERIMENT, experiment.SAMPLE_UNIFORM_PATCH_FOR_EXPERIMENT.

    %% Set up
    if(nargin < 7)
        sampleMethod = 'uniform';
    end

    targetKeyIndex = lib.target_index_from_string(ImgStats.Settings, targetKeyStr);
    nPatches = nBlocks*nLevels*nTrials;
    maskContrast = binContrast(binIndex(2));

    %% Load, crop and save images
    stimuli = zeros(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, ...
        nTrials, nLevels, nBlocks);

    for iTrial = 1:nTrials
        for iLevel = 1:nLevels
            for iBlock = 1:nBlocks
                noisePatch = lib.pink_noise_2d(241, 241, 60);

                noisePatch = (noisePatch - min(noisePatch(:)));
                noisePatch = round((noisePatch ./ max(noisePatch(:))) .* (2^16 - 1));

                noisePatch = (noisePatch - mean(noisePatch(:))) ./ std(noisePatch(:)) ...
                    .* maskContrast .* floor((2^16 - 1)/2) + floor((2^16 - 1)/2);

                stimuli(:, :, iTrial, iLevel, iBlock) = noisePatch;
            end
        end
    end

    patchIndex = zeros([nTrials, nLevels, nBlocks]);
end
