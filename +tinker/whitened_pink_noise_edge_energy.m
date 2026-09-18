% whitened_pink_noise_edge_energy  Sample whitened-pink-noise edge energy across seeds.
%
%     whitened_pink_noise_edge_energy
%
% Script, no arguments. For a batch of pink-noise stimulus seeds,
% whitens both the blank and target stimulus (lib.whiten_pink_noise_square)
% and measures the grad_by_norm edge-energy on the whitened images,
% appending to a stored table so repeated runs extend rather than
% overwrite it. An earlier version computed all of
% pink_noise_seed_multiple_energies's energy types on the whitened
% images too; that loop is now commented out in favor of grad_by_norm
% alone (see the tranche's findings log).
%
% Inputs: none (all parameters are literals below).
% Output: none returned (script); appends to
% vislab-common/data/seed_energy_pink_noise_whitened.mat's frozen
% seed_energy variable (seed, blank energy, target energy).
%
% See also lib.stimulus, lib.whiten_pink_noise_square, lib.edge_energy.

bg_size = 256;
target_radius = 64;
texture_params.type = 'pink_noise';
luminance = .5;
contrast = .15;

n_samples = 9890000;

kernel_size = [1 3];

if exist('vislab-common/data/seed_energy_pink_noise_whitened.mat', 'file') == 2
    load('vislab-common/data/seed_energy_pink_noise_whitened.mat')
    sample_start = seed_energy(end, 1)+1;
    seed_energy = [seed_energy;nan(n_samples, 3)];
else
    seed_energy = nan(n_samples, 3);
    sample_start = 1;
end

tic
parfor seed = sample_start:sample_start+n_samples-1
    seed

    % blank
    pink_noise_blank = lib.stimulus(texture_params, seed, bg_size, 0, 'center', 0, ...
        luminance, contrast, 'match', 'match');
    % figure; imagesc(stim_b); colormap gray; axis image; colorbar
    whitened_blank = lib.whiten_pink_noise_square(pink_noise_blank);
    % figure; imagesc(wn_reverse_b); colormap gray; axis image; colorbar

    % target
    pink_noise_target = lib.stimulus(texture_params, seed, bg_size, target_radius, ...
        'center', 0, luminance, contrast, 'match', 'match');
    % figure; imagesc(stim_t); colormap gray; axis image; colorbar
    whitened_target = lib.whiten_pink_noise_square(pink_noise_target);
    % figure; imagesc(wn_reverse_t); colormap gray; axis image; colorbar

    % Only compute perp_ratio energy
    edge_energy_blank = lib.edge_energy(whitened_blank, target_radius, ...
        'center', kernel_size, 'grad_by_norm');
    edge_energy_target = lib.edge_energy(whitened_target, target_radius, ...
        'center', kernel_size, 'grad_by_norm');
    seed_energy(seed, :) = [seed edge_energy_blank edge_energy_target];

    % Compute multiple types of energies
%     this_seed_energies=[];
%     for type={'mag','cos','normal','grad_by_lum','grad_by_norm','grad_by_sd','perp_ratio'}
%         edge_energy_blank=lib.edge_energy(whitened_blank,target_radius,'center',kernel_size,type);
%         edge_energy_target=lib.edge_energy(whitened_target,target_radius,'center',kernel_size,type);
%         this_seed_energies=[this_seed_energies edge_energy_blank edge_energy_target];
%     end
%     seed_energy(seed,:)=[seed this_seed_energies];
end
toc

save('vislab-common/data/seed_energy_pink_noise_whitened.mat', 'seed_energy');
