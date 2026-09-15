% compute_edge_powers_pink_noise  Compute ideal-observer blank/target edge
%     powers for 1000 pink-noise-texture stimulus pairs.
%
%     compute_edge_powers_pink_noise
%
% Script, no arguments. Sibling of `general.compute_edge_powers_camo`, cut
% down to a quick pink-noise check: the Portilla-Simoncelli synthesis
% block and the append-to-existing-file logic are both commented out here
% (dead, see below), and the result is neither preallocated nor saved.
%
% NOTE: `n_samples` is set but never used — the loop below runs
% `seed = 1:1e3` regardless. `bg_size`, `kernel_sigma`, `luminance`/
% `contrast` and `n_spectrum` are set but never passed to `lib.stimulus`/
% `lib.edge_vector_ideal` either. `edge_powers_new` grows one row per
% iteration with no preallocation (Stage 2 AGROW candidate, not fixed
% here). Left as found.
%
% Inputs: none from disk (the append-existing-file load is commented out).
% Output: `edge_powers_new` in the workspace (N x 2, blank/target ideal
%     edge power, dimensionless). Nothing is saved to disk — the `save`
%     call is commented out.
%
% See also general.compute_edge_powers_camo, general.compute_edge_powers_camo_large.

bg_size = 256;
luminance = 0.5;
contrast = 0.15;
target_radius = 64;

n_samples = 2e4-116;
kernel_sigma = 1;
n_edge = 1e4;  % # of elements in edge vector
n_spectrum = floor(n_edge/2)+1;  % # of items in edge spectrum

% if exist('vislab-common/data/natural/edge_powers_camo.mat','file')==2
%     load('vislab-common/data/natural/edge_powers_camo.mat')
%     sample_start=size(edge_powers,1)+1;
%     edge_powers=[edge_powers;nan(n_samples,2)];
% else
%     edge_powers=nan(n_samples,2);
%     sample_start=1;
% end

% pink noise texture
texture.type = 'pink_noise';

% % Portilla-Simoncelli texture
% addpath(genpath('por_sim_tx_synth'))
% input_img='vislab-common/data/textures/natural/camo.png';
% im0=double(im2gray(imread(input_img)));
% Nsc = 4; % Number of scales
% Nor = 4; % Number of orientations
% Na = 9;  % Spatial neighborhood is Na x Na coefficients
% Niter = 25;	% Number of iterations of synthesis loop
% texture=struct;
% texture.type='ps';
% texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
% texture.Niter=Niter;

tic
for seed = 1:1e3
    seed
    [stim_t, stim_b] = lib.stimulus('seed', seed, 'texture', texture, 'ml_b', 0.5, ...
        'cont_b', 0.15, 'target_radius', target_radius);
    edge_power_b = lib.edge_measures_ideal(lib.edge_vector_ideal(stim_b));
    edge_power_t = lib.edge_measures_ideal(lib.edge_vector_ideal(stim_t));
    edge_powers_new(seed, :) = [edge_power_b, edge_power_t];
end
toc

% save('vislab-common/data/natural/edge_powers_camo.mat','edge_powers')
