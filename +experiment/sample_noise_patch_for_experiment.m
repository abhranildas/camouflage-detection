function [stimuli, patch_index] = sample_noise_patch_for_experiment(ImgStats, target_key_str, ...
    bin_index, bin_contrast, n_trials, n_levels, n_blocks, sample_method)
% SAMPLE_NOISE_PATCH_FOR_EXPERIMENT  Build 1/f-noise stimuli for a detection experiment.
%   [stimuli, patch_index] = experiment.sample_noise_patch_for_experiment(ImgStats, ...
%       target_key_str, bin_index, bin_contrast, n_trials, n_levels, n_blocks)
%   [...] = experiment.sample_noise_patch_for_experiment(..., sample_method)
%
%   The synthetic-background control condition: instead of cropping natural
%   image patches, every stimulus is a fresh 241 x 241 pink-noise field
%   rescaled to the RMS contrast of the contrast bin named by bin_index(2).
%   No source patches are drawn, so the returned index array is all zeros and
%   exists only to match the signature of the sibling samplers.
%
%   Inputs
%     ImgStats       - image-statistics struct; uses .Settings (for
%                      .surroundSizePix, the stimulus side in pixels) and the
%                      target key list.
%     target_key_str - target name, e.g. 'gabor'; resolved to an index but not
%                      otherwise used on this path.
%     bin_index      - [luminance, contrast, similarity] bin indices, each
%                      1-10; only the second is used here.
%     bin_contrast   - RMS contrast at each contrast-bin centre, dimensionless.
%     n_trials       - trials per level, count.
%     n_levels       - levels per session, count.
%     n_blocks       - sessions, count.
%     sample_method  - kept for signature compatibility with the sibling
%                      samplers; unused here. Default 'uniform'.
%
%   Output
%     stimuli     - surround_size_pix x surround_size_pix x n_trials x n_levels x
%                   n_blocks array of 16-bit pixel values.
%     patch_index - n_trials x n_levels x n_blocks array of zeros; there is no
%                   source patch for a synthesised field.
%
%   Note that lib.pink_noise_2d does not exist anywhere in the tree (B2.9), so
%   this function cannot currently run; the call is left as written, since
%   repointing it would be a real change and not a Stage 1 rename. n_patches
%   is likewise computed and never used.
%
%   See also experiment.SAMPLE_PATCHES_FOR_EXPERIMENT,
%   experiment.SAMPLE_UNIFORM_PATCH_FOR_EXPERIMENT.

    %% Set up
    if(nargin < 7)
        sample_method = 'uniform';
    end

    target_key_index = lib.target_index_from_string(ImgStats.Settings, target_key_str);
    n_patches = n_blocks*n_levels*n_trials;
    mask_contrast = bin_contrast(bin_index(2));

    %% Load, crop and save images
    stimuli = zeros(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, ...
        n_trials, n_levels, n_blocks);

    for i_trial = 1:n_trials
        for i_level = 1:n_levels
            for i_block = 1:n_blocks
                noise_patch = lib.pink_noise_2d(241, 241, 60);

                noise_patch = (noise_patch - min(noise_patch(:)));
                noise_patch = round((noise_patch ./ max(noise_patch(:))) .* (2^16 - 1));

                noise_patch = (noise_patch - mean(noise_patch(:))) ./ std(noise_patch(:)) ...
                    .* mask_contrast .* floor((2^16 - 1)/2) + floor((2^16 - 1)/2);

                stimuli(:, :, i_trial, i_level, i_block) = noise_patch;
            end
        end
    end

    patch_index = zeros([n_trials, n_levels, n_blocks]);
end
