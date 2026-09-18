% +vis  (package namespace: vis.*)
% Plotting and display scripts/functions: patch-grid viewers, edge-energy
% distribution plots, and psychometric-function plots. No file in this
% package is called by anything outside it.
%
% Call functions/scripts as vis.<name>. Requires the repo root on the
% MATLAB path (see setup.m). Several files here are scripts, not
% functions — run cell by cell, not called with arguments.
%
% Patch viewers (R. C. Walshe's, renamed to snake_case in tranche 0.1.1;
% known callers of B2.15, lib.crop_image's always-overridden indColorChannels)
%   vis.show_example_patches     - grid of patches from one luminance bin (BUG: the
%     bSave branch references undefined variables L/targetNr, new/B2)
%   vis.show_patch_grid          - grid of patches from one luminance/contrast/
%     similarity bin
%   vis.show_patches_one_by_one  - step through patches in a bin one at a time
%
% Edge-energy distributions and histograms
%   vis.plot_edge_strength_dists - blank-vs-target edge-energy distributions,
%     pairwise scatterplots, and a rotating 3D scatter GIF
%   vis.plot_edge_energy_hists   - overlaid blank/target edge-energy
%     histograms
%
% Psychometric plots (BUG: both call analysis.computeThresholdInBin, which
% does not exist anywhere in this repo; both error if run, new/B2)
%   vis.plot_psychometrics_vs_angle    - psychometric functions and thresholds vs.
%     visual angle (viewing distance)
%   vis.plot_psychometrics_vs_duration - psychometric functions and thresholds vs.
%     stimulus duration
%
% Display
%   vis.show_image - display a stimulus image, marking clipped pixels
