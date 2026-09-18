% show_example_stimuli  Display a grid of example camouflage stimuli across edge-energy levels.
%
%     show_example_stimuli
%
% Script, no arguments. Generates one trial per edge-energy block and
% displays them tiled in a grid, one row per trial and one column per
% edge-energy block, increasing edge energy left to right.
%
% Inputs: none (all parameters are literals below).
% Output: one figure, no files saved.
%
% See also experiment.generate_camouflage_stimuli, experiment.show_image.

bg_size = 256;
target_radius = 64;
p_target = 1;
n_sessions = 2;
n_blocks = 10;
n_trials = 1;
luminance = 0.5; contrast = .15;
edge_energy_block_edges = linspace(.1067, 1.4671, n_blocks+1); % ratio of perp gradients
% edge_energy_block_edges=linspace(.67,.95,n_blocks+1); %mag+dir/mag
% edgeEnergyLevels=linspace(36,139,nLevels);  %mag+dir
% edgeEnergyLevels=linspace(324,457,nLevels);  %dir
% edgeEnergyLevels=linspace(50,152,nLevels);  %mag
target_present = rand(n_trials, n_blocks, n_sessions) < p_target;
[stimuli, seeds, edge_energies] = experiment.generate_camouflage_stimuli(...
    edge_energy_block_edges, n_trials, n_sessions, bg_size, target_radius, ...
    luminance, contrast, target_present);
figure
for i_block = 1:n_blocks
    for i_trial = 1:n_trials
        subplot('Position', [(i_block-1)/n_blocks (i_trial-1)/n_trials 1/n_blocks 1/n_trials])
        experiment.show_image(stimuli(:, :, i_trial, i_block));
        colorbar off
        axis on
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
    end
end
