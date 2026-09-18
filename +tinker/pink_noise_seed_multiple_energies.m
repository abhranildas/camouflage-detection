% pink_noise_seed_multiple_energies  Sample multiple edge-energy measures across seeds.
%
%     pink_noise_seed_multiple_energies
%
% Script, no arguments. For a batch of pink-noise stimulus seeds,
% computes several edge-energy measures (magnitude, cosine, normal,
% three gradient-normalized variants, perp_ratio) on both the blank and
% target stimulus, appending to a stored table so repeated runs extend
% rather than overwrite it.
%
% Inputs: none (all parameters are literals below).
% Output: none returned (script); appends to
% vislab-common/data/seed_multiple_energies_symmetric.mat's frozen
% seed_energy variable (seed, then one blank/target energy pair per
% energy type).
%
% See also lib.stimulus, lib.edge_energy.

bg_size = 256;
target_radius = 64;
texture_params.type = 'pink_noise';
luminance = .5;
contrast = .15;

n_samples = 1e5;

kernel_size = [1 3];

if exist('vislab-common/data/seed_multiple_energies_symmetric.mat', 'file') == 2
    load('vislab-common/data/seed_multiple_energies_symmetric.mat')
    sample_start = seed_energy(end, 1)+1;
    seed_energy = [seed_energy;nan(n_samples, 15)];
else
    seed_energy = nan(n_samples, 15);
    sample_start = 1;
end

tic
parfor seed = sample_start:sample_start+n_samples-1
    seed

    % blank
    pink_noise_blank = lib.stimulus(texture_params, seed, bg_size, 0, 'center', 0, ...
        luminance, contrast, 'match', 'match');
    % figure; imagesc(stim_b); colormap gray; axis image; colorbar
    % img_whitened_b=lib.reverse_pink_noise_square(pink_noise_blank);
    % figure; imagesc(wn_reverse_b); colormap gray; axis image; colorbar

    % target
    pink_noise_target = lib.stimulus(texture_params, seed, bg_size, target_radius, ...
        'center', 0, luminance, contrast, 'match', 'match');
    % figure; imagesc(stim_t); colormap gray; axis image; colorbar
    % img_whitened_t=lib.reverse_pink_noise_square(pink_noise_target);
    % figure; imagesc(wn_reverse_t); colormap gray; axis image; colorbar

    % Only compute perp_ratio energy
%     edge_energy_blank=lib.edge_energy(img_whitened_b,target_radius,'center',kernel_size);
%     edge_energy_target=lib.edge_energy(img_whitened_t,target_radius,'center');
%     seed_energy_whitened(seed,:)=[seed edge_energy_blank edge_energy_target];

    % Compute multiple types of energies
    energies_this_seed = [];
    for energy_type = {'mag', 'cos', 'normal', 'grad_by_lum', 'grad_by_norm', ...
            'grad_by_sd', 'perp_ratio'}
        edge_energy_blank = lib.edge_energy(pink_noise_blank, target_radius, ...
            'center', kernel_size, energy_type);
        edge_energy_target = lib.edge_energy(pink_noise_target, target_radius, ...
            'center', kernel_size, energy_type);
        energies_this_seed = [energies_this_seed edge_energy_blank edge_energy_target];
    end
    seed_energy(seed, :) = [seed energies_this_seed];
end
toc

save('vislab-common/data/seed_multiple_energies_symmetric.mat', 'seed_energy');
