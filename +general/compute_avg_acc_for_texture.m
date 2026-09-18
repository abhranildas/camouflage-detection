% compute_avg_acc_for_texture  Plot each subject's fitted psychometric d'
%     against the pooled blank/target edge-power histograms, then report
%     the pooled mean/sd accuracy across subjects and stimuli.
%
%     compute_avg_acc_for_texture
%
% Script, no arguments. Fits `experiment.analysis.compute_threshold_edge_power`
% per subject for one experiment type, evaluates the fitted psychometric
% function at every stored target edge power, and converts d' to
% proportion correct via `normcdf(d_prime/2)` (the two-alternative,
% equal-variance form).
%
% Inputs: `vislab-common/data/edge_powers/<exp_name>.mat` (`edge_powers`,
%     N x 2, blank/target edge power, dimensionless); `exp_files/
%     <exp_name>/subject_out/*.mat`, one per subject.
% Output: one figure per subject (edge-power histograms plus a printed
%     title) and a printed pooled accuracy mean +/- sd (percent). Nothing
%     is saved to disk.
%
% See also experiment.analysis.compute_threshold_edge_power, experiment.analysis.psychometric_fun.

exp_name = 'pink_noise';

% load edge powers
load(['vislab-common/data/edge_powers/' exp_name '.mat'], 'edge_powers')

[blank_edge_power_counts, blank_edge_power_bins] = histcounts(edge_powers(:, 1));
blank_edge_power_counts = blank_edge_power_counts/max(blank_edge_power_counts);

% target histogram
[target_edge_power_counts, target_edge_power_bins] = histcounts(edge_powers(:, 2));
target_edge_power_counts = target_edge_power_counts/max(target_edge_power_counts);

subj_list = dir(['exp_files/' exp_name '/subject_out/*.mat']);
all_d_primes = nan(size(edge_powers, 1), length(subj_list));

for i_subj = 1:length(subj_list)
    figure; hold on
    % blank histogram
    histogram('BinEdges', blank_edge_power_bins, 'BinCounts', blank_edge_power_counts, ...
        'facecolor', 'b', 'facealpha', 0.3, 'edgecolor', 'none')
    % target histogram
    histogram('BinEdges', target_edge_power_bins, 'BinCounts', target_edge_power_counts, ...
        'facecolor', 'r', 'facealpha', 0.3, 'edgecolor', 'none')

    [~, subj_name] = fileparts(subj_list(i_subj).name)
    % compute pmf parameters
    [threshold, slope, bias] = experiment.analysis.compute_threshold_edge_power(exp_name, ...
        subj_name, 1, 0);
    mu = 0;
    threshold_scale = threshold-mu;
    [~, ~, ~, d_primes] = experiment.analysis.psychometric_fun(edge_powers(:, 2), mu, ...
        threshold_scale, slope, bias);
    all_d_primes(:, i_subj) = d_primes;
    title(sprintf('%s: %s', exp_name, subj_name))
end

all_accuracy = normcdf(all_d_primes/2);

% mean and sd of pooled accuracy of all stimuli across all subjects
[accuracy_sd, accuracy_avg] = std(all_accuracy(:));
fprintf('%s: %.1f ± %.1f%%\n', exp_name, 100*accuracy_avg, 100*accuracy_sd);
% title(sprintf('%s: %.1f ± %.1f%%',exp_name,100*acc_avg,100*acc_sd))
