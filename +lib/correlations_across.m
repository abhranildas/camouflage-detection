function [corr_vs_distance, distances, shift_stats_cross] = correlations_across(stim, mask)
% CORRELATIONS_ACROSS  Correlation coefficient across a boundary, vs distance.
%   [corr_vs_distance, distances, shift_stats_cross] = lib.correlations_across(stim, mask)
%
%   Computes correlation coefficients of pairs of points in a stimulus image
%   that fall on opposite sides of a boundary (given by mask), pooled by
%   pairwise distance.
%
%   Inputs
%     stim - square image, in normalised luminance units.
%     mask - logical image the same size as stim, true inside the boundary.
%
%   Output
%     corr_vs_distance - correlation coefficient across the boundary, one
%                         value per unique pairwise distance in distances.
%                         NaN where fewer than 2 pairs contribute.
%     distances         - the unique pairwise distances (pixels) that
%                          corr_vs_distance is evaluated at.
%     shift_stats_cross  - bg_size x (2*bg_size-1) x 7 array of
%                          lib.pairwise_stats statistics, one per row/column
%                          shift, for the pairs that cross the boundary.
%
%   See also lib.PAIRWISE_STATS, lib.COMBINE_PAIRWISE_STATS.

    %% 1. compute sufficient pairwise statistics for all x-y shifts
    % that can be combined to get correlation coefficients:

    bg_size = size(stim, 1);
    shift_stats_cross = nan(bg_size, 2*bg_size-1, 7);

    for shift_x = 0:bg_size-1
        for shift_y = -(bg_size-1):bg_size-1
            shift_y_1 = shift_y;
            shift_y_2 = -shift_y;

            y_start_1 = max(1-shift_y_1, 1);
            y_end_1 = min(bg_size-shift_y_1, bg_size);
            y_start_2 = max(1-shift_y_2, 1);
            y_end_2 = min(bg_size-shift_y_2, bg_size);

            stim_1 = stim(1:end-shift_x, y_start_1:y_end_1);
            stim_2 = stim(1+shift_x:end, y_start_2:y_end_2);

            mask_1 = mask(1:end-shift_x, y_start_1:y_end_1);
            mask_2 = mask(1+shift_x:end, y_start_2:y_end_2);

            stim_1_cross = stim_1(mask_1 ~= mask_2);
            stim_2_cross = stim_2(mask_1 ~= mask_2);

            shift_stats_cross(shift_x+1, shift_y+bg_size, :) = ...
                lib.pairwise_stats(stim_1_cross, stim_2_cross);
        end
    end

    % remove vertical reflection from being double-counted
    shift_stats_cross(1, bg_size+1:end, 1) = 0;

    %% 2. compute correlation coefficient vs distance by combining above
    % pairwise stats for each distance:

    shift_stats_cross_flat = reshape(shift_stats_cross, [bg_size*(2*bg_size-1), 7]);

    x_sq = repmat((0:bg_size-1).^2, [2*bg_size-1, 1]);              % array of x^2
    y_sq = repmat((-(bg_size-1):bg_size-1).^2, [bg_size, 1]);        % array of y^2
    dist_sq_mat = x_sq' + y_sq;   % matrix of dist^2 = x^2 + y^2
    dist_sq_list = unique(dist_sq_mat);
    distances = sqrt(dist_sq_list);
    corr_vs_distance = nan(numel(distances), 1);

    for i_dist = 1:numel(dist_sq_list)
        dist_sq = dist_sq_list(i_dist);

        % across boundary:
        dist_sq_stats_cross = shift_stats_cross_flat(...
            (dist_sq_mat == dist_sq) & (shift_stats_cross(:, :, 1) > 0), :);
        [~, ~, ~, ~, ~, ~, corr_coeff] = lib.combine_pairwise_stats(...
            dist_sq_stats_cross(:, 1), ...
            dist_sq_stats_cross(:, 2), ...
            dist_sq_stats_cross(:, 3), ...
            dist_sq_stats_cross(:, 4), ...
            dist_sq_stats_cross(:, 5), ...
            dist_sq_stats_cross(:, 6), ...
            dist_sq_stats_cross(:, 7));
        corr_vs_distance(i_dist) = corr_coeff;

    end

    % corr coeffs of 2 (x,y) pairs are computed to be inf. Make these nan.
    corr_vs_distance(isinf(corr_vs_distance)) = nan;
end
