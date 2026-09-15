function template = mismatch_template(bg_size, target_radius, freq_index, phase_bg, phase_target)
% MISMATCH_TEMPLATE  Whitened template for a target/background phase mismatch.
%   template = lib.mismatch_template(bg_size, target_radius, freq_index, phase_bg, phase_target)
%
%   Creates the template produced by whitening a target and background
%   consisting of a single plane wave of the same frequency, but different
%   phases.
%
%   This calls lib.circular_mask and lib.whiten_pink_noise_square, neither
%   of which resolves to anything in this repo (B2.9) — this function
%   cannot currently run. Not fixed here (Stage 1 is behaviour-preserving).
%
%   Inputs
%     bg_size       - side length of the background, in pixels.
%     target_radius - target radius, in pixels.
%     freq_index    - frequency index (bin) of the plane wave.
%     phase_bg      - phase of the background plane wave, radians.
%     phase_target  - phase of the target plane wave, radians.
%
%   Output
%     template - bg_size x bg_size mismatch template.
%
%   See also lib.WHITEN.

    % background
    freq_amp_bg = zeros(1, bg_size-1);
    freq_amp_bg(freq_index) = exp(1i*phase_bg);
    freq_amp_bg(end-freq_index+1) = exp(-1i*phase_bg);
    freq_amp_bg = [0, freq_amp_bg];

    stim_freq_bg = zeros(bg_size);
    stim_freq_bg(1, :) = freq_amp_bg;
    stim_bg = ifft2(stim_freq_bg);

    % target
    freq_amp_target = zeros(1, bg_size-1);
    freq_amp_target(freq_index) = exp(1i*phase_target);
    freq_amp_target(end-freq_index+1) = exp(-1i*phase_target);
    freq_amp_target = [0, freq_amp_target];

    stim_freq_target = zeros(bg_size);
    stim_freq_target(1, :) = freq_amp_target;
    stim_target = ifft2(stim_freq_target);

    mask = lib.circular_mask(bg_size, target_radius);

    stim = stim_bg;
    stim(mask) = stim_target(mask);

    stim_bg_whitened = lib.whiten_pink_noise_square(stim_bg);
    stim_target_whitened = lib.whiten_pink_noise_square(stim_target);
    stim_bg_target_whitened = stim_bg_whitened;
    stim_bg_target_whitened(mask) = stim_target_whitened(mask);

    stim_whitened = lib.whiten_pink_noise_square(stim);
    template = stim_whitened - stim_bg_target_whitened;
end
