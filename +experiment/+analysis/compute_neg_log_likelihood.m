function neg_log_likelihood = compute_neg_log_likelihood(p, target_means, n_blanks, n_targets, ...
    n_hits, n_correct_rejections)
%COMPUTE_NEG_LOG_LIKELIHOOD  Negative log likelihood of a signal-detection psychometric model.
%
%   neg_log_likelihood = experiment.analysis.COMPUTE_NEG_LOG_LIKELIHOOD(p, ...
%       target_means, n_blanks, n_targets, n_hits, n_correct_rejections)
%
% Packs the three free parameters of experiment.analysis.psychometric_fun
% (threshold_scale, slope, bias, with mu fixed at 0) into the vector p, so
% this is the objective fminsearch minimizes inside
% experiment.analysis.fit_psychometric.
%
% Inputs
%   p                       [threshold_scale, slope, bias], dimensionless
%                           except threshold_scale (same units as
%                           target_means)
%   target_means            per-level mean stimulus value for target-present
%                           trials, same units as p(1)
%   n_blanks                trial count with no target, per level
%   n_targets               trial count with a target, per level
%   n_hits                  hit count, per level
%   n_correct_rejections    correct-rejection count, per level
%
% Output
%   neg_log_likelihood  negative log likelihood, +Inf outside the parameter
%                       domain (threshold_scale > 0, slope > 0, -1 < bias < 1)
%
%   See also EXPERIMENT.ANALYSIS.FIT_PSYCHOMETRIC, EXPERIMENT.ANALYSIS.PSYCHOMETRIC_FUN.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%% Earlier 4-parameter version, superseded by fixing mu = 0 (S3.16: T5.1)
%     mu=p(1);
    %mu=0;
    threshold_scale = p(1);
    slope = p(2);
    bias = p(3);

    % Earlier per-trial-response likelihood, superseded by the summarized
    % per-level hit/correct-rejection binomial counts below (S3.16: T5.1)
    % y_bm=(blank_mean/a).^b;
    % yc=d/2;
    % y=(x/a).^b;

    % yc=y_bm+(y_t-y_bm)*(c+1)/2;

    % z=y-yc;
    if threshold_scale > 0 && slope > 0 && bias > -1 && bias < 1
        %         ll=sum(log(normcdf(z(response)/2)))+... % response target
        %      + sum(log(normcdf(d(~response),'upper'))); % response blank

        d_prime = (abs(target_means) / threshold_scale).^slope .* sign(target_means);
        p_hit = normcdf(d_prime * (1 - bias) / 2);
        p_correct_rejection = normcdf(d_prime * (1 + bias) / 2);
%         p_c=(p_h+p_cr)/2; % prob. of correct

%         p_c=normcdf(d/2);
        log_likelihood = sum(log(binopdf(n_hits, n_targets, p_hit))) + ...
           sum(log(binopdf(n_correct_rejections, n_blanks, p_correct_rejection)));
        neg_log_likelihood = -log_likelihood;
    else
        neg_log_likelihood = inf;
    end
end
