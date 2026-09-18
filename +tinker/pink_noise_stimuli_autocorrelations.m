% pink_noise_stimuli_autocorrelations  Point-pair correlation vs. separation,
% across a target boundary.
%
%     pink_noise_stimuli_autocorrelations
%
% Script, no arguments. For a batch of pink-noise stimulus seeds,
% computes the correlation coefficient between pixel-value pairs at each
% separation distance, restricted to pairs whose connecting line crosses
% the target boundary (lib.correlations_across) -- building a baseline
% cross-boundary correlation profile from background noise alone (no
% target patch is actually inserted; the target-boundary mask sets the
% pair geometry, not the stimulus content). A second cell derives a
% log-likelihood-ratio decision variable from separately-computed
% blank/target correlation profiles, and a third looks at d' vs.
% distance; both reference variables not produced anywhere in this file
% (see B3.21).
%
% Inputs: none (all parameters are literals below).
% Output: none returned (script); appends the frozen 'd' and 'corr_cross'
% to vislab-common/data/pink_noise_stim_blank_autocorr.mat.
%
% See also lib.correlations_across, lib.circular_mask, lib.compute_dPrime_pCorrect.

%% compute correlation as a function of separation distance of point pairs
% that cross / don't cross the target boundary, for a bunch of pink noise
% stimuli.

bg_size = 256;
target_radius = 64;
texture_params.type = 'pink_noise';
n_seeds = 4000;

mask = lib.circular_mask(bg_size, target_radius, 'center');
x_squared = repmat((0:bg_size-1).^2, [bg_size, 1]); % array of x^2
d = sqrt(unique(x_squared+x_squared'));

if exist('vislab-common/data/pink_noise_stim_blank_autocorr.mat', 'file') == 2
    load('vislab-common/data/pink_noise_stim_blank_autocorr.mat')
    seed_start = size(corr_same, 2)+1;
    % corr_same=[corr_same,nan(numel(d),n_seeds)];
    corr_cross = [corr_cross, nan(numel(d), n_seeds)];
else
    % corr_same=nan(numel(d),n_seeds);
    corr_cross = nan(numel(d), n_seeds);
    seed_start = 1;
end

tic
parfor seed = seed_start:seed_start+n_seeds-1
    seed
    pink_noise_image = lib.stimulus(texture_params, seed, bg_size, 0, 'center', 0, 0.5, .15);
    % corr_cross_this=lib.correlations_across(pink_noise_image,mask);
    % corr_same(:,seed)=corr_same_this;
    corr_cross(:, seed) = lib.correlations_across(pink_noise_image, mask);
end
toc

figure; hold on
% plot(d,corr_same,'Color',[0 0 1 .05])
% plot(d,mean(corr_same,2),'b')
plot(d, mean(corr_cross, 2), 'r')
% xlim([0 150])

save('vislab-common/data/pink_noise_stim_blank_autocorr.mat', 'd', 'corr_cross');

%% log-likelihood-ratio decision variable based on autocorrelations
n_seeds = size(corr_blank_cross, 2);

mean_corr_blank = mean(corr_blank_cross, 2);
mean_corr_target = mean(corr_target_cross, 2);

sd_corr_blank = std(corr_blank_cross, 0, 2);
sd_corr_target = std(corr_target_cross, 0, 2);

LLR_blank = nan(n_seeds, 1);
LLR_target = nan(n_seeds, 1);

for seed = 1:n_seeds
    seed
    corr_this_seed = corr_blank_cross(:, seed);
    LLR_blank(seed) = nansum(terms(20:end));
    corr_this_seed = corr_target_cross(:, seed);
    LLR_target(seed) = nansum(log(sd_corr_blank./sd_corr_target) + ...
        ((corr_this_seed-mean_corr_blank).^2)./(2*sd_corr_blank.^2) - ...
        ((corr_this_seed-mean_corr_target).^2)./(2*sd_corr_target.^2));
end

lib.compute_dPrime_pCorrect(LLR_blank, LLR_target, 100, 1);

% save('vislab-common/data/pink_noise_stim_corrs.mat','d','corr_blank_cross','corr_target_cross','LLR_blank','LLR_target');

%% d' as a function of distance
d_prime = nan(numel(d), 4);
for i_distance = 2:numel(d)
    [d_prime_av, d_prime_hf, d_prime_pc, opt_acc] = lib.compute_dPrime_pCorrect(...
        corr_cross(i_distance, :), corr_same(i_distance, :), 10, 0);
    d_prime(i_distance, :) = [d_prime_av, d_prime_hf, d_prime_pc, opt_acc];
end
% plot(d(floor(d)==d),d_prime(floor(d)==d,4))
