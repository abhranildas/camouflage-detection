function [stimuli, patch_index] = sample_uniform_patch_for_experiment(ImgStats, bin_index, ...
    n_trials, n_levels, n_sessions)
% SAMPLE_UNIFORM_PATCH_FOR_EXPERIMENT  Build uniform-luminance stimuli for a detection experiment.
%   [stimuli, patch_index] = experiment.sample_uniform_patch_for_experiment(ImgStats, ...
%       bin_index, n_trials, n_levels, n_sessions)
%
%   The flat-field control condition: instead of cropping natural-image
%   patches, every stimulus is a constant field at the luminance-bin centre
%   named by bin_index(1). No patches are drawn, so the returned index array
%   is all zeros and exists only to match the signature of the sibling
%   samplers.
%
%   Inputs
%     ImgStats   - image-statistics struct; uses .Settings.binCenters.L (bin
%                  centre luminances in 8-bit pixel values) and
%                  .Settings.surroundSizePix (stimulus side, in pixels).
%     bin_index  - [luminance, contrast, similarity] bin indices, each 1-10;
%                  only the first is used here.
%     n_trials   - trials per level, count.
%     n_levels   - levels per session, count.
%     n_sessions - sessions, count.
%
%   Output
%     stimuli     - surround_size_pix x surround_size_pix x n_trials x n_levels x
%                   n_sessions array of 16-bit pixel values.
%     patch_index - n_trials x n_levels x n_sessions array of zeros; there is no
%                   source patch for a uniform field.
%
%   The bin centre is stored in 8-bit units and rescaled to 16-bit here, which
%   is why the (2^16 - 1)/(2^8 - 1) factor appears.
%
%   See also experiment.SAMPLE_PATCHES_FOR_EXPERIMENT, experiment.SAMPLE_NOISE_PATCH_FOR_EXPERIMENT.

    %% Load, crop and save images
    bin_luminance = ImgStats.Settings.binCenters.L(bin_index(1)) * (2^16 - 1)/(2^8 - 1);
    stimuli = ones(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, ...
        n_trials, n_levels, n_sessions) * bin_luminance;
    patch_index = zeros([n_trials, n_levels, n_sessions]);
end
