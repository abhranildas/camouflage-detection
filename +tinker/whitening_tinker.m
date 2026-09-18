% whitening_tinker  Exploratory script: 1/f whitening and pinkening filters in 1-D.
%
%     whitening_tinker
%
% Cell-by-cell scratch script, no arguments. Builds a 1/f pinkening
% filter and its sqrt(f) whitening inverse via tinker.filter, checks the
% whitening/pinkening impulse responses against an analytical form, then
% (further down) whitens a mismatch-detection template stimulus and a
% synthetic split-frequency edge signal to look at how whitening affects
% detectability.
%
% Inputs: none (all parameters are literals per cell).
% Output: figures only; nothing saved to disk.
%
% See also tinker.filter, lib.mismatch_template, lib.whiten_pink_noise_square.

signal_length = 100;
whitening_filter = [1 1:signal_length/2 signal_length/2-1: -1:1]; % whitening filter
pinkening_filter = 1./whitening_filter;  % pinkening filter

% y=[normrnd(0,1,[1 signal_length/2]),zeros(1,signal_length/2)];
x_white_noise = normrnd(0, 1, [1 signal_length]);

% x_white_noise_left=x_white_noise;
% x_white_noise_left(signal_length/2+1:end)=0;
%
% x_white_noise_right=x_white_noise;
% x_white_noise_right(1:signal_length/2)=0;

x_delta = [1, zeros(1, signal_length-1)];

x_pink_irf = tinker.filter(x_delta, pinkening_filter);
x_white_irf = tinker.filter(x_delta, whitening_filter);

x_pink_noise = tinker.filter(x_white_noise, pinkening_filter);

% x_pink_noise_left=x_pink_noise;
% x_pink_noise_left(signal_length/2+1:end)=0;
%
% x_pink_noise_right=x_pink_noise;
% x_pink_noise_right(1:signal_length/2)=0;
%
% x_whitened_left=tinker.filter(x_pink_noise_left,whitening_filter);
% x_whitened_right=tinker.filter(x_pink_noise_right,whitening_filter);

x_whitened = tinker.filter(x_pink_noise, whitening_filter);

% analytical result
x_irf_anal = zeros(1, signal_length);
k = 1:signal_length/2;
for i_sample = 1:signal_length
    x_irf_anal(i_sample) = (1+2*(-1)^i_sample/signal_length + ...
        sum(2*cos(2*(i_sample-1)*k*pi/signal_length)./k))/signal_length;
end

figure(1)
stem(x_delta);
figure(2)
plot(x_pink_irf);
hold on
plot(x_irf_anal);
hold off;

crop_mask = [ones(1, signal_length/2) zeros(1, signal_length/2)];

%% pinkening IRF (corrected)
signal_length = 5e3;

% create a 1/sqrt(frequency) Fourier filter.
freq_filter = ones(1, signal_length);
for i_freq = 1:signal_length
    distance = sqrt(norm(i_freq-signal_length/2-1));
    if distance  % leave fft origin at 1
        freq_filter(i_freq) = distance^(-1);
    end
end

% delta function:
delta = [1, zeros(1, signal_length-1)];

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/frequency filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
delta_f = fftshift(fft(delta));

% multiply with 1/frequency filter
delta_f_fil = freq_filter.*delta_f;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
pinken_irf = ifft(ifftshift(delta_f_fil));

figure; hold on
stem(fftshift(delta), 'marker', 'none', 'color', 'k');
plot(fftshift(pinken_irf), 'b')
xlim(251+150*[-1 1]); ylim([0 .15])
set(gca, 'xtick', [101 251 401], 'xticklabels', {'-150', '0', '150'}, ...
    'ytick', [0 .15], 'fontsize', 13)

%% whitening IRF (corrected)
signal_length = 500;

% create a sqrt(frequency) Fourier filter.
freq_filter = ones(1, signal_length);
for i_freq = 1:signal_length
    distance = sqrt(norm(i_freq-signal_length/2-1));
    if distance  % leave fft origin at 1
        freq_filter(i_freq) = distance;
    end
end

% delta function:
delta = [1, zeros(1, signal_length-1)];

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/frequency filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
delta_f = fftshift(fft(delta));

% multiply with 1/frequency filter
delta_f_fil = freq_filter.*delta_f;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
whiten_irf = ifft(ifftshift(delta_f_fil));

figure; hold on
stem(fftshift(delta), 'marker', 'none', 'color', 'k');
plot(fftshift(whiten_irf), 'b')
xlim(251+10*[-1 1]); ylim([-3 12])
set(gca, 'xtick', [241 251 261], 'xticklabels', {'-10', '0', '10'}, 'ytick', [0 10], 'fontsize', 13)

%% checking theoretical form of pinkening IRF
n_samples = 100;
x_range = 1:n_samples;
delta = [1, zeros(1, n_samples-1)];
delta_f = fft(delta);

freq_filter = ones(1, n_samples);
for i_freq = 1:n_samples
    distance = sqrt(norm(i_freq-n_samples/2-1));
    if distance  % leave fft origin at 1
        freq_filter(i_freq) = 1/distance;
    end
end

filter_shifted = fftshift(freq_filter);
delta_f = delta_f.*filter_shifted;
f_numeric = ifft(delta_f);

% curve=cos(0*x_range*2*pi/n_samples);
% curve=exp(1i*0*x_range*2*pi/n_samples);
curve = 1+cos(pi*(x_range-1))/sqrt(n_samples/2);
for k = 1:n_samples/2-1
    curve = curve+2*cos(2*pi*k*(x_range-1)/n_samples)/sqrt(k);
%     curve=curve+exp(1i*(k-1)*x_range*2*pi/n_samples);
end
curve = curve/n_samples;

