% plot_psychometrics_vs_angle  Plot psychometric functions and fitted thresholds
%     across viewing distance (visual angle per pixel).
%
%     plot_psychometrics_vs_angle
%
% Script, no arguments. For each pixels-per-degree value in `ppd_values`,
% loads the matching '1fnoise' experiment (named by luminance/contrast, and
% by ppd when ppd is not the base 60), fits a threshold with
% `analysis.computeThresholdInBin`, and plots the per-level accuracy points,
% the fitted psychometric curve, and the threshold, each offset along the
% visual-angle axis (64/ppd, in degrees).
%
% BUG (new, B2-level): `analysis.computeThresholdInBin` does not exist —
% no `+analysis/` package exists anywhere in this repo (the fitting
% functions live in `+experiment/+analysis/`, and no function named
% `computeThresholdInBin` exists there either). Every call below errors
% immediately with "Undefined function 'analysis.computeThresholdInBin'".
% Left as found.
%
% Inputs: exp_files/1fnoise_L<luminance>_C<contrast>[_D<ppd>]/... on disk
%     (read inside analysis.computeThresholdInBin, which does not exist).
% Output: one 3D figure (per-level accuracy, fitted curve, and threshold
%     line for each ppd value, plus a threshold-vs-angle curve).
%
% See also experiment.analysis.computeThreshold_edgePower.

luminance = .5; contrast = .15;
figure(1); hold on
blue = [0 0 255]/255; red = [255 0 0]/255;
ppd_values = [60 80 100 120];
for i_ppd = 1:numel(ppd_values)
    ppd = ppd_values(i_ppd);
    if ppd == 60
        exp_name = ['1fnoise_L' num2str(luminance) '_C' num2str(contrast)];
    else
        exp_name = ['1fnoise_L' num2str(luminance) '_C' num2str(contrast) '_D' num2str(ppd)];
    end
    [threshold, threshold_std, ~, ~, ~, exp_levels, mean_pc, std_pc, x_pmf, y_pmf] = ...
        analysis.computeThresholdInBin(exp_name, 'ad', 1, 1);
    thresholds(i_ppd) = threshold;
    figure(1)
    color = (blue*(numel(ppd_values)-i_ppd+1)+red*(i_ppd-1))/numel(ppd_values);
    plot3(64./(ppd*ones(1, 10)), exp_levels, mean_pc, 'ok', 'MarkerSize', 6, ...
        'MarkerFaceColor', color);
    % errorbar(exp_levels, mean_pc, std_pc, 'ok', 'MarkerSize', 7, 'MarkerFaceColor', 'w', ...
    %     'LineWidth', 1);
    plot3(64/ppd*ones(1, numel(x_pmf)), x_pmf, y_pmf, 'Color', color, 'LineWidth', 2);
    plot3(64/ppd*[1 1], threshold*[1 1], [.5 .7], '--', 'Color', color, 'LineWidth', 1);
end

plot3(64./ppd_values, thresholds, 0.5*ones(1, numel(ppd_values)), 'k', 'Marker', 'x', ...
    'MarkerSize', 8, 'LineWidth', 1);

xlim([.5 1.1])
xlabel({'visual angle', '(deg)'})

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
