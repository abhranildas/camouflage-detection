function llr = gauss_llr(x, mean_a, cov_a, mean_b, cov_b)
% GAUSS_LLR  Log likelihood ratio of an observation under two Gaussians.
%   llr = lib.gauss_llr(x, mean_a, cov_a, mean_b, cov_b)
%
%   Log likelihood ratio of observation x belonging to Gaussian a vs
%   Gaussian b.
%
%   Inputs
%     x            - observation(s).
%     mean_a, cov_a - mean and covariance of Gaussian a.
%     mean_b, cov_b - mean and covariance of Gaussian b.
%
%   Output
%     llr - log likelihood ratio, positive favouring a.
%
%   See also lib.MAHA_DIST.

    llr = (lib.maha_dist(x, mean_b, cov_b) - lib.maha_dist(x, mean_a, cov_a)...
        + log(det(cov_b)/det(cov_a)))/2;
end
