function stats = pairwise_stats(x, y)
% PAIRWISE_STATS  Sufficient statistics of a set of paired observations.
%   stats = lib.pairwise_stats(x, y)
%
%   Computes the seven numbers that lib.combine_pairwise_stats needs to pool
%   several such groups into one correlation coefficient, without keeping the
%   raw observations around.
%
%   Inputs
%     x, y - equal-length vectors of paired observations, any units.
%
%   Output
%     stats - 1x7 row vector [n_obs, mean_x, mean_y, mean_xy, mean_x2,
%             mean_y2, corr_coeff]: sample count, the two means, the mean
%             cross-product, the two mean squares, and the Pearson
%             correlation coefficient of x and y.
%
%   See also lib.COMBINE_PAIRWISE_STATS.

    x = x(:);
    y = y(:);
    if numel(x) ~= numel(y)
        error('The number of observations in the two lists are different.');
    end

    n_obs = numel(x);
    mean_x = mean(x);
    mean_y = mean(y);
    mean_xy = mean(x.*y);
    mean_x2 = mean(x.^2);
    mean_y2 = mean(y.^2);
    corr_coeff = (mean_xy - mean_x*mean_y)/sqrt((mean_x2 - mean_x^2)*(mean_y2 - mean_y^2));
    stats = [n_obs, mean_x, mean_y, mean_xy, mean_x2, mean_y2, corr_coeff];
end
