function [p_correct, p_hit, p_correct_rejection, d_prime] = psychometricFun(x, mu, ...
    threshold_scale, slope, bias)
%PSYCHOMETRICFUN  Two-alternative (yes/no) psychometric function from a signal-detection model.
%
%   [p_correct, p_hit, p_correct_rejection, d_prime] = ...
%       experiment.analysis.PSYCHOMETRICFUN(x, mu, threshold_scale, slope, bias)
%
% A Weibull-shaped d' grows with the stimulus level x, then is converted to
% hit/correct-rejection probabilities with an asymmetric criterion set by
% bias.
%
% Inputs
%   x                stimulus level (units of the calling experiment, e.g.
%                    contrast or edge power)
%   mu               location shift, same units as x (always 0 in every
%                    caller in this repo)
%   threshold_scale  stimulus level at which d_prime = 1, same units as x
%   slope            Weibull shape exponent, dimensionless
%   bias             criterion asymmetry between hits and correct
%                    rejections, dimensionless, in (-1, 1)
%
% Output
%   p_correct            mean of p_hit and p_correct_rejection
%   p_hit                probability of a hit
%   p_correct_rejection  probability of a correct rejection
%   d_prime              sensitivity index at x
%
%   See also EXPERIMENT.ANALYSIS.COMPUTENEGLOGLIKELIHOOD, EXPERIMENT.ANALYSIS.FITPSYCHOMETRIC.

d_prime = (abs(x - mu) / threshold_scale).^slope .* sign(x - mu);
p_hit = normcdf(d_prime * (1 - bias) / 2);
p_correct_rejection = normcdf(d_prime * (1 + bias) / 2);
p_correct = (p_hit + p_correct_rejection) / 2;
end
