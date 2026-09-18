function [edge_threshold, exponent, sigma, threshold_sd, slope_sd, bias_sd, ...
    sessions_completed, target_means, p_correct_boot_sds, x_pmf, y_pmf] = ...
    compute_threshold_edge_response(...
    exp_type_str, subject_str, b_plot, b_bootstrap)
%COMPUTE_THRESHOLD_EDGE_RESPONSE  Fit the edge-response threshold, per subject or optimal.
%
%   [edge_threshold, exponent, sigma, threshold_sd, slope_sd, bias_sd, ...
%       sessions_completed, target_means, p_correct_boot_sds, x_pmf, y_pmf] = ...
%       experiment.analysis.COMPUTE_THRESHOLD_EDGE_RESPONSE(exp_type_str, subject_str, ...
%       b_plot, b_bootstrap)
%
% Fits experiment.analysis.compute_neg_log_likelihood_edge_response's
% [edge_threshold, exponent, sigma] to a subject's pooled contour-group data
% via fminsearch, or to the optimal-observer likelihood when subject_str is
% 'optimal'.
%
% The function line was renamed from computeThreshold to match the
% filename in tranche 0.1.1 (resolves B3.9); dispatch was always on the
% filename, so no call site changes.
%
% The %% Bootstrap section (b_bootstrap branch) references target_means,
% target_sds, exp_values, and threshold, none of which this function ever
% assigns — B3.10, pre-existing, not fixed here. Those four names are left
% exactly as found rather than renamed: this function's own fitted
% threshold-like parameter is edge_threshold (renamed from the ambiguous
% "th"), and giving it the name "threshold" instead — as its sibling
% compute_threshold_edge_power.m does — would have coincided with the
% currently-undefined "threshold" reference inside the Bootstrap section
% and silently supplied it a value, masking B3.10 rather than leaving it
% reproducible. The same section's other three undefined names, "a", "b"
% and "c" (also part of B3.10), are still undefined here but now spelled
% threshold_scale, slope and bias, matching the fit_psychometric vocabulary
% used in compute_threshold_edge_power.m/_texture_exponent.m — renaming them
% could not mask anything, since neither name is ever validly assigned in
% this file. See the tranche 0.1.5 findings log entry.
%
% Inputs
%   exp_type_str   experiment type, names the exp_files/<exp_type_str>/ folder
%   subject_str   subject identifier, or 'optimal' for the noiseless-observer
%                fit
%   b_plot        true to plot the fitted d' vs. proportion correct
%   b_bootstrap   true to bootstrap the standard errors below (B3.10: errors
%                on every call, see above)
%
% Output
%   edge_threshold        fitted lib.edge_response threshold parameter
%   exponent               fitted lib.edge_response exponent parameter,
%                          dimensionless
%   sigma                  fitted additional observation noise sd, same
%                          units as the edge response
%   threshold_sd, slope_sd, bias_sd, p_correct_boot_sds   never validly
%                          produced; see the B3.10 note above
%   sessions_completed     number of completed sessions pooled (undefined
%                          when subject_str is 'optimal', since that branch
%                          never sets it)
%   target_means           never assigned; see the B3.10 note above
%   x_pmf, y_pmf           unused
%
%   See also LIB.EDGE_RESPONSE, EXPERIMENT.ANALYSIS.COMPUTE_NEG_LOG_LIKELIHOOD_EDGE_RESPONSE.

    % Load in experiment settings file
    cfg = config();
    folder_exp = fullfile(cfg.paths.exp_files, exp_type_str);
    load(fullfile(folder_exp, 'exp_settings.mat'), 'ExpSettings');
    n_trials = ExpSettings.nTrials;
    n_levels = ExpSettings.nLevels;

    % Earlier plan to also pool a third contour-count group alongside
    % stim_l_groups/stim_e_groups, never finished (S3.16: T5.5)
%     stim_n_groups=[];
    stim_l_groups = [];
    stim_e_groups = [];
    b_target = logical([]);

    if strcmp(subject_str, 'optimal')
        b_opt = true;
        completed_bin_index = true(ExpSettings.nSessions, 1);
    else
        b_opt = false;
        % Load in subject file
        load(fullfile(folder_exp, 'subject_out', [subject_str '.mat']), 'SubjectExpFile');
        completed_bin_index = SubjectExpFile.levelCompleted == n_levels;
        sessions_completed = sum(completed_bin_index);
        if(sessions_completed == 0)
            error(['Error: Needed ' num2str(n_levels) ' levels to fit psychometric function.']);
        end
        disp(['Sessions used: ' num2str(sessions_completed)]);
        hit = logical([]);
        correct_reject = logical([]); % mirrors SubjectExpFile.correctRejection; name kept as-is
        correct = logical([]);
    end

    for i_session = 1:length(completed_bin_index)
        if(completed_bin_index(i_session))
