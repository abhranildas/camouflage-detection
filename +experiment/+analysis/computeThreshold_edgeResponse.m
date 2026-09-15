function [edge_threshold, exponent, sigma, threshold_sd, slope_sd, bias_sd, ...
    sessions_completed, target_means, p_correct_boot_sds, x_pmf, y_pmf] = computeThreshold(...
    expTypeStr, subjectStr, bPlot, bBootstrap)
%COMPUTETHRESHOLD  Fit the edge-response detection threshold for a subject, or the optimal observer.
%
%   [edge_threshold, exponent, sigma, threshold_sd, slope_sd, bias_sd, ...
%       sessions_completed, target_means, p_correct_boot_sds, x_pmf, y_pmf] = ...
%       experiment.analysis.COMPUTETHRESHOLD(expTypeStr, subjectStr, bPlot, bBootstrap)
%
% Fits experiment.analysis.computeNegLogLikelihood_edgeResponse's
% [edge_threshold, exponent, sigma] to a subject's pooled contour-group data
% via fminsearch, or to the optimal-observer likelihood when subjectStr is
% 'optimal'.
%
% This file is named computeThreshold_edgeResponse.m but the function
% inside is named computeThreshold (B3.9, pre-existing, not fixed here).
%
% The %% Bootstrap section (bBootstrap branch) references target_means,
% target_sds, exp_values, and threshold, none of which this function ever
% assigns — B3.10, pre-existing, not fixed here. Those four names are left
% exactly as found rather than renamed: this function's own fitted
% threshold-like parameter is edge_threshold (renamed from the ambiguous
% "th"), and giving it the name "threshold" instead — as its sibling
% computeThreshold_edgePower.m does — would have coincided with the
% currently-undefined "threshold" reference inside the Bootstrap section
% and silently supplied it a value, masking B3.10 rather than leaving it
% reproducible. The same section's other three undefined names, "a", "b"
% and "c" (also part of B3.10), are still undefined here but now spelled
% threshold_scale, slope and bias, matching the fitPsychometric vocabulary
% used in computeThreshold_edgePower.m/_texture_exponent.m — renaming them
% could not mask anything, since neither name is ever validly assigned in
% this file. See the tranche 0.1.5 findings log entry.
%
% Inputs
%   expTypeStr   experiment type, names the exp_files/<expTypeStr>/ folder
%   subjectStr   subject identifier, or 'optimal' for the noiseless-observer
%                fit
%   bPlot        true to plot the fitted d' vs. proportion correct
%   bBootstrap   true to bootstrap the standard errors below (B3.10: errors
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
%                          when subjectStr is 'optimal', since that branch
%                          never sets it)
%   target_means           never assigned; see the B3.10 note above
%   x_pmf, y_pmf           unused
%
%   See also LIB.EDGE_RESPONSE, EXPERIMENT.ANALYSIS.COMPUTENEGLOGLIKELIHOOD_EDGERESPONSE.

    % Load in experiment settings file
    load(['./exp_files/' expTypeStr '/exp_settings.mat'], 'ExpSettings');
    nTrials = ExpSettings.nTrials;
    nLevels = ExpSettings.nLevels;

    % Earlier plan to also pool a third contour-count group alongside
    % stim_l_groups/stim_e_groups, never finished (S3.16: T5.5)
%     stim_n_groups=[];
    stim_l_groups = [];
    stim_e_groups = [];
    bTarget = logical([]);

    if strcmp(subjectStr, 'optimal')
        bOpt = true;
        completedBinIndex = true(ExpSettings.nSessions, 1);
    else
        bOpt = false;
        % Load in subject file
        load(['./exp_files/' expTypeStr '/subject_out/' subjectStr '.mat'], 'SubjectExpFile');
        completedBinIndex = SubjectExpFile.levelCompleted == nLevels;
        sessions_completed = sum(completedBinIndex);
        if(sessions_completed == 0)
            error(['Error: Needed ' num2str(nLevels) ' levels to fit psychometric function.']);
        end
        disp(['Sessions used: ' num2str(sessions_completed)]);
        hit = logical([]);
        correct_reject = logical([]); % mirrors SubjectExpFile.correctRejection; name kept as-is
        correct = logical([]);
    end

    for iSession = 1:length(completedBinIndex)
        if(completedBinIndex(iSession))
