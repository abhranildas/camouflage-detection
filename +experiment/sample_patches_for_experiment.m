function [stimuli, patch_index] = sample_patches_for_experiment(ImgStats, target_key_str, ...
    bin_index, n_trials, n_levels, n_blocks, sample_method, sim_type_str, img_type_str)
% SAMPLE_PATCHES_FOR_EXPERIMENT  Sample natural-image patches for a detection experiment.
%   [stimuli, patch_index] = experiment.sample_patches_for_experiment(ImgStats, ...
%       target_key_str, bin_index, n_trials, n_levels, n_blocks)
%   [...] = experiment.sample_patches_for_experiment(..., sample_method, sim_type_str, img_type_str)
%
%   Picks n_trials*n_levels*n_blocks patch locations out of one
%   luminance/contrast/similarity bin of a precomputed patch index, then
%   loads and crops each one. With sample_method 'uniform' the patches are
%   spread evenly over the bin after sorting by source image, so no single
%   image dominates; otherwise they are drawn at random with replacement.
%
%   Inputs
%     ImgStats       - image-statistics struct; uses .Settings (paths and
%                      .surroundSizePix, the stimulus side in pixels),
%                      .patchIndex / .patchIndexSs (per-target bin membership),
%                      .L (per-coordinate, per-image luminance) and .imgType.
%     target_key_str - target name, e.g. 'gabor'.
%     bin_index      - [luminance, contrast, similarity] bin indices, each 1-10.
%     n_trials       - trials per level, count.
%     n_levels       - levels per session, count.
%     n_blocks       - sessions, count.
%     sample_method  - 'uniform' to spread evenly over the bin, anything else
%                      to draw at random. Default 'uniform'.
%     sim_type_str   - 'amplitude' to use .patchIndex, anything else to use
%                      .patchIndexSs. Default 'amplitude'.
%     img_type_str   - image-type filter, or 'all' for no filter. Default 'all'.
%
%   Output
%     stimuli     - surround_size_pix x surround_size_pix x n_trials x n_levels x
%                   n_blocks array of patch pixel values.
%     patch_index - n_trials x n_levels x n_blocks array of linear indices into
%                   ImgStats.L, recording which patch each stimulus came from.
%
%   The nargin guard for img_type_str tests nargin < 9 twice (it should test
%   nargin < 8 for sim_type_str), so sim_type_str defaults correctly only by
%   coincidence of the two defaults never being needed apart. Left as found:
%   changing a condition is not a Stage 1 edit.
%
%   See also experiment.SAMPLE_NOISE_PATCH_FOR_EXPERIMENT,
%   experiment.SAMPLE_UNIFORM_PATCH_FOR_EXPERIMENT.

    %% Set up
    if(nargin < 7)
        sample_method = 'uniform';
    end

    if(nargin < 9)
        sim_type_str = 'amplitude';
    end

    if(nargin < 9)
        img_type_str = 'all';
    end

    if(sum(bin_index > 10 | bin_index < 1))
        error('bin_index out of range. Use 1-10');
    end

    file_path_in = ImgStats.Settings.imgFilePathExperiment;

    target_key_index = lib.target_index_from_string(ImgStats.Settings, target_key_str);
    n_patches = n_blocks*n_levels*n_trials;

    if(strcmp(sim_type_str, 'amplitude'))
        patch_index_bin = ...
            ImgStats.patchIndex{target_key_index}{bin_index(1), bin_index(2), bin_index(3)};
    else
        patch_index_bin = ...
            ImgStats.patchIndexSs{target_key_index}{bin_index(1), bin_index(2), bin_index(3)};
    end

    %% Sample patches across all bins,
    % keep image order, but randomize the coordinate order
    if(~strcmp(img_type_str, 'all'))
        [~, image_index] = ind2sub(size(ImgStats.L), patch_index_bin);
        matching_index = find(ImgStats.imgType(image_index) == img_type_str);
        patch_index_bin = patch_index_bin(matching_index);
    end

    if(strcmp(sample_method, 'uniform'))
        patch_index_bin = patch_index_bin(randperm(length(patch_index_bin)));

        n_coords = size(ImgStats.L, 1);
        n_images = size(ImgStats.L, 2);

        [~, image_index_rand] = ind2sub([n_coords n_images], patch_index_bin);
        [~, sorted_index] = sort(image_index_rand);

        patch_index_bin = patch_index_bin(sorted_index);
        patch_index = patch_index_bin(round(linspace(1, length(patch_index_bin), n_patches)));
        patch_index = patch_index(randperm(length(patch_index)));
    else
        patch_index = randsample(patch_index_bin, n_patches);
    end

    patch_index = reshape(patch_index, [n_trials, n_levels, n_blocks]);

    %% Load, crop and save images
    stimuli = zeros(ImgStats.Settings.surroundSizePix, ImgStats.Settings.surroundSizePix, ...
        n_trials, n_levels, n_blocks);

    for i_trial = 1:n_trials
        for i_level = 1:n_levels
            for i_block = 1:n_blocks
                stimuli(:, :, i_trial, i_level, i_block) = ...
                    lib.load_patch_at_index(ImgStats, patch_index(i_trial, i_level, i_block), ...
                    file_path_in, 0, 0);
            end
        end
    end
end
