% plot_psychometrics_vs_duration  Plot psychometric functions and fitted thresholds
%     across stimulus duration.
%
%     plot_psychometrics_vs_duration
%
% Script, no arguments. For each duration (ms) in `dur_values`, loads the
% matching '1fnoise' experiment (named by luminance/contrast, and by
% duration when it is not the base 200 ms), fits a threshold with
% `analysis.computeThresholdInBin`, and plots the per-level accuracy points,
% the fitted psychometric curve, and the threshold, each offset along the
% duration axis.
%
% BUG (new, B2-level): `analysis.computeThresholdInBin` does not exist —
% no `+analysis/` package exists anywhere in this repo (the fitting
% functions live in `+experiment/+analysis/`, and no function named
% `computeThresholdInBin` exists there either). Every call below errors
% immediately with "Undefined function 'analysis.computeThresholdInBin'".
% Left as found.
%
% Inputs: exp_files/1fnoise_L<luminance>_C<contrast>[_T<duration>]/... on
%     disk (read inside analysis.computeThresholdInBin, which does not
%     exist).
% Output: one 3D figure (per-level accuracy, fitted curve, and threshold
%     line for each duration, plus a threshold-vs-duration curve).
%
% See also experiment.analysis.compute_threshold_edge_power.

luminance = .5; contrast = .15;
figure(1); hold on
blue = [0 0 255]/255; red = [255 0 0]/255;
dur_values = [50 100 200 400 800];
for i_dur = 1:numel(dur_values)
    dur = dur_values(i_dur);
    if dur == 200
        exp_name = ['1fnoise_L' num2str(luminance) '_C' num2str(contrast)];
    else
        exp_name = ['1fnoise_L' num2str(luminance) '_C' num2str(contrast) '_T' num2str(dur)];
    end
    [threshold, threshold_std, ~, ~, ~, exp_levels, mean_pc, std_pc, x_pmf, y_pmf] = ...
        analysis.computeThresholdInBin(exp_name, 'ad', 1, 1);
    thresholds(i_dur) = threshold;
    figure(1)
    color = (blue*(numel(dur_values)-i_dur+1)+red*(i_dur-1))/numel(dur_values);
    plot3(dur*ones(1, 10), exp_levels, mean_pc, 'ok', 'MarkerSize', 6, ...
        'MarkerFaceColor', color);
    % errorbar(exp_levels, mean_pc, std_pc, 'ok', 'MarkerSize', 7, 'MarkerFaceColor', 'w', ...
    %     'LineWidth', 1);
    plot3(dur*ones(1, numel(x_pmf)), x_pmf, y_pmf, 'Color', color, 'LineWidth', 2);
    plot3(dur*[1 1], threshold*[1 1], [.5 .7], '--', 'Color', color, 'LineWidth', 1);
end

plot3(dur_values, thresholds, 0.5*ones(1, numel(dur_values)), 'k', 'Marker', 'x', ...
    'MarkerSize', 8, 'LineWidth', 1);

xlim([50 800])
set(gca, 'xscale', 'log')
xlabel({'duration', '(ms)'})
set(gca, 'xtick', dur_values);

ylabel 'edge strength'
ylim([0 1.5])
set(gca, 'ytick', 0:.5:1.5);
set(gca, 'yticklabel', {'0', '', '', '1.5'});

zlabel 'detection accuracy'
zlim([.5 1])
set(gca, 'ztick', .5:.1:1);
set(gca, 'zticklabel', {'50%', '', '', '', '', '100%'});
grid on
set(gca, 'FontSize', 13)
