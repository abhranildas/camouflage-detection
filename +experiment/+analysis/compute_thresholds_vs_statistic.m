function thresholds = compute_thresholds_vs_statistic(ImgStats, bin_index_levels, stat_type_str, ...
    exp_type_str, target_type_str, subjects_str, b_bootstrap, b_model)
%COMPUTE_THRESHOLDS_VS_STATISTIC  Plot detection threshold vs. a background statistic, per subject.
%
%   thresholds = experiment.analysis.COMPUTE_THRESHOLDS_VS_STATISTIC(ImgStats, ...
%       bin_index_levels, stat_type_str, exp_type_str, target_type_str, ...
%       subjects_str, b_bootstrap, b_model)
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
%   bin_index_levels   n_bins x 3, one row per (luminance, contrast,
%                    similarity) bin index to plot
%   stat_type_str      'contrast' or 'similarity', selects the x-axis
%                    statistic
%   exp_type_str       experiment type, passed through to
%                    computeThresholdInBin
%   target_type_str    target identifier, passed through to
%                    computeThresholdInBin and used to look up
%                    ImgStats.Settings.binCenters.Sa
%   subjects_str      n_subjects x k char array of subject identifiers
%   b_bootstrap       true to plot bootstrapped threshold error bars
%   b_model           true to overlay the template-matching-model prediction
%                    instead of the across-subject mean
%
% Output
%   thresholds  n_subjects x n_bins fitted threshold values
%
%   See also EXPERIMENT.ANALYSIS.COMPUTE_TEMPLATE_RESPONSE_SIGMA.

%% Compute thresholds for each subject and each bin
for i_subject = 1:size(subjects_str, 1)
    for i_bin = 1:size(bin_index_levels, 1)
        [thresholds(i_subject, i_bin), thresholds_sd(i_subject, i_bin)] = ...
            analysis.computeThresholdInBin(bin_index_levels(i_bin, :), exp_type_str, ...
                target_type_str, subjects_str(i_subject, :), 0, b_bootstrap);
    end
end

%% Plot thresholds vs statistics
if(strcmp(stat_type_str, 'contrast'))
    background_values = ImgStats.Settings.binCenters.C(bin_index_levels(:, 2));
    x_axis_label = 'Background Contrast';
elseif(strcmp(stat_type_str, 'similarity'))
    target_index = lib.target_index_from_string(ImgStats.Settings, target_type_str);
    background_values = ImgStats.Settings.binCenters.Sa(bin_index_levels(:, 3), target_index)';
    x_axis_label = 'Background Similarity';
end

figure; hold on;
axis square; box off;
set(gca, 'FontSize', 20);
set(gca, 'TickDir', 'out')
set(gcf, 'color', 'w');
% y_label_val = 0.5:0.1:1;
% set(gca, 'YTick', y_label_val);
% set(gca,'YTickLabel',sprintf('%1.1f\n',y_label_val));
x_label_val = background_values;
set(gca, 'XTick', background_values);
set(gca, 'XTickLabel', sprintf('%.3f\n', x_label_val));
xlabel(x_axis_label);
ylabel('Threshold Amplitude');
ylim([0 max(thresholds(:))*1.1]);

for i_subject = 1:size(subjects_str, 1)
    if(b_bootstrap)
        errorbar(background_values, thresholds(i_subject, :), thresholds_sd(i_subject, :), '-o', ...
            'MarkerSize', 11, 'MarkerFaceColor', 'auto', 'LineWidth', 2);
    else
        plot(background_values, thresholds(i_subject, :), '-o', 'MarkerSize', 11, ...
            'MarkerFaceColor', 'auto', 'LineWidth', 2);
    end
end

if(b_model)
    b_scale = 1;
    template_sigma = analysis.compute_template_response_sigma(ImgStats, target_type_str, b_scale);
    efficiency = 0.0001;
    for i_model_bin = 1:size(bin_index_levels, 1)
        model_amplitude(i_model_bin) = efficiency .* ...
            template_sigma(bin_index_levels(i_model_bin, 1), ...
            bin_index_levels(i_model_bin, 2), bin_index_levels(i_model_bin, 3));
    end
    plot(background_values, model_amplitude, '-ok', 'MarkerSize', 11, 'MarkerFaceColor', 'k', ...
        'LineWidth', 2);
else
    if(size(thresholds, 1) > 1)
        plot(background_values, mean(thresholds), '-ok', 'MarkerSize', 11, ...
            'MarkerFaceColor', 'k', 'LineWidth', 2);
    end
end

legend(subjects_str, 'Location', 'northwest');
legend('boxoff');
end
