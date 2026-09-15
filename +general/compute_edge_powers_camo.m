% compute_edge_powers_camo  Append ideal-observer blank/target edge powers
%     for a Portilla-Simoncelli camouflage texture to the shipped
%     `edge_powers_camo.mat` sample pool.
%
%     compute_edge_powers_camo
%
% Script, no arguments. Synthesises a Portilla-Simoncelli texture model
% from `camo.png`, then draws `n_samples` seeded stimulus pairs
% (blank/target) from it and scores each with `lib.edge_vector_ideal` +
% `lib.edge_measures_ideal`, appending to whatever the `.mat` file already
% holds.
%
% NOTE: `bg_size`, `kernel_sigma`, `luminance`/`contrast` and `n_spectrum`
% below are set but never passed to `lib.stimulus`/`lib.edge_vector_ideal`
% (which hardcode 0.5/0.15 for `ml_b`/`cont_b` and use their own
% defaults). Left as found.
%
% Inputs: `vislab-common/data/natural/edge_powers_camo.mat` (`edge_powers`,
%     appended to if present); `vislab-common/data/textures/natural/
%     camo.png` (source texture for the P-S synthesis model).
% Output: `vislab-common/data/natural/edge_powers_camo.mat` (`edge_powers`,
%     N x 2, blank/target ideal edge power, dimensionless).
%
% See also general.compute_edge_powers_camo_large, general.compute_edge_powers_pink_noise.

bg_size = 256;
luminance = 0.5;
contrast = 0.15;
target_radius = 64;

n_samples = 2e4-116;
kernel_sigma = 1;
n_edge = 1e4;  % # of elements in edge vector
n_spectrum = floor(n_edge/2)+1;  % # of items in edge spectrum

if exist('vislab-common/data/natural/edge_powers_camo.mat', 'file') == 2
    load('vislab-common/data/natural/edge_powers_camo.mat')
    sample_start = size(edge_powers, 1)+1;
    edge_powers = [edge_powers; nan(n_samples, 2)];
else
    edge_powers = nan(n_samples, 2);
    sample_start = 1;
end

% pink noise texture
% texture.type='pink_noise';

% Portilla-Simoncelli texture
addpath(genpath('por_sim_tx_synth'))
source_image_path = 'vislab-common/data/textures/natural/camo.png';
source_image_grey = double(im2gray(imread(source_image_path)));
n_scales = 4;  % Number of scales
n_orientations = 4;  % Number of orientations
% Spatial neighborhood is neighborhood_size x neighborhood_size coefficients
neighborhood_size = 9;
n_synthesis_iter = 25;  % Number of iterations of synthesis loop
texture = struct;
texture.type = 'ps';
texture.stats = textureAnalysis(source_image_grey, n_scales, n_orientations, neighborhood_size);
texture.Niter = n_synthesis_iter;

tic
parfor seed = sample_start:sample_start+n_samples-1
    seed
    [stim_t, stim_b] = lib.stimulus('seed', seed, 'texture', texture, 'ml_b', 0.5, ...
        'cont_b', 0.15, 'target_radius', target_radius);
    edge_power_b = lib.edge_measures_ideal(lib.edge_vector_ideal(stim_b));
    edge_power_t = lib.edge_measures_ideal(lib.edge_vector_ideal(stim_t));
    edge_powers(seed, :) = [edge_power_b, edge_power_t];
end
toc

save('vislab-common/data/natural/edge_powers_camo.mat', 'edge_powers')
