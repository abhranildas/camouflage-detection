function [threshold_scale, slope, bias] = fitPsychometric(threshold_scale_init, slope_init, ...
    bias_init, target_means, n_blanks, n_targets, n_hits, n_correct_rejections)
%FITPSYCHOMETRIC  Fit the signal-detection psychometric model by maximum likelihood.
%
%   [threshold_scale, slope, bias] = experiment.analysis.FITPSYCHOMETRIC(...
%       threshold_scale_init, slope_init, bias_init, target_means, ...
%       n_blanks, n_targets, n_hits, n_correct_rejections)
%
% Minimizes experiment.analysis.computeNegLogLikelihood with fminsearch,
% fitting the three free parameters of experiment.analysis.psychometricFun
% (mu fixed at 0).
%
% Inputs
%   threshold_scale_init    initial guess for threshold_scale, same units as
%                           target_means
%   slope_init              initial guess for slope, dimensionless
%   bias_init                initial guess for bias, dimensionless, in (-1, 1)
%   target_means             per-level mean stimulus value for target-present
%                             trials, same units as threshold_scale
%   n_blanks                 trial count with no target, per level
%   n_targets                trial count with a target, per level
%   n_hits                   hit count, per level
%   n_correct_rejections     correct-rejection count, per level
%
% Output
%   threshold_scale  fitted stimulus level at which d' = 1, same units as
%                    target_means
%   slope            fitted Weibull shape exponent, dimensionless
%   bias             fitted criterion asymmetry, dimensionless
%
%   See also EXPERIMENT.ANALYSIS.COMPUTENEGLOGLIKELIHOOD, EXPERIMENT.ANALYSIS.PSYCHOMETRICFUN.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%% Fit model
% Earlier version computed target_means itself from raw per-trial values,
% superseded by the caller (e.g. computeThreshold_edgePower) passing
% target_means in directly (S3.16: T5.3)
% n_levels=size(exp_values,2);
%
% % means of blanks and targets in each level
% mu_blanks=nan(1,n_levels);
% mu_targets=nan(1,n_levels);
%
% for level=1:n_levels
%     x_level=exp_values(:,level);
%     blanks_level=~bTargetPresent(:,level);
%     mu_blanks(level)=mean(x_level(blanks_level));
%     targets_level=bTargetPresent(:,level);
%     mu_targets(level)=mean(x_level(targets_level));
% end

options = optimset('TolX', 1e-3);
init = [threshold_scale_init slope_init bias_init];

params = fminsearch(@(p) experiment.analysis.computeNegLogLikelihood(p, target_means, ...
    n_blanks, n_targets, n_hits, n_correct_rejections), init, options);

% mu=params(1);
threshold_scale = params(1);
slope = params(2);
bias = params(3);
end
