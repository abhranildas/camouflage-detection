function cost = edge_fit_cost(scale, dprimes)
% EDGE_FIT_COST  Sum-of-squares cost for scaling model d' onto subject d'.
%   cost = lib.edge_fit_cost(scale, dprimes)
%
%   One free parameter, an efficiency-like scale factor applied to the model's
%   d' before comparing it with the subject's, summed over experiments.
%
%   Inputs
%     scale   - scalar multiplier applied to the model d'. Dimensionless.
%     dprimes - n_experiments x 2 cell array. Column 1 holds the subject d'
%               vector for that experiment, column 2 the model d' vector of
%               the same length. Both dimensionless.
%
%   Output
%     cost - scalar sum over experiments of the squared residuals
%            subject_dprime - scale*model_dprime.
%
%   The column convention (1 = subject, 2 = model) matters: mixing the two up
%   is what B1.9 records in +general/fit_edge_model_with_exps.m.
%
%   SUMSQR comes from the Deep Learning Toolbox; this function errors without
%   it.
%
%   See also lib.EDGE_RESPONSE, SUMSQR, FMINSEARCH.

    cost = 0;
    for i_exp = 1:size(dprimes, 1)
        cost = cost + sumsqr(dprimes{i_exp, 1} - scale*dprimes{i_exp, 2});
    end
end