figure; plot(f_numeric); hold on; plot(curve, 'o');
[sum(curve) sum(curve.^2)]

%% continuous analytical whitening filter
k_max = 2;
x_range = -10:.01:10;
curve = (exp(-2*pi*1i*k_max*x_range).*(1+2*pi*1i*k_max*x_range)-1)./(4*pi^2*x_range.^2);
plot(curve)

%% whitening a sine
k_idx = 1; % index of the sinusoid frequency
phase = 0; % phase of the sinusoid

sine_spectrum = zeros(1, signal_length-1);
sine_spectrum(k_idx) = exp(1i*phase);
sine_spectrum(end-k_idx+1) = exp(-1i*phase);
sine_spectrum = [0, sine_spectrum];
% sine_signal=ifft(sine_spectrum);

% plot(sine_signal)
% sine_whitened=cconv(sine_signal,x_whiten_one_irf,length(sine_signal));
% hold on; plot(sine_whitened); hold off

%% whitening a single plane wave mismatch stimulus.
bg_size = 256;
target_radius = 64;
luminance = .5;
contrast = .15;

k_idx = 1; % index of the sinusoid frequency
phi_b = .5; % phase of the sinusoid
phi_t = .7; % phase of the sinusoid

mismatch_template_image = lib.mismatch_template(bg_size, target_radius, k_idx, phi_b, phi_t);
figure; imagesc(mismatch_template_image); axis square; colormap gray; ...
    set(gca, 'xtick', []); set(gca, 'ytick', []);

%% matched mismatch-template detector
texture_params.type = 'pink_noise';

n_test_samples = 1e2;
temp_response = nan(n_test_samples, 3);

parfor seed = 1:n_test_samples
    seed
    % blank
    pink_noise_blank = lib.stimulus(texture_params, seed, bg_size, 0, 'center', 0, ...
        luminance, contrast, 'match', 'match');
    whitened_blank = lib.whiten_pink_noise_square(pink_noise_blank);

    % target
    pink_noise_target = lib.stimulus(texture_params, seed, bg_size, target_radius, ...
        'center', 0, luminance, contrast, 'match', 'match');
    whitened_target = lib.whiten_pink_noise_square(pink_noise_target);

    temp_response(seed, :) = [seed dot(mismatch_template_image(:), whitened_blank(:)) ...
        dot(mismatch_template_image(:), whitened_target(:))];
end

%% whitening one frequency component

% 1-frequency whitening filter
k_idx = 3; % index of the frequency
single_freq_whitening_filter = ones(1, signal_length);
single_freq_whitening_filter(k_idx+1) = k_idx;
single_freq_whitening_filter(end-k_idx+1) = k_idx;

% IRF
x_whiten_one_irf = tinker.filter(x_delta, single_freq_whitening_filter);

x_white_noise_left = normrnd(0, 1, [1 signal_length]);
x_pink_noise_left = tinker.filter(x_white_noise_left, pinkening_filter);

x_white_noise_right = normrnd(0, 1, [1 signal_length]);
x_pink_noise_right = tinker.filter(x_white_noise_right, pinkening_filter);

x_white_noise = [x_white_noise_left(1:signal_length/2), x_white_noise_right(signal_length/2+1:end)];

x_pink_noise = [x_pink_noise_left(1:signal_length/2) x_pink_noise_right(signal_length/2+1:end)];

subplot(3, 1, 1)
plot(x_pink_noise)

x_whitened = tinker.filter(x_pink_noise, whitening_filter);

subplot(3, 1, 2)
plot(x_white_noise);
hold on
plot(x_whitened);
hold off

subplot(3, 1, 3)
plot(x_whitened-x_white_noise);

x_whitened_one = cconv(x_pink_noise, x_whiten_one_irf, length(x_pink_noise));
hold on;
plot(x_whitened_one)
figure
plot(x_whitened_one-x_pink_noise)
%% examples of whitened stimuli
x_white_noise_left = normrnd(0, 1, [1 signal_length]);
x_pink_noise_left = tinker.filter(x_white_noise_left, pinkening_filter);

x_white_noise_right = normrnd(0, 1, [1 signal_length]);
x_pink_noise_right = tinker.filter(x_white_noise_right, pinkening_filter);

x_pink_noise_stim = [x_pink_noise_left(1:signal_length/2) ...
    x_pink_noise_right(signal_length/2+1:end)];

plot(x_pink_noise_stim); hold on;
x_whitened_stim = tinker.filter(x_pink_noise_stim, whitening_filter);
plot(x_whitened_stim); hold off;

%% whitening edges between all phase pairs
signal_length = 100;
k = 1;
x_range = 1:signal_length/2;
n_phases = 10;
plot_idx = 1;

figure;
for phase_a = linspace(0, 2*pi, n_phases)
    for phase_b = linspace(0, 2*pi, n_phases)
        sine_a = sin(k*x_range+phase_a);
        sine_b = sin(k*x_range+phase_b);
        curve = [sine_a, sine_b];
        curve_whitened = cconv(curve, x_white_irf, signal_length);
        subplot(n_phases, n_phases, plot_idx)
        plot(curve, 'Color', [.5 .5 .5])
        hold on
        plot(curve_whitened-signal_length*k*curve/(2*pi), 'b')
        ylim([-2 2])
        xlim([30 70])
        % plot([50 50],ylim,'k')
        hold off
        set(gca, 'xtick', [])
        set(gca, 'ytick', [])
        axis off
        % title(sprintf('%d %d',round(rad2deg([phase_a+k*signal_length/2,phase_b]))))
        plot_idx = plot_idx+1;
    end
end
