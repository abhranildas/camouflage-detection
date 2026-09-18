% TEST_ERLANG  Plot the density of a sum of two exponentials.
%   Script, no arguments.
%
%   Plots (exp(-r1*x) - exp(-r2*x))*r1*r2/(r2 - r1), the probability density
%   of the sum of two independent exponential variables with rates r1 and r2.
%   With two different rates this is a hypoexponential density; the Erlang in
%   the filename is the special case of equal rates, which this is not. Same
%   confusion as lib.hyperexp_nll, which also fits a hypoexponential.
%
%   Inputs
%     none.
%
%   Output
%     none (side effect: one figure).
%
%   See also lib.hyperexp_nll, general.fit_hyperexp_dist, exppdf.

rate_1 = 1/300;  % rate of the first exponential, per unit x
rate_2 = 1/10;  % rate of the second exponential, per unit x
x_max = 1500;  % largest x to plot, same units as 1/rate
x = 1:x_max/1000:x_max;
density = (exp(-rate_1*x) - exp(-rate_2*x))*rate_2*rate_1/(rate_2 - rate_1);
figure
plot(x, density);
