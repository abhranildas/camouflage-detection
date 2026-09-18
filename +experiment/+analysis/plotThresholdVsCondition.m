%PLOTTHRESHOLDVSCONDITION_MINE  Plot detection threshold vs. condition, with error bars.
%
% Ad-hoc script, not a function: plots a pre-existing workspace variable
% dur (columns: condition, threshold, threshold error) as an error-bar plot.
% dur is never assigned anywhere in this script or by any caller in the
% repo (B2.17, new, not fixed here) — running this script directly errors
% immediately with "Unrecognized function or variable 'dur'".

figure
errorbar(dur(:, 1), dur(:, 2), dur(:, 3), '-ok', 'linewidth', 1, 'markersize', 7, ...
    'MarkerFaceColor', 'w')
%xlim([0 .16])
ylim([.3 .52])
set(gca, 'XTick', [0 200])
set(gca, 'YTick', [0.3 0.5])
xlabel 'contrast'
ylabel 'detection threshold'
set(gca, 'TickDir', 'out')
set(gca, 'Fontsize', 13)
box off
