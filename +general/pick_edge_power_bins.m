% pick_edge_power_bins  Interactively pick edge-power bin edges from the
%     blank/target edge-power histograms.
%
%     pick_edge_power_bins
%
% Script, no arguments. Expects `edge_powers` (N x 2, blank/target edge
% power, dimensionless) already in the workspace. Plots both histograms
% on a log y-axis; the bin edges are then chosen by hand (e.g. via
% `xline`, interactively) and written into `edgePowerBlockEdges` below —
% this is the hand-picking step `experiment.setUpExperiment`'s own
% commented-out automatic binning rule (T6.1) was replaced by.
%
% Inputs: workspace variable `edge_powers`, as above.
% Output: one figure (blank/target edge-power histograms);
%     `edgePowerBlockEdges` in the workspace, to be saved into the edge
%     power file and consumed by `experiment.setUpExperiment`. Nothing is
%     saved to disk by this script itself.
%
% See also experiment.setUpExperiment.

% load edge powers
histogram(edge_powers(:, 1))
hold on
histogram(edge_powers(:, 2))
ylim([60 60000])
set(gca, 'yscale', 'log')

% find leftmost and rightmost bin locations
candidate_bin_edges = linspace(.759, .899, 10);

% now use xline to mark bins, and add to:
edgePowerBlockEdges = [];

% then save edge_powers and block edges in the edge power file
% then run experiment.setUpExperiment
