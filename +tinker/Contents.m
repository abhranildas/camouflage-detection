% +tinker  (package namespace: tinker.*)
% Scratch/exploratory scripts and small helper functions for developing
% and cross-checking the pink-noise stimulus and whitening machinery in
% +lib/. Most files here are cell-by-cell scripts, not called with
% arguments; a few are small helper functions reused by those scripts.
%
% Call functions/scripts as tinker.<name>. Requires the repo root on the
% MATLAB path (see setup.m).
%
% Pink-noise synthesis and theory
%   tinker.pink_noise                       - exploratory script: 1-D/2-D
%     pink noise via FFT filtering and manual inverse-DFT summation,
%     sampled vs. theoretical distributions and autocorrelations
%   tinker.pink_noise_line                  - synthesize a 1-D pink-noise
%     sample by explicit sinusoid summation
%   tinker.pink_noise_square_manual         - synthesize a 2-D pink-noise
%     sample by explicit plane-wave summation
%   tinker.pink_noise_dist                  - theoretical point-value
%     distribution of 1-D/2-D pink noise
%   tinker.pink_noise_line_dist             - theoretical point-value
%     distribution of 1-D pink noise, log-spaced frequency range
%   tinker.spatial_pattern                  - general 1/f^beta spatial
%     noise generator (Yearsley 2004); not camouflage-detection-specific
%   tinker.coloured_noise_cubes             - render a 1/f noise volume
%     as an animated GIF
%
% Whitening and edge-energy sampling
%   tinker.whitening_tinker                 - exploratory script: 1/f
%     whitening/pinkening filters in 1-D, and their effect on a
%     mismatch-detection template's response
%   tinker.pink_noise_seed_multiple_energies - batch-samples several
%     edge-energy measures across seeds, appends to stored data (O2.2)
%   tinker.whitened_pink_noise_edge_energy  - batch-samples grad_by_norm
%     edge energy on whitened stimuli across seeds, appends to stored data
%   tinker.pink_noise_stimuli_autocorrelations - point-pair correlation
%     vs. separation distance, across a target boundary (B3.21: two
%     later cells reference undefined variables)
%
% Other
%   tinker.new_psychometric                 - psychometric-function shape
%     vs. noise SD and bias (name predates this cleanup; see 3.1.1)
%   tinker.show_example_stimuli             - display a grid of example
%     camouflage stimuli across edge-energy levels
