function [neg_log_likelihood, p_correct, d_prime] = compute_neg_log_likelihood_edge_response(p, ...
    stim_l_groups, stim_e_groups, b_target, b_opt, n_blanks, n_targets, n_hits, ...
    n_correct_rejections)
%COMPUTE_NEG_LOG_LIKELIHOOD_EDGE_RESPONSE  Negative log likelihood of the edge-response model.
%
%   [neg_log_likelihood, p_correct, d_prime] = ...
%       experiment.analysis.COMPUTE_NEG_LOG_LIKELIHOOD_EDGE_RESPONSE(p, ...
%       stim_l_groups, stim_e_groups, b_target, b_opt, n_blanks, n_targets, ...
%       n_hits, n_correct_rejections)
%
% Pools per-contour-group lengths and edge energies into a per-trial edge
% response via lib.edge_response, then compares the blank-level and
% target-level response distributions to get d'. This is the objective
% fminsearch minimizes inside experiment.analysis.compute_threshold_edge_response.
%
% Inputs
%   p                       [threshold, exponent, sigma] passed to
%                           lib.edge_response; sigma is additional
%                           observation noise sd, same units as the edge
%                           response
%   stim_l_groups           per-trial cell array of contour-group lengths
%   stim_e_groups           per-trial cell array of contour-group edge
%                           energies
%   b_target                 trials x levels logical, true where a target is
%                           present
%   b_opt                    true for the optimal (noiseless-observer)
%                           likelihood; false to fit against n_hits/n_correct_rejections
%   n_blanks                trial count with no target, per level (unused
%                           when b_opt is true)
%   n_targets               trial count with a target, per level (unused on
%                           either branch: see file header note)
%   n_hits                  hit count, per level (unused when b_opt is true)
%   n_correct_rejections    correct-rejection count, per level (unused when
%                           b_opt is true)
%
% Output
%   neg_log_likelihood  negative log likelihood, +Inf outside the parameter
%                       domain (threshold > 0, exponent > 0, sigma > 0)
%   p_correct           probability of a correct response at each level,
%                       ignoring bias
%   d_prime             sensitivity index at each level
%
% n_targets is accepted but never read on either branch: the bias-aware
% likelihood that would use it (n_hits vs n_targets, n_correct_rejections vs
% n_blanks) is commented out below in favour of a combined-correct binomial
% likelihood. See the header note below.
%
%   See also LIB.EDGE_RESPONSE, EXPERIMENT.ANALYSIS.COMPUTE_THRESHOLD_EDGE_RESPONSE.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

    threshold = p(1);
    exponent = p(2);
    sigma = p(3);

    n_trials = size(b_target, 1);
    n_levels = size(b_target, 2);

    if threshold > 0 && exponent > 0 && sigma > 0
        % edge responses
        edge_response = cellfun(@(l, e) lib.edge_response(l, e, threshold, exponent), ...
            stim_l_groups, stim_e_groups);

        % mean and sd of edge responses for blanks and targets in each level
        response_blank_means = nan(1, n_levels);
        response_blank_sds = nan(1, n_levels);
        response_target_means = nan(1, n_levels);
        response_target_sds = nan(1, n_levels);
        for i_level = 1:n_levels
            response_level = edge_response(:, i_level);
            response_blank_level = response_level(~b_target(:, i_level));
            response_target_level = response_level(b_target(:, i_level));
            response_blank_means(i_level) = mean(response_blank_level);
            response_blank_sds(i_level) = sqrt(var(response_blank_level) + sigma^2);
            response_target_means(i_level) = mean(response_target_level);
            response_target_sds(i_level) = sqrt(var(response_target_level) + sigma^2);
        end

        % d'_e
        d_prime = abs(response_target_means - response_blank_means) ./ ...
            ((response_blank_sds + response_target_sds) / 2);

        % ignoring bias
        p_correct = normcdf(d_prime / 2);
        if b_opt
            log_likelihood = mean(p_correct);
        else
            log_likelihood = sum(log(binopdf(n_hits + n_correct_rejections, n_trials, p_correct)));
        end

        % incorporating bias (S3.16: T5.2)
%         p_h=normcdf(d*(1-gamma)/2); % prob. of hits
%         p_cr=normcdf(d*(1+gamma)/2); % prob. of correct rejection
%         p_c=(p_h+p_cr)/2; % prob. of correct
%         ll=sum(log(binopdf(num_hits,num_targets,p_h)))+...
%             sum(log(binopdf(num_cr,num_blanks,p_cr)));

        neg_log_likelihood = -log_likelihood;
    else
        neg_log_likelihood = inf;
    end
end
