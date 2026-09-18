% camo_ability_vs_samples  Plot how a sample's max/mean/min edge energy
%     converges to the population value as sample size grows.
%
%     camo_ability_vs_samples
%
% Script, no arguments. For each of a log-spaced sweep of sample sizes,
% draws `n_trials` random samples of that size (without replacement, from
% one column of the shipped edge-energy pool) and averages each sample's
% max/mean/min across trials.
%
% Inputs: `vislab-common/data/seed_energy_pink_noise.mat` (`seed_energy`,
%     an N x 3 array; column 3 is the edge-energy pool sampled here).
% Output: one figure, max/mean/min edge energy (dimensionless) vs. sample
%     size (dimensionless count, log-spaced 10 to 10^4). Nothing is saved
%     to disk.
%
% See also general.compute_edge_powers_pink_noise.

load ('vislab-common/data/seed_energy_pink_noise.mat')
n_list = round(10.^(1:.1:4));
n_trials = 100;
n_stats = zeros(numel(n_list), 4);
samples = zeros(n_trials, 3);
for i_size = 1:numel(n_list)
    sample_size = n_list(i_size)  % deliberate: progress display, read again below
    for i_trial = 1:n_trials
        energy_sample = randsample(seed_energy(:, 3), sample_size);
        samples(i_trial, :) = [mean(energy_sample), min(energy_sample), max(energy_sample)];
    end
    n_stats(i_size, :) = [sample_size, mean(samples)];
end

plot(n_stats(:, 1), n_stats(:, 4), '-o');
hold on
plot(n_stats(:, 1), n_stats(:, 2), '-o');
plot(n_stats(:, 1), n_stats(:, 3), '-o');
%xlim([min(n_list) max(n_list)])
xlabel 'number of samples'
ylabel 'edge strength'
legend('maximum', 'mean', 'minimum')
legend boxoff
set(gca, 'fontsize', 13)