%             stim_n_groups=[stim_n_groups; ExpSettings.stim_n_groups(:,:,idx)];
            stim_l_groups = [stim_l_groups; ExpSettings.stim_l_groups(:, :, i_session)];
            stim_e_groups = [stim_e_groups; ExpSettings.stim_e_groups(:, :, i_session)];
            b_target = [b_target; ExpSettings.bTargetPresent(:, :, i_session)];
            if ~b_opt
                hit = [hit; SubjectExpFile.hit(:, :, i_session)];
                correct_reject = [correct_reject; SubjectExpFile.correctRejection(:, :, i_session)];
                correct = [correct; SubjectExpFile.correct(:, :, i_session)];
            end
        end
    end

    n_targets = sum(b_target);
    n_blanks = sum(~b_target);
    if ~b_opt
        n_hits = sum(hit);
        n_correct_rejections = sum(correct_reject);
        p_correct = mean(correct); % prob. of correct
    end
    edge_threshold_init = 5;
    exponent_init = 0.1;
    sigma_init = 5;

    init = [edge_threshold_init exponent_init sigma_init];
    options = optimset('PlotFcns', @optimplotfval);
    if b_opt
        params = fminsearch(@(p) experiment.analysis.compute_neg_log_likelihood_edge_response(p, ...
            stim_l_groups, stim_e_groups, b_target, b_opt), init, options);
    else
        params = fminsearch(@(p) experiment.analysis.compute_neg_log_likelihood_edge_response(p, ...
            stim_l_groups, stim_e_groups, b_target, b_opt, n_blanks, n_targets, n_hits, ...
            n_correct_rejections), init, options);
    end
    edge_threshold = params(1);
    exponent = params(2);
    sigma = params(3);

    % Sketch of a two-stage fit (alpha/beta on top of the edge-response
    % parameters) that was never written (S3.16: T5.5)
    %     [alpha,beta] = experiment.analysis.fitPsychometric_edgeResponse(alpha_init, beta_init, stim_n_groups,stim_l_groups,stim_e_groups,b_target,num_blanks,num_targets, num_hits, num_cr);
    %     mu=0;
    %     threshold=mu+a;

    %% Figure properties
    if b_plot
        figure; hold on;
        if b_opt
            [~, p_correct, d_prime] = ...
                experiment.analysis.compute_neg_log_likelihood_edge_response(...
                params, stim_l_groups, stim_e_groups, b_target, b_opt);
        else
            [~, ~, d_prime] = experiment.analysis.compute_neg_log_likelihood_edge_response(...
                params, ...
                stim_l_groups, stim_e_groups, b_target, b_opt, n_blanks, n_targets, n_hits, ...
                n_correct_rejections);
        end
        %         r_t_means=r_t_means-mean(r_b_means);
        plot(d_prime, p_correct, 'ok', 'markerfacecolor', 'k', 'MarkerSize', 5);
        xlimit = xlim; xlim([0 xlimit(2)])
        fplot(@(x) experiment.analysis.psychometric_fun(x, 0, 1, 1, 0), xlim, 'k');
        %         xline(threshold,'color','k','Linewidth',1)
        %         xlim([0 1])
        %         ylim([0 1])
        xlabel("edge response d'"); ylabel('% correct')
        set(gca, 'FontSize', 13, 'TickDir', 'out', 'box', 'off', 'ytick', [.5 .75 1], ...
            'yticklabel', [50 75 100]);
    end

    %% Bootstrap — B3.10: errors every call (target_means/sds/exp_values/threshold undefined)
    if(b_bootstrap)
        n_boot = 500;
        p_correct_boot = nan(n_boot, n_levels);
        mu_boot = zeros(1, n_boot);
        threshold_scale_boot = nan(1, n_boot);
        slope_boot = nan(1, n_boot);
        bias_boot = nan(1, n_boot);
        for i_boot = 1:n_boot
            exp_values_boot = nan(n_trials, n_levels);
            target_means_boot = nan(1, n_levels);
            b_target_boot = false(n_trials, n_levels);
            hit_boot = false(n_trials, n_levels);
            correct_reject_boot = false(n_trials, n_levels);
            correct_boot = false(n_trials, n_levels);
            for i_boot_level = 1:n_levels
                [exp_level, boot_idx] = datasample(exp_values(:, i_boot_level), n_trials);
                exp_values_boot(:, i_boot_level) = exp_level;
                b_target_level = b_target(boot_idx', i_boot_level);
                b_target_boot(:, i_boot_level) = b_target_level;
                target_means_boot(i_boot_level) = mean(exp_level(b_target_level));
                hit_boot(:, i_boot_level) = hit(boot_idx', i_boot_level);
                correct_reject_boot(:, i_boot_level) = correct_reject(boot_idx', i_boot_level);
                correct_boot(:, i_boot_level) = correct(boot_idx', i_boot_level);
            end
            n_targets_boot = sum(b_target_boot);
            n_blanks_boot = sum(~b_target_boot);
            n_hits_boot = sum(hit_boot);
            n_correct_rejections_boot = sum(correct_reject_boot);

            p_correct_boot(i_boot, :) = mean(correct_boot);
            [threshold_scale_boot(i_boot), slope_boot(i_boot), bias_boot(i_boot)] = ...
                experiment.analysis.fit_psychometric(threshold_scale, slope, bias, ...
                target_means_boot, n_blanks_boot, n_targets_boot, n_hits_boot, ...
                n_correct_rejections_boot);
        end
        threshold_boot = mu_boot + threshold_scale_boot;
        threshold_sd = std(threshold_boot);
        slope_sd = std(slope_boot);
        bias_sd = std(bias_boot);
        p_correct_boot_sds = std(p_correct_boot);
        if(b_plot)
            for i_target_level = 1:length(target_means)
                rectangle('Position', ...
                    [target_means(i_target_level)-target_sds(i_target_level), ...
                    p_correct(i_target_level)-p_correct_boot_sds(i_target_level), ...
                    2*target_sds(i_target_level), 2*p_correct_boot_sds(i_target_level)], ...
                    'facecolor', [0 0 0 .1], 'edgecolor', 'none')
            end
        end
        % mark threshold errorband:
        rectangle('Position', [threshold-threshold_sd 0 2*threshold_sd 1], ...
            'facecolor', [0 0 0 .1], 'edgecolor', 'none')
    end
end
