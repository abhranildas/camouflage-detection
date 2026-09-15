% compare_edge_energy_defs  Compare d' and optimal-observer accuracy across
%     six edge-energy definitions, each at ten kernel scales.
%
%     compare_edge_energy_defs
%
% Script, no arguments. For each of six edge-energy definitions
% (`cos`, `mag`, `grad_by_lum`, `grad_by_norm`, `grad_by_sd`,
% `perp_ratio`) and ten kernel scales, reads the matching target/no-target
% energy fields out of `seed_energy` and scores them.
%
% Inputs: workspace variable `seed_energy`, a struct with fields
%     `target_<type>_<kernel_sigma>` / `notarget_<type>_<kernel_sigma>`
%     for each of the six types and kernel_sigma = 1:10.
% Output: `energies_accuracies`, a 60-element struct array (`.type`,
%     `.opt_acc`, `.dPrime_av`, `.dPrime_hf`, `.dPrime_pc`). Nothing is
%     saved to disk.
%
% NOTE: `analysis.compute_dPrime_pCorrect`, called below, does not exist
% anywhere in this repo (checked: no file or package defines it). Running
% this script errors immediately. Left as found — not a Stage 1 fix.
%
% See also general.compute_edge_powers_camo, general.compute_edge_powers_pink_noise.

energies_accuracies = struct;
i_result = 1;
for edge_measure_type = {'cos', 'mag', 'grad_by_lum', 'grad_by_norm', 'grad_by_sd', 'perp_ratio'}
    for kernel_sigma = 1:10
        [d_prime_avg, d_prime_hit_false_alarm, d_prime_percent_correct, ...
            optimal_accuracy, optimal_criterion] = ...
            analysis.compute_dPrime_pCorrect( ...
            [seed_energy.(['notarget_', char(edge_measure_type), '_', num2str(kernel_sigma)])], ...
            [seed_energy.(['target_', char(edge_measure_type), '_', num2str(kernel_sigma)])], ...
            500, 1);
        %[~,opt_acc]=analysis.optimal_discrim([seed_energy.(['notarget_', char(type), '_', num2str(kernel_sd)])],[seed_energy.(['target_', char(type), '_', num2str(kernel_sd)])],500,1);
        %dPrime=analysis.compute_dPrime([seed_energy.(['notarget_', char(type), '_', num2str(kernel_sd)])],[seed_energy.(['target_', char(type), '_', num2str(kernel_sd)])]);
        energies_accuracies(i_result).type = [char(edge_measure_type), '_', num2str(kernel_sigma)];
        energies_accuracies(i_result).opt_acc = optimal_accuracy;
        energies_accuracies(i_result).dPrime_av = d_prime_avg;
        energies_accuracies(i_result).dPrime_hf = d_prime_hit_false_alarm;
        energies_accuracies(i_result).dPrime_pc = d_prime_percent_correct;
        i_result = i_result+1;
    end
end
