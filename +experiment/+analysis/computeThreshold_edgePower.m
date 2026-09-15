function [threshold, slope, bias, threshold_sd, slope_sd, bias_sd, sessions_completed, ...
    target_means, p_correct_boot_sds, x_pmf, y_pmf] = computeThreshold_edgePower(expTypeStr, ...
    subjectStr, bPlot, bBootstrap)
%COMPUTETHRESHOLD_EDGEPOWER  Fit the edge-power detection threshold for one subject's session data.
%
%   [threshold, slope, bias, threshold_sd, slope_sd, bias_sd, ...
%       sessions_completed, target_means, p_correct_boot_sds, x_pmf, y_pmf] = ...
%       experiment.analysis.COMPUTETHRESHOLD_EDGEPOWER(expTypeStr, ...
%       subjectStr, bPlot, bBootstrap)
%
% Loads a subject's completed sessions from exp_files/<expTypeStr>/, pools
% the edge-power values across them, and fits
% experiment.analysis.psychometricFun to the per-level hit/correct-rejection
% counts via experiment.analysis.fitPsychometric.
%
% x_pmf and y_pmf are declared but never assigned on any path (pre-existing,
% not introduced by this pass).
%
% Inputs
%   expTypeStr   experiment type, names the exp_files/<expTypeStr>/ folder
%   subjectStr   subject identifier, names the subject_out/<subjectStr>.mat
%                file
%   bPlot        true to plot the fitted psychometric function
%   bBootstrap   true to bootstrap the standard errors below
%
% Output
%   threshold             fitted edge power at which d' = 1
%   slope                 fitted Weibull shape exponent, dimensionless
%   bias                  fitted criterion asymmetry, dimensionless
%   threshold_sd          bootstrapped sd of threshold (bBootstrap only)
%   slope_sd              bootstrapped sd of slope (bBootstrap only)
%   bias_sd               bootstrapped sd of bias (bBootstrap only)
%   sessions_completed     number of completed sessions pooled
%   target_means           per-level mean edge power on target-present trials
%   p_correct_boot_sds    bootstrapped sd of proportion correct, per level
%                         (bBootstrap only)
%   x_pmf, y_pmf          unused; see note above
%
%   See also EXPERIMENT.ANALYSIS.FITPSYCHOMETRIC, EXPERIMENT.ANALYSIS.PSYCHOMETRICFUN.

    % Load in experiment settings file
    load(['./exp_files/' expTypeStr '/exp_settings.mat'], 'ExpSettings');

    % Load in subject experiment file
    load(['./exp_files/' expTypeStr '/subject_out/' subjectStr '.mat'], 'SubjectExpFile');

    nTrials = size(SubjectExpFile.correct, 1);
    nLevels = size(SubjectExpFile.correct, 2);
    completedBinIndex = SubjectExpFile.levelCompleted == nLevels;
    sessions_completed = sum(completedBinIndex);

    if(sessions_completed == 0)
        error(['Error: Needed ' num2str(nLevels) ' levels to fit psychometric function.']);
    end

    exp_values = [];
    bTarget = logical([]);
    hit = logical([]);
    correct_reject = logical([]); % mirrors SubjectExpFile.correctRejection; name kept as-is
    correct = logical([]);

    % Superseded by the live mu = 0 below, same decision as
    % experiment.analysis.computeNegLogLikelihood's T5.1 (S3.16: T5.4)
%     blank_mean=mean(SubjectExpFile.edgePowers(~SubjectExpFile.bTargetPresent));

    if(bPlot)
        disp(['Sessions used: ' num2str(sessions_completed)]);
    end

    for iSession = 1:length(completedBinIndex)
        if(completedBinIndex(iSession))
            exp_values = [exp_values; ExpSettings.edgePowers(:, :, iSession)];
            bTarget = [bTarget; SubjectExpFile.bTargetPresent(:, :, iSession)];
            hit = [hit; SubjectExpFile.hit(:, :, iSession)];
            correct_reject = [correct_reject; SubjectExpFile.correctRejection(:, :, iSession)];
            correct = [correct; SubjectExpFile.correct(:, :, iSession)];
        end
    end

    n_targets = sum(bTarget);
    n_blanks = sum(~bTarget);
    n_hits = sum(hit);
    n_correct_rejections = sum(correct_reject);

    target_means = nan(1, nLevels);
    target_sds = nan(1, nLevels);
    for iTargetLevel = 1:nLevels
        exp_level = exp_values(:, iTargetLevel);
        bTarget_level = bTarget(:, iTargetLevel);
        target_means(iTargetLevel) = mean(exp_level(bTarget_level));
        target_sds(iTargetLevel) = std(exp_level(bTarget_level));
    end

    p_correct = mean(correct); % prob. of correct

    % Superseded by the live mu = 0 below (S3.16: T5.4)
