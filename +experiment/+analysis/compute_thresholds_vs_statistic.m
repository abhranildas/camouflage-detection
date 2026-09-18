function thresholds = compute_thresholds_vs_statistic(ImgStats, binIndexLevels, statTypeStr, ...
    expTypeStr, targetTypeStr, subjectsStr, bBootstrap, bModel)
%COMPUTE_THRESHOLDS_VS_STATISTIC  Plot detection threshold vs. a background statistic, per subject.
%
%   thresholds = experiment.analysis.COMPUTE_THRESHOLDS_VS_STATISTIC(ImgStats, ...
%       binIndexLevels, statTypeStr, expTypeStr, targetTypeStr, ...
%       subjectsStr, bBootstrap, bModel)
%
% Computes each subject's threshold in every requested bin via
% analysis.computeThresholdInBin (unresolved — B2.9, pre-existing, not fixed
% here: no top-level +analysis package exists, so this call errors), then
% plots threshold vs. the chosen background statistic (contrast or
% target/background similarity), optionally overlaying an efficiency-scaled
% template-matching-model prediction.
%
% Inputs
%   ImgStats         image-statistics struct, as built by the (out-of-scope,
%                    excluded) +stats/ package
%   binIndexLevels   n_bins x 3, one row per (luminance, contrast,
%                    similarity) bin index to plot
%   statTypeStr      'contrast' or 'similarity', selects the x-axis
%                    statistic
%   expTypeStr       experiment type, passed through to
%                    computeThresholdInBin
%   targetTypeStr    target identifier, passed through to
%                    computeThresholdInBin and used to look up
%                    ImgStats.Settings.binCenters.Sa
%   subjectsStr      n_subjects x k char array of subject identifiers
%   bBootstrap       true to plot bootstrapped threshold error bars
%   bModel           true to overlay the template-matching-model prediction
%                    instead of the across-subject mean
%
% Output
%   thresholds  n_subjects x n_bins fitted threshold values
%
%   See also EXPERIMENT.ANALYSIS.COMPUTE_TEMPLATE_RESPONSE_SIGMA.

%% Compute thresholds for each subject and each bin
for iSubject = 1:size(subjectsStr, 1)
    for iBin = 1:size(binIndexLevels, 1)
        [thresholds(iSubject, iBin), thresholdsStd(iSubject, iBin)] = ...
            analysis.computeThresholdInBin(binIndexLevels(iBin, :), expTypeStr, ...
                targetTypeStr, subjectsStr(iSubject, :), 0, bBootstrap);
    end
end

%% Plot thresholds vs statistics
if(strcmp(statTypeStr, 'contrast'))
    backgroundValues = ImgStats.Settings.binCenters.C(binIndexLevels(:, 2));
    xAxisLabel = 'Background Contrast';
elseif(strcmp(statTypeStr, 'similarity'))
    targetIndex = lib.target_index_from_string(ImgStats.Settings, targetTypeStr);
    backgroundValues = ImgStats.Settings.binCenters.Sa(binIndexLevels(:, 3), targetIndex)';
    xAxisLabel = 'Background Similarity';
end

figure; hold on;
axis square; box off;
set(gca, 'FontSize', 20);
set(gca, 'TickDir', 'out')
set(gcf, 'color', 'w');
% yLabelVal = 0.5:0.1:1;
% set(gca, 'YTick', yLabelVal);
% set(gca,'YTickLabel',sprintf('%1.1f\n',yLabelVal));
xLabelVal = backgroundValues;
set(gca, 'XTick', backgroundValues);
set(gca, 'XTickLabel', sprintf('%.3f\n', xLabelVal));
xlabel(xAxisLabel);
ylabel('Threshold Amplitude');
ylim([0 max(thresholds(:))*1.1]);

for iSubject = 1:size(subjectsStr, 1)
    if(bBootstrap)
        errorbar(backgroundValues, thresholds(iSubject, :), thresholdsStd(iSubject, :), '-o', ...
            'MarkerSize', 11, 'MarkerFaceColor', 'auto', 'LineWidth', 2);
    else
        plot(backgroundValues, thresholds(iSubject, :), '-o', 'MarkerSize', 11, ...
            'MarkerFaceColor', 'auto', 'LineWidth', 2);
    end
end

if(bModel)
    bScale = 1;
    templateSigma = analysis.compute_template_response_sigma(ImgStats, targetTypeStr, bScale);
    efficiency = 0.0001;
    for iModelBin = 1:size(binIndexLevels, 1)
        modelAmplitude(iModelBin) = efficiency .* templateSigma(binIndexLevels(iModelBin, 1), ...
            binIndexLevels(iModelBin, 2), binIndexLevels(iModelBin, 3));
    end
    plot(backgroundValues, modelAmplitude, '-ok', 'MarkerSize', 11, 'MarkerFaceColor', 'k', ...
        'LineWidth', 2);
else
    if(size(thresholds, 1) > 1)
        plot(backgroundValues, mean(thresholds), '-ok', 'MarkerSize', 11, ...
            'MarkerFaceColor', 'k', 'LineWidth', 2);
    end
end

legend(subjectsStr, 'Location', 'northwest');
legend('boxoff');
end
