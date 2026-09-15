% fit_hyperexp_dist  Fit a two-rate hyperexponential distribution to a
%     pooled edge-property statistic by maximum likelihood.
%
%     fit_hyperexp_dist
%
% Script, no arguments. Expects `edge_props_b` (a struct array with an
% `.ep16` field) already in the workspace.
%
% Inputs: workspace variable `edge_props_b.ep16`.
% Output: one figure, the pdf histogram of the data overlaid with the
%     fitted hyperexponential density. `lambda` (the two fitted rates)
%     left in the workspace. Nothing is saved to disk.
%
% See also lib.hyperexp_nll.

x = [edge_props_b.ep16];

A = [-1 0; 1 -1]; b = [0 0];

mean_x = mean(x); var_x = var(x);

% initial guesses for lambda_1 and lambda_2
% are made from the mean and sd, see journal notes:
initial_lambda = 2./(mean_x+sqrt(2*var_x-mean_x^2)*[1 -1]);
% force the lambda_2 to be larger:
initial_lambda(2) = max(initial_lambda(2), initial_lambda(1)+eps)

lambda = fmincon(@(lambda) lib.hyperexp_nll(x, lambda), initial_lambda, A, b)

figure; hold on
histogram(x, 'normalization', 'pdf', 'edgecolor', 'none');
fplot(@(x) lambda(1)*lambda(2)/(lambda(2)-lambda(1))*(exp(-lambda(1)*x)-exp(-lambda(2)*x)), ...
    [0 max(x)])
