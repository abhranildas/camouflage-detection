% analyze_shuffled_exp  Compare a blocked vs. an unblocked pink-noise
%     detection experiment's hit rate, correct-rejection rate and d' per
%     edge-power bin, with bootstrapped d' error bars.
%
%     analyze_shuffled_exp
%
% Script, no arguments. "Blocked" trials are grouped into ten edge-power
% bins per session (the standard pink-noise design); "unblocked" trials
% present all edge powers in one shuffled session. Both are one subject
% (`adriana`).
%
% Inputs: `exp_files/pink_noise/exp_settings.mat` (`ExpSettings`, for
%     `edgePowerBlockCenters`), `exp_files/pink_noise_unblocked/
%     subject_out/adriana.mat` and `exp_files/pink_noise/subject_out/
%     adriana.mat` (each a `SubjectExpFile` with `.bTargetPresent`, `.hit`,
%     `.correctRejection`, all trials x edge-power bins x sessions).
% Output: three figures — hit/correct-rejection rate vs. edge power
%     (dimensionless bin index), then d' vs. edge power with bootstrapped
%     (n_boot = 100 resamples) standard-deviation error bars, blocked vs.
%     unblocked. Nothing is saved to disk.
%
% See also general.analyze_search_exps, general.analyze_shape_exps.

cfg = config();
load(fullfile(cfg.paths.exp_files, 'pink_noise', 'exp_settings.mat'), 'ExpSettings')

load(fullfile(cfg.paths.exp_files, 'pink_noise_unblocked', 'subject_out', 'adriana.mat'), ...
    'SubjectExpFile')
subject_exp_file_ub = SubjectExpFile;
load(fullfile(cfg.paths.exp_files, 'pink_noise', 'subject_out', 'adriana.mat'))

target_present = reshape(permute(SubjectExpFile.bTargetPresent, [2, 1, 3]), 10, [])';
hits = reshape(permute(SubjectExpFile.hit, [2, 1, 3]), 10, [])';
correct_rejection = reshape(permute(SubjectExpFile.correctRejection, [2, 1, 3]), 10, [])';

target_present_ub = reshape(permute(subject_exp_file_ub.bTargetPresent, [2, 1, 3]), 10, [])';
hits_ub = reshape(permute(subject_exp_file_ub.hit, [2, 1, 3]), 10, [])';
correct_rejection_ub = reshape(permute(subject_exp_file_ub.correctRejection, [2, 1, 3]), 10, [])';

hit_rate = sum(hits)./sum(target_present);
hit_rate_ub = sum(hits_ub)./sum(target_present_ub);

correct_rejection_rate = sum(correct_rejection)./sum(~target_present);
correct_rejection_rate_ub = sum(correct_rejection_ub)./sum(~target_present_ub);

figure; hold on
plot(ExpSettings.edgePowerBlockCenters, hit_rate_ub, '-o', 'color', 'b', ...
    'markerfacecolor', 'w');
plot(ExpSettings.edgePowerBlockCenters, hit_rate, '-o', 'color', 'b', 'markersize', 4, ...
    'markerfacecolor', 'b');
plot(ExpSettings.edgePowerBlockCenters, correct_rejection_rate_ub, '-o', 'color', 'r', ...
    'markerfacecolor', 'w');
plot(ExpSettings.edgePowerBlockCenters, correct_rejection_rate, '-o', 'color', 'r', ...
    'markersize', 4, 'markerfacecolor', 'r');
legend('hit rate (shuffled)', 'hit rate (blocked)', ...
    'correct rejection rate (shuffled)', 'correct rejection rate (blocked)')
legend boxoff

xlabel('edge power')

d_prime = norminv(hit_rate)-norminv(1-correct_rejection_rate);
d_prime_ub = norminv(hit_rate_ub)-norminv(1-mean(correct_rejection_rate_ub));

% figure; hold on
% plot(SubjectExpFile.edgePowerBlockCenters,d,'.b');
% plot(SubjectExpFile.edgePowerBlockCenters,d_ub,'or');

n_boot = 100;
d_prime_boot = nan(n_boot, 10); d_prime_ub_boot = nan(n_boot, 10);

for i_boot = 1:n_boot
    % blocked experiment
    [target_present_boot, boot_idx] = datasample(target_present, 30);
    hits_boot = hits(boot_idx, :);
    correct_rejection_boot = correct_rejection(boot_idx, :);

    hit_rate_boot = sum(hits_boot)./sum(target_present_boot);
    correct_rejection_rate_boot = sum(correct_rejection_boot)./sum(~target_present_boot);

    d_prime_boot(i_boot, :) = norminv(hit_rate_boot)-norminv(1-correct_rejection_rate_boot);

    % unblocked experiment
    [target_present_boot, boot_idx] = datasample(target_present_ub, 30);
    hits_boot = hits_ub(boot_idx, :);
    correct_rejection_boot = correct_rejection_ub(boot_idx, :);

    hit_rate_boot = sum(hits_boot)./sum(target_present_boot);
    correct_rejection_rate_boot = sum(correct_rejection_boot)./sum(~target_present_boot);

    d_prime_ub_boot(i_boot, :) = norminv(hit_rate_boot)- ...
        norminv(1-mean(correct_rejection_rate_boot));
end

d_prime_boot(isinf(d_prime_boot)) = nan;
d_prime_ub_boot(isinf(d_prime_ub_boot)) = nan;

d_prime(isinf(d_prime)) = 5; d_prime_ub(isinf(d_prime_ub)) = 5;

d_prime_sd = std(d_prime_boot, 'omitnan');
d_prime_sd(isnan(d_prime_sd)) = 0;
d_prime_ub_sd = std(d_prime_ub_boot, 'omitnan');
d_prime_ub_sd(isnan(d_prime_ub_sd)) = 0;

figure; hold on
errorbar(ExpSettings.edgePowerBlockCenters, d_prime, d_prime_sd, 'b', 'marker', 'o', ...
    'markerfacecolor', 'b');
errorbar(ExpSettings.edgePowerBlockCenters, d_prime_ub, d_prime_ub_sd, 'r', 'marker', 'o', ...
    'markerfacecolor', 'r');

title('d prime'); legend('blocked', 'unblocked')
