function [stimuli, patchIndex] = sampleUniformPatchForExperiment(ImgStats, binIndex, ...
    nTrials, nLevels, nSessions)
% SAMPLEUNIFORMPATCHFOREXPERIMENT  Build uniform-luminance stimuli for a detection experiment.
%   [stimuli, patchIndex] = experiment.sampleUniformPatchForExperiment(ImgStats, ...
%       binIndex, nTrials, nLevels, nSessions)
%
%   The flat-field control condition: instead of cropping natural-image
%   patches, every stimulus is a constant field at the luminance-bin centre
%   named by binIndex(1). No patches are drawn, so the returned index array
%   is all zeros and exists only to match the signature of the sibling
%   samplers.
%
%   Inputs
%     ImgStats  - image-statistics struct; uses .Settings.binCenters.L (bin
%                 centre luminances in 8-bit pixel values) and
%                 .Settings.surroundSizePix (stimulus side, in pixels).
%     binIndex  - [luminance, contrast, similarity] bin indices, each 1-10;
%                 only the first is used here.
%     nTrials   - trials per level, count.
%     nLevels   - levels per session, count.
%     nSessions - sessions, count.
%
%   Output
%     stimuli    - surroundSizePix x surroundSizePix x nTrials x nLevels x
%                  nSessions array of 16-bit pixel values.
%     patchIndex - nTrials x nLevels x nSessions array of zeros; there is no
%                  source patch for a uniform field.
%
%   The bin centre is stored in 8-bit units and rescaled to 16-bit here, which
%   is why the (2^16 - 1)/(2^8 - 1) factor appears.
%
%   See also experiment.SAMPLEPATCHESFOREXPERIMENT, experiment.SAMPLENOISEPATCHFOREXPERIMENT.

    %% Load, crop and save images
    binLuminance = ImgStats.Settings.binCenters.L(binIndex(1)) * (2^16 - 1)/(2^8 - 1);
    stimuli = ones(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, ...
        nTrials, nLevels, nSessions) * binLuminance;
    patchIndex = zeros([nTrials, nLevels, nSessions]);
end
