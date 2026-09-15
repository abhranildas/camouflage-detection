% block_jumping  Check whether recomputed edge energies still respect the
%     original per-block level ordering ("block jumping").
%
%     block_jumping
%
% Script, no arguments. Loads a saved experiment's edge energies
% (`ExpSettings.edgeEnergies`) and target-present flags
% (`ExpSettings.bTargetPresent`), recomputes each trial's edge energy from
% its stored seed with the live `lib.stimulus`/`lib.edge_energy` pair, and
% flags, per block, any target-present trial whose recomputed edge energy
% falls outside the range of the neighbouring blocks (would indicate the
% per-block level ordering "jumped").
%
% `bg_size`, `target_radius`, `seed`, `kernel_size` mirror
% `lib.stimulus`/`lib.edge_energy` name-value parameters and keep those
% exact names per docs/repo-cleanup.md section 4.1.1's binding convention
% 3. `luminance`/`contrast` are local values only, not passed to
% `lib.stimulus` below (that call hardcodes `'match'` for both target
% luminance/contrast instead) — the mismatch is left as found.
%
% Inputs: exp_files/1fnoise_L0.5_C0.15/exp_settings.mat (zone-3 frozen
%     struct fields: ExpSettings.edgeEnergies, .bTargetPresent,
%     .stimuliSeed).
% Output: three figures (old edge-energy stems, recomputed edge-energy
%     stems, old-vs-new scatter); prints the fraction of target-present
%     trials flagged as out of block order.
%
% See also lib.stimulus, lib.edge_energy.

load('exp_files/1fnoise_L0.5_C0.15/exp_settings.mat')
edge_energy_old = [ExpSettings.edgeEnergies(:, :, 1); ExpSettings.edgeEnergies(:, :, 2); ...
    ExpSettings.edgeEnergies(:, :, 3); ExpSettings.edgeEnergies(:, :, 4)];
target_present = [ExpSettings.bTargetPresent(:, :, 1); ExpSettings.bTargetPresent(:, :, 2); ...
    ExpSettings.bTargetPresent(:, :, 3); ExpSettings.bTargetPresent(:, :, 4)];

figure; hold on
for block = 1:10
    stem(edge_energy_old(target_present(:, block) == 1, block), ...
        ones(size(edge_energy_old(target_present(:, block) == 1, block))), 'marker', 'none')
end

edge_energy_new = zeros(size(edge_energy_old));
seeds = [ExpSettings.stimuliSeed(:, :, 1); ExpSettings.stimuliSeed(:, :, 2); ...
    ExpSettings.stimuliSeed(:, :, 3); ExpSettings.stimuliSeed(:, :, 4)];

bg_size = 256;                            % background width
target_radius = 64;
contrast = 0.15;                          % image RMS contrast
luminance = 0.5;                          % image mean luminance
kernel_size = [1 3];
texture_params.type = 'pink_noise';

% BUG (new, B2-level): lib.stimulus takes only name-value arguments (via
% inputParser) — see its own header. The call below passes everything
% positionally instead, so inputParser receives a struct where it expects
% a parameter-name string. This call errors immediately if the script is
% run as written. Left as found.
for i_trial = 1:size(seeds, 1)
    for i_block = 1:size(seeds, 2)
        [i_trial i_block]
        seed = seeds(i_trial, i_block);
        stim_target = lib.stimulus(texture_params, seed, bg_size, target_radius, 'center', ...
            0, luminance, contrast, 'match', 'match');
        edge_energy_new(i_trial, i_block) = lib.edge_energy(stim_target, target_radius, ...
            'center', kernel_size, 'grad_by_norm');
    end
end

figure; hold on
for block = 1:10
    stem(edge_energy_new(target_present(:, block) == 1, block), ...
        ones(size(edge_energy_new(target_present(:, block) == 1, block))), 'marker', 'none')
end

figure; hold on
for block = 1:10
    plot(edge_energy_old(target_present(:, block) == 1, block), ...
        edge_energy_new(target_present(:, block) == 1, block), '.')
end

bad_order = zeros(size(edge_energy_new));

for col = 1:9
    bad_order(edge_energy_new(:, col) > min(edge_energy_new(:, col+1)), col) = 1;
end

for col = 2:10
    bad_order(edge_energy_new(:, col) < max(edge_energy_new(:, col-1)), col) = 1;
end

sum(sum(bad_order(target_present)))/sum(sum(target_present))
