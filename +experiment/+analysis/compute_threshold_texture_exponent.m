function [threshold, slope, bias, threshold_sd, slope_sd, bias_sd, sessions_completed, ...
    target_means, p_correct_boot_sds, x_pmf, y_pmf] = compute_threshold_texture_exponent(...
    exp_type_str, subject_str, b_plot, b_bootstrap)
%COMPUTE_THRESHOLD_TEXTURE_EXPONENT  Fit the texture-exponent detection threshold for a subject.
%
%   [threshold, slope, bias, threshold_sd, slope_sd, bias_sd, ...
%       sessions_completed, target_means, p_correct_boot_sds, x_pmf, y_pmf] = ...
%       experiment.analysis.COMPUTE_THRESHOLD_TEXTURE_EXPONENT(exp_type_str, ...
%       subject_str, b_plot, b_bootstrap)
%
% Loads a subject's completed sessions from exp_files/<exp_type_str>/, pools
% the per-level texture exponents (ExpSettings.alphas — B2.6: this branch of
% the _texture_exponent family may instead have ExpSettings.nBlocks in place
% of ExpSettings.nLevels on disk, not checked by this file), and fits
% experiment.analysis.psychometric_fun to the per-level hit/correct-rejection
% counts via experiment.analysis.fit_psychometric.
%
% x_pmf and y_pmf are declared but never assigned on any path (pre-existing,
% not introduced by this pass).
%
% Inputs
%   exp_type_str   experiment type, names the exp_files/<exp_type_str>/ folder
%   subject_str   subject identifier, names the subject_out/<subject_str>.mat
%                file
%   b_plot        true to plot the fitted psychometric function
%   b_bootstrap   true to bootstrap the standard errors below
%
% Output
%   threshold             fitted texture exponent at which d' = 1
%   slope                 fitted Weibull shape exponent, dimensionless
%   bias                  fitted criterion asymmetry, dimensionless
%   threshold_sd          bootstrapped sd of threshold (b_bootstrap only)
%   slope_sd              bootstrapped sd of slope (b_bootstrap only)
%   bias_sd               bootstrapped sd of bias (b_bootstrap only)
%   sessions_completed     number of completed sessions pooled
%   target_means           per-level mean texture exponent on target-present
%                          trials
%   p_correct_boot_sds    bootstrapped sd of proportion correct, per level
%                         (b_bootstrap only)
%   x_pmf, y_pmf          unused; see note above
%
%   See also EXPERIMENT.ANALYSIS.FIT_PSYCHOMETRIC, EXPERIMENT.ANALYSIS.PSYCHOMETRIC_FUN.

    % Load in experiment file
    load(['./exp_files/' exp_type_str '/exp_settings.mat'], 'ExpSettings');

    % Load in subject file
    load(['./exp_files/' exp_type_str '/subject_out/' subject_str '.mat'], 'SubjectExpFile');

    n_trials = ExpSettings.nTrials;
    n_levels = ExpSettings.nLevels;
    completed_bin_index = SubjectExpFile.levelCompleted == n_levels;
    sessions_completed = sum(completed_bin_index);

    if(sessions_completed == 0)
        error(['Error: Needed ' num2str(n_levels) ' levels to fit psychometric function.']);
    end

    exp_values = [];
    b_target = logical([]);
    hit = logical([]);
    correct_reject = logical([]); % mirrors SubjectExpFile.correctRejection; name kept as-is
    correct = logical([]);

    if(b_plot)
        disp(['Sessions used: ' num2str(sessions_completed)]);
    end

    for i_session = 1:length(completed_bin_index)
        if(completed_bin_index(i_session))
            exp_values = [exp_values; repmat(ExpSettings.alphas, [n_trials 1])];
            b_target = [b_target; SubjectExpFile.bTargetPresent(:, :, i_session)];
            hit = [hit; SubjectExpFile.hit(:, :, i_session)];
            correct_reject = [correct_reject; SubjectExpFile.correctRejection(:, :, i_session)];
            correct = [correct; SubjectExpFile.correct(:, :, i_session)];
        end
    end

    n_targets = sum(b_target);
    n_blanks = sum(~b_target);
    n_hits = sum(hit);
    n_correct_rejections = sum(correct_reject);

    target_means = nan(1, n_levels);
    target_sds = nan(1, n_levels);
    for i_target_level = 1:n_levels
        exp_level = exp_values(:, i_target_level);
        b_target_level = b_target(:, i_target_level);
        target_means(i_target_level) = mean(exp_level(b_target_level));
        target_sds(i_target_level) = std(exp_level(b_target_level));
    end

    p_correct = mean(correct); % prob. of correct

    % Superseded by the live mu = 0 below, same decision as
    % experiment.analysis.compute_neg_log_likelihood's T5.1 (S3.16: T5.4)
%     mu_init=blank_mean;
    threshold_scale_init = mean(target_means);
    slope_init = 1;
    bias_init = 0;
    [threshold_scale, slope, bias] = experiment.analysis.fit_psychometric(threshold_scale_init, ...
        slope_init, bias_init, target_means, n_blanks, n_targets, n_hits, n_correct_rejections);
    mu = 0;
    threshold = mu + threshold_scale;

    %% Figure properties
    if b_plot
        hold on;
        plot(target_means, p_correct, '.g', 'MarkerSize', 15);
        fplot(@(x) experiment.analysis.psychometric_fun(x, mu, threshold_scale, slope, bias), ...
            [mu ExpSettings.alphas(end)], 'g');
        xline(threshold, 'color', 'g', 'Linewidth', 1)
        %ylim([.5 1])
        xlabel('texture exponent \alpha'); ylabel('% correct')
        set(gca, 'FontSize', 13, 'TickDir', 'out', 'box', 'off', 'ytick', [.5 .75 1], ...
            'yticklabel', [50 75 100]);
    end

    %% Bootstrap
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
%             for i=1:length(target_means)
%                 rectangle('Position',[target_means(i)-.01, p_c(i)-p_correct_boot_sds(i), .02, 2*p_correct_boot_sds(i)],...
%                     'facecolor',[0 0 0 .1], 'edgecolor','none')
%             end
            errorbar(target_means, p_correct, p_correct_boot_sds, ...
                'linestyle', 'none', 'color', 'g');
        end
        % mark threshold errorband:
        rectangle('Position', [threshold-threshold_sd 0 2*threshold_sd 1], ...
            'facecolor', [0 1 0 .1], 'edgecolor', 'none')
    end
end