%             stim_n_groups=[stim_n_groups; ExpSettings.stim_n_groups(:,:,idx)];
            stim_l_groups = [stim_l_groups; ExpSettings.stim_l_groups(:, :, iSession)];
            stim_e_groups = [stim_e_groups; ExpSettings.stim_e_groups(:, :, iSession)];
            bTarget = [bTarget; ExpSettings.bTargetPresent(:, :, iSession)];
            if ~bOpt
                hit = [hit; SubjectExpFile.hit(:, :, iSession)];
                correct_reject = [correct_reject; SubjectExpFile.correctRejection(:, :, iSession)];
                correct = [correct; SubjectExpFile.correct(:, :, iSession)];
            end
        end
    end

    n_targets = sum(bTarget);
    n_blanks = sum(~bTarget);
    if ~bOpt
        n_hits = sum(hit);
        n_correct_rejections = sum(correct_reject);
        p_correct = mean(correct); % prob. of correct
    end
    edge_threshold_init = 5;
    exponent_init = 0.1;
    sigma_init = 5;

    init = [edge_threshold_init exponent_init sigma_init];
    options = optimset('PlotFcns', @optimplotfval);
    if bOpt
        params = fminsearch(@(p) experiment.analysis.computeNegLogLikelihood_edgeResponse(p, ...
            stim_l_groups, stim_e_groups, bTarget, bOpt), init, options);
    else
        params = fminsearch(@(p) experiment.analysis.computeNegLogLikelihood_edgeResponse(p, ...
            stim_l_groups, stim_e_groups, bTarget, bOpt, n_blanks, n_targets, n_hits, ...
            n_correct_rejections), init, options);
    end
    edge_threshold = params(1);
    exponent = params(2);
    sigma = params(3);

    % Sketch of a two-stage fit (alpha/beta on top of the edge-response
    % parameters) that was never written (S3.16: T5.5)
    %     [alpha,beta] = experiment.analysis.fitPsychometric_edgeResponse(alpha_init, beta_init, stim_n_groups,stim_l_groups,stim_e_groups,bTarget,num_blanks,num_targets, num_hits, num_cr);
    %     mu=0;
    %     threshold=mu+a;

    %% Figure properties
    if bPlot
        figure; hold on;
        if bOpt
            [~, p_correct, d_prime] = experiment.analysis.computeNegLogLikelihood_edgeResponse(...
                params, stim_l_groups, stim_e_groups, bTarget, bOpt);
        else
            [~, ~, d_prime] = experiment.analysis.computeNegLogLikelihood_edgeResponse(params, ...
                stim_l_groups, stim_e_groups, bTarget, bOpt, n_blanks, n_targets, n_hits, ...
                n_correct_rejections);
        end
        %         r_t_means=r_t_means-mean(r_b_means);
        plot(d_prime, p_correct, 'ok', 'markerfacecolor', 'k', 'MarkerSize', 5);
        xlimit = xlim; xlim([0 xlimit(2)])
        fplot(@(x) experiment.analysis.psychometricFun(x, 0, 1, 1, 0), xlim, 'k');
        %         xline(threshold,'color','k','Linewidth',1)
        %         xlim([0 1])
        %         ylim([0 1])
        xlabel("edge response d'"); ylabel('% correct')
        set(gca, 'FontSize', 13, 'TickDir', 'out', 'box', 'off', 'ytick', [.5 .75 1], ...
            'yticklabel', [50 75 100]);
    end

    %% Bootstrap — B3.10: errors every call (target_means/sds/exp_values/threshold undefined)
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
                    'facecolor', [0 0 0 .1], 'edgecolor', 'none')
            end
        end
        % mark threshold errorband:
        rectangle('Position', [threshold-threshold_sd 0 2*threshold_sd 1], ...
            'facecolor', [0 0 0 .1], 'edgecolor', 'none')
    end
end
