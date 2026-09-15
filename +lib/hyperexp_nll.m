function nll = hyperexp_nll(x, lambda)
% HYPEREXP_NLL  Negative log likelihood under the hypoexponential distribution.
%   nll = lib.hyperexp_nll(x, lambda)
%
%   Log likelihood of a set of numbers under the hypoexponential
%   distribution (sum of two exponential variables). Despite the function's
%   name and this docstring's original wording ("hyperexponential"), the
%   density coded below is the hypoexponential one (a sum, not a mixture,
%   of two exponentials) — see B3.6 in the plan. Not fixed here (Stage 1 is
%   behaviour-preserving).
%
%   Inputs
%     x      - vector of observations, > 0.
%     lambda - 2-element rate vector, lambda(2) > lambda(1) > 0.
%
%   Output
%     nll - negative log likelihood of x under the distribution.
%
%   See also general.FIT_HYPEREXP_DIST.

    n_obs = numel(x);
    nll = -n_obs*log(lambda(1)*lambda(2)/(lambda(2)-lambda(1)))-...
        sum(log(exp(-lambda(1)*x)-exp(-lambda(2)*x)));
end
