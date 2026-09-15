function mahalanobis_dist = maha_dist(x, mean_val, cov_val)
% MAHA_DIST  Mahalanobis distance between observations and a Gaussian.
%   mahalanobis_dist = lib.maha_dist(x, mean_val, cov_val)
%
%   Inputs
%     x        - observations, col = variable, row = observation.
%     mean_val - Gaussian mean.
%     cov_val  - Gaussian covariance.
%
%   Output
%     mahalanobis_dist - column of Mahalanobis distances, one per
%                        observation (row of x).
%
%   See also lib.GAUSS_LLR.

    mahalanobis_dist = dot(x-mean_val, (x-mean_val)/cov_val, 2);
end
