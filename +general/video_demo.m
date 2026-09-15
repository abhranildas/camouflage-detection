% video_demo  Sample many random target placements, rank them by edge
%     energy, and display the top-ranked stimulus.
%
%     video_demo
%
% Script, no arguments. Draws `n_samples` random target locations/
% orientations, scores each with `lib.edge_energy`, sorts by edge energy,
% and displays the lowest-scoring (first-row) sample.
%
% BUG (new, B2-level): `lib.stimulus` takes only name-value arguments
% (via `inputParser`) — see its own header. The calls below
% (`lib.stimulus(texture_params, seed, bg_size, target_radius, ...)`)
% pass everything positionally instead, so `inputParser` receives a
% struct where it expects a parameter-name string. Both calls (line 16
% and the display call at the end) error immediately if this script is
% run as written. Left as found.
%
% Inputs: none from disk; all parameters below are literals.
% Output: `vislab-common/data/video_demo.mat` (`stim_energy`, N x 4:
%     target row, target col, target orientation in degrees, edge
%     energy); one displayed image (if the calls above did not error).
%
% See also lib.stimulus, lib.edge_energy.

kernel_size = [1 3];
luminance = 0.5;
contrast = 0.15;
target_radius = 50;
bg_size = 500;
texture_params.type = 'pink_noise';
seed = 1;
n_samples = 5e5;
stim_energy = nan(n_samples, 4);
tic
parfor i_sample = 1:n_samples
    i_sample
    rng('shuffle');
    target_loc = datasample(target_radius+1:bg_size-target_radius, 2);
    target_or = unifrnd(0, 360);
    stim = lib.stimulus(texture_params, seed, bg_size, target_radius, target_loc, target_or, ...
        luminance, contrast, luminance, contrast);
    edge_energy = lib.edge_energy(stim, target_radius, target_loc, kernel_size, 'perp_ratio');
    stim_energy(i_sample, :) = [target_loc target_or edge_energy]
end
toc

stim_energy = sortrows(stim_energy, 4);
save('vislab-common/data/video_demo.mat', 'stim_energy');

% see one of these images
i_sample = 1;
target_loc = stim_energy(i_sample, [1 2]);
target_or = stim_energy(i_sample, 3);
stim = lib.stimulus(texture_params, seed, bg_size, target_radius, target_loc, target_or, ...
    luminance, contrast, luminance, contrast);
vis.show_image(stim);
