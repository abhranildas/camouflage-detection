function [n_obs, mean_x, mean_y, mean_xy, mean_x2, mean_y2, corr_coeff] = ...
    combine_pairwise_stats(n_list, mean_x_list, mean_y_list, mean_xy_list, ...
    mean_x2_list, mean_y2_list, corr_coeff_list)
% COMBINE_PAIRWISE_STATS  Pool several groups' pairwise statistics into one.
%   [n_obs, mean_x, mean_y, mean_xy, mean_x2, mean_y2, corr_coeff] = ...
%       lib.combine_pairwise_stats(n_list, mean_x_list, mean_y_list, ...
%           mean_xy_list, mean_x2_list, mean_y2_list, corr_coeff_list)
%
%   Combines the seven lib.pairwise_stats statistics of several groups of
%   pairwise observations into the same seven statistics of the pooled
%   observations, without needing the raw observations.
%
%   Inputs
%     n_list, mean_x_list, mean_y_list, mean_xy_list, mean_x2_list,
%     mean_y2_list, corr_coeff_list - one list (vector) per group, of the
%     seven lib.pairwise_stats outputs for that group.
%
%   Output
%     n_obs, mean_x, mean_y, mean_xy, mean_x2, mean_y2, corr_coeff - the same
%     seven statistics, combined (n_obs is the pooled count; corr_coeff is
%     unused here, kept because lib.pairwise_stats returns it).
%
%   See also lib.PAIRWISE_STATS.

    n_obs = sum(n_list);
    freq_list = n_list/sum(n_obs);   % relative frequencies (row vector)

    mean_x = dot(freq_list, mean_x_list);
    mean_y = dot(freq_list, mean_y_list);
    mean_xy = dot(freq_list, mean_xy_list);
    mean_x2 = dot(freq_list, mean_x2_list);
    mean_y2 = dot(freq_list, mean_y2_list);
    corr_coeff = (mean_xy - mean_x*mean_y)/sqrt((mean_x2 - mean_x^2)*(mean_y2 - mean_y^2));
end