%     mu_init=blank_mean;
    threshold_scale_init = mean(target_means);
    slope_init = 1;
    bias_init = 0;
    [threshold_scale, slope, bias] = experiment.analysis.fitPsychometric(threshold_scale_init, ...
        slope_init, bias_init, target_means, n_blanks, n_targets, n_hits, n_correct_rejections);
    mu = 0;
    threshold = mu + threshold_scale;

    %% Figure properties
    if bPlot
        hold on;
        plot(target_means, p_correct, 'ok', 'markerfacecolor', 'k', 'MarkerSize', 5);
        fplot(@(x) experiment.analysis.psychometricFun(x, mu, threshold_scale, slope, bias), ...
            [mu 1], 'k');
        xline(threshold, 'color', 'k', 'Linewidth', 1)
%         xlim([0 1])
        ylim([0 1])
        xlabel('edge power'); ylabel('% correct')
        set(gca, 'FontSize', 13, 'TickDir', 'out', 'box', 'off', 'ytick', [.5 .75 1], ...
            'yticklabel', [50 75 100]);
    end

    %% Bootstrap
    if(bBootstrap)
        n_boot = 500;
        p_correct_boot = nan(n_boot, nLevels);
        mu_boot = zeros(1, n_boot);
        threshold_scale_boot = nan(1, n_boot);
        slope_boot = nan(1, n_boot);
        bias_boot = nan(1, n_boot);
        for iBoot = 1:n_boot
            exp_values_boot = nan(nTrials, nLevels);
            target_means_boot = nan(1, nLevels);
            bTarget_boot = false(nTrials, nLevels);
            hit_boot = false(nTrials, nLevels);
            correct_reject_boot = false(nTrials, nLevels);
            correct_boot = false(nTrials, nLevels);
            for iBootLevel = 1:nLevels
                [exp_level, boot_idx] = datasample(exp_values(:, iBootLevel), nTrials);
                exp_values_boot(:, iBootLevel) = exp_level;
                bTarget_level = bTarget(boot_idx', iBootLevel);
                bTarget_boot(:, iBootLevel) = bTarget_level;
                target_means_boot(iBootLevel) = mean(exp_level(bTarget_level));
                hit_boot(:, iBootLevel) = hit(boot_idx', iBootLevel);
                correct_reject_boot(:, iBootLevel) = correct_reject(boot_idx', iBootLevel);
                correct_boot(:, iBootLevel) = correct(boot_idx', iBootLevel);
            end
            n_targets_boot = sum(bTarget_boot);
            n_blanks_boot = sum(~bTarget_boot);
            n_hits_boot = sum(hit_boot);
            n_correct_rejections_boot = sum(correct_reject_boot);

            p_correct_boot(iBoot, :) = mean(correct_boot);
            [threshold_scale_boot(iBoot), slope_boot(iBoot), bias_boot(iBoot)] = ...
                experiment.analysis.fitPsychometric(threshold_scale, slope, bias, ...
                target_means_boot, n_blanks_boot, n_targets_boot, n_hits_boot, ...
                n_correct_rejections_boot);
        end
        threshold_boot = mu_boot + threshold_scale_boot;
        mu_sd = std(mu_boot);
        threshold_sd = std(threshold_boot);
        slope_sd = std(slope_boot);
        bias_sd = std(bias_boot);
        p_correct_boot_sds = std(p_correct_boot);
        if(bPlot)
            for iTargetLevel = 1:length(target_means)
                rectangle('Position', ...
                    [target_means(iTargetLevel)-target_sds(iTargetLevel), ...
                    p_correct(iTargetLevel)-p_correct_boot_sds(iTargetLevel), ...
                    2*target_sds(iTargetLevel), 2*p_correct_boot_sds(iTargetLevel)], ...
                    'facecolor', [0 0 0 .5], 'edgecolor', 'none')
            end
        end
        % mark threshold errorband:
        rectangle('Position', [threshold-threshold_sd 0 2*threshold_sd 1], ...
            'facecolor', [0 0 0 .1], 'edgecolor', 'none')
    end
end
