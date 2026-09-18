% pink_noise  Exploratory script: synthesize and characterize 1-D/2-D pink noise.
%
%     pink_noise
%
% Cell-by-cell scratch script, no arguments. Cells build 1/f (pink) noise
% by FFT filtering (both automatically and, once, by explicit manual
% inverse-DFT summation as a learning exercise), then compare sampled vs.
% theoretical point-value distributions and autocorrelation functions in
% 1-D and 2-D, at increasing levels of correctness (later cells marked
% "(corrected)" fix normalization issues in earlier ones).
%
% Inputs: none (all parameters are literals per cell).
% Output: figures only; nothing saved to disk.
%
% Known issue: the "Verify convolution theorem" and "2D pink noise:
% autocorrelation (corrected)" cells call a bare colored_noise(...), which
% resolves to no function anywhere in this repo (see B2.26).
%
% See also tinker.pink_noise_dist, tinker.pink_noise_line,
% tinker.pink_noise_square_manual, lib.create_pink_noise_line.

%% 2D pink noise

bg_size = 200;
pink_noise_filter = zeros(bg_size);
for i_ensemble = 1:bg_size
    % i_ensemble indexes pixel rows here, not ensemble samples -- it
    % ranges over bg_size, not n_ensemble, and this loop builds the
    % filter kernel, not an ensemble. Kept as i_ensemble because the
    % majority of this file's uses of this counter are genuine
    % ensemble indices (see below).
    for i_col = 1:bg_size
        value = norm([i_ensemble-bg_size/2-1, i_col-bg_size/2-1]);
        if value  % leave fft origin at 0
            pink_noise_filter(i_ensemble, i_col) = 1/value;
        end
    end
end
% white noise image:
white_noise = normrnd(0, 1, bg_size);

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
white_noise_fft = fftshift(fft2(white_noise));

% multiply with 1/f filter
white_noise_fft = pink_noise_filter.*white_noise_fft;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
white_noise_fft = ifftshift(white_noise_fft);

% either use inverse fourier transform:
pink_noise_image = ifft2(white_noise_fft);

% or do it manually as a learning tool:
pink_noise_image_manual = zeros(bg_size);

figure;
subplot(1, 2, 1);
imagesc(pink_noise_image); colormap gray; axis image;

subplot(1, 2, 2);
for freq_u = 1:bg_size
    freq_u  % deliberate: progress display alongside the live drawnow plot below
    imagesc(pink_noise_image_manual); colormap gray; axis image; drawnow
    for freq_v = 1:bg_size
        cos_amp = real(white_noise_fft(freq_u, freq_v));
        sin_amp = imag(white_noise_fft(freq_u, freq_v));
        for i_ensemble = 1:bg_size
            for i_col = 1:bg_size
                pink_noise_image_manual(i_ensemble, i_col) = ...
                    pink_noise_image_manual(i_ensemble, i_col)+...
                    cos_amp*cos(2*pi/bg_size*((freq_u-1)*i_col+(freq_v-1)*i_ensemble))+...
                    sin_amp*sin(2*pi/bg_size*((freq_u-1)*i_col+(freq_v-1)*i_ensemble));
            end
        end
    end
end

%% Verify convolution theorem
conv_test_image = colored_noise(1000, 2, -1);
conv_test_fft = fft2(conv_test_image);
conv_test_autocorr = xcorr2(conv_test_image);

conv_test_autocorr_fft = fft2(conv_test_autocorr);
figure; surf(abs(fftshift(conv_test_autocorr_fft)));

conv_test_power = abs(conv_test_fft).^2;
figure; surf(abs(fftshift(conv_test_power)));

[radial_profile, radius_bins] = lib.radial_avg(conv_test_autocorr, 100);
figure;
plot(log(radius_bins), log(radial_profile))

%% 1D pink noise: distribution
dimension = 1;
n_samples = 1e3;
log_k_min = -2;
log_k_max = 2;
d_log_k = .01;
k_list = 10.^(log_k_min:d_log_k:log_k_max);
k_min = 10^log_k_min; k_max = 10^log_k_max;
n_ensemble = 1e2;

% ensemble sampling
pink_noise_ensemble = zeros(n_ensemble, n_samples);
for i_ensemble = 1:n_ensemble
    corr_coef_sum = tinker.pink_noise_line(n_samples, k_list);
    pink_noise_ensemble(i_ensemble, :) = corr_coef_sum;
end

% theory
[density, value] = tinker.pink_noise_dist(dimension, k_list);

% compare sampling vs theory
figure
histogram(pink_noise_ensemble(:), 1000, 'Normalization', 'pdf', 'EdgeColor', 'none'); hold on
plot(value, density, 'r-', 'LineWidth', 1); hold off

legend('sampled', 'theory');
legend boxoff
set(gca, 'fontsize', 13)

%% 1D pink noise: autocorrelation

% ensemble sampling
lags = 0:n_samples-2;
autocorrelations = zeros(n_ensemble, numel(lags));
figure; hold on
for i_ensemble = 1:n_ensemble
    for lag = lags
        corr_matrix = corrcoef(pink_noise_ensemble(i_ensemble, 1:end-lag), ...
            pink_noise_ensemble(i_ensemble, 1+lag:end));
        autocorrelations(i_ensemble, lag+1) = corr_matrix(1, 2);
    end
    % autocorrelations(i_ensemble,:)=autocorr_image(ys(i_ensemble,:),'NumLags',len-2);
    plot(lags*k_min, autocorrelations(i_ensemble, :), 'Color', [0 0 0 .01])
end

h_mean = plot(lags*k_min, mean(autocorrelations), '-k', 'LineWidth', 1);

% analytical: discrete sum
corr_coef_sum = zeros(size(lags));
for k = k_list
    corr_coef_sum = corr_coef_sum+cos(k*lags)/k;
end

corr_coef = corr_coef_sum/sum(1./k_list);

h_anal_disc = plot(lags*k_min, corr_coef, 'r-', 'LineWidth', 1);

% analytical: continuous integral from k_min to k_max
corr_coef_continuous = (cosint(lags*k_max)-cosint(lags*k_min))/log(k_max/k_min);
corr_coef_continuous(1) = 1;
h_anal_cont = plot(lags*k_min, corr_coef_continuous, '-b', 'LineWidth', 1);

xlabel ('d (in units of \lambda_{max})')
ylabel('correlation coefficient r(d)')
set(gca, 'fontsize', 13)
legend([h_mean, h_anal_disc, h_anal_cont], {'sample mean (discrete)', ...
    'analytical (discrete)', 'analytical (continuous)'});
legend boxoff

%% 2D pink noise: distribution
dimension = 2;
n_samples = 100;
log_k_min = -1;
log_k_max = 1;
d_log_k = .1;
k_list = 10.^(log_k_min:d_log_k:log_k_max);
k_min = 10^log_k_min; k_max = 10^log_k_max;
angle_step = .1; % spacing of component wave orientations

% ensemble sampling
pink_noise_ensemble_2d = zeros(n_samples, n_samples, n_ensemble);
for i_ensemble = 1:n_ensemble
    i_ensemble  % deliberate: progress display through the ensemble loop
    pink_noise_ensemble_2d(:, :, i_ensemble) = ...
        tinker.pink_noise_square_manual(n_samples, k_list, angle_step);
end

% theory
[density, value] = tinker.pink_noise_dist(dimension, k_list, angle_step);

% compare sampling vs theory
figure
histogram(pink_noise_ensemble_2d(:), 1000, 'Normalization', 'pdf', 'EdgeColor', 'none'); hold on
plot(value, density, 'r-'); hold off
legend('sampled', 'theory'); legend boxoff
set(gca, 'fontsize', 13)
box off
title 'distribution of 2D pink noise values'

%% 2D pink noise: autocorrelation

% ensemble sampling
lags = 0:n_samples-2;
autocorrelations = zeros(numel(lags), numel(lags), n_ensemble);
figure; hold on
for i_ensemble = 1:n_ensemble
    i_ensemble  % deliberate: progress display through the ensemble loop
    for lag_x = lags
        for shift_y = lags
            corr_region_1 = pink_noise_ensemble_2d(1:end-lag_x, 1:end-shift_y, i_ensemble);
            corr_region_2 = pink_noise_ensemble_2d(1+lag_x:end, 1+shift_y:end, i_ensemble);
            corr_matrix = corrcoef(corr_region_1(:), corr_region_2(:));
            autocorrelations(lag_x+1, shift_y+1, i_ensemble) = corr_matrix(1, 2);
        end
    end
    plot(lags*k_min, autocorrelations(1, :, i_ensemble), 'Color', [0 0 0 .1])
end
h_mean = plot(lags*k_min, mean(autocorrelations(1, :, :), 3), '-k', 'LineWidth', 1);

% analytical: discrete sum
corr_coef_sum = zeros(size(lags));
for k = k_list
    corr_coef_sum = corr_coef_sum+besselj(0, k*lags)/k^2;
end
corr_coef = corr_coef_sum/sum(k_list.^(-2));
h_anal_disc = plot(lags*k_min, corr_coef, 'r-', 'LineWidth', 1);

% analytical: continuous integral from k_min to k_max
corr_coef_continuous = (hypergeom(-1/2, [1/2 1], -lags.^2*k_min^2/4)/k_min...
    -hypergeom(-1/2, [1/2 1], -lags.^2*k_max^2/4)/k_max)/...
    (1/k_min-1/k_max);
h_anal_cont = plot(lags*k_min, corr_coef_continuous, '-b', 'LineWidth', 1);

xlabel ('d (in units of \lambda_{max})')
ylabel('correlation coefficient r(d)')
set(gca, 'fontsize', 13)
legend([h_mean, h_anal_disc, h_anal_cont], {'sample mean (discrete)', ...
    'analytical (discrete)', 'analytical (continuous)'});
legend boxoff

% plot sample mean autocorrelation in both x_values,y_values
autocorrelations_mean = mean(autocorrelations, 3);
autocorrelations_mean = [fliplr(autocorrelations_mean), autocorrelations_mean];
autocorrelations_mean = [flipud(autocorrelations_mean); autocorrelations_mean];
figure; surf(autocorrelations_mean, 'LineStyle', 'none');
zlabel 'r(d)'
set(gca, 'fontsize', 13)

%% check pink noise point value distribution parameters
pink_noise_sample = lib.create_pink_noise_line(1e4, 1);
var(pink_noise_sample)

%% 1D pink noise: autocorrelation (corrected)

n_samples = 5e3;
n_ensemble = 500;

% generate pink noise
pink_noise_ensemble = zeros(n_ensemble, n_samples);
for i_ensemble = 1:n_ensemble
    pink_noise_sample = lib.create_pink_noise_line(n_samples, 1);
    pink_noise_ensemble(i_ensemble, :) = pink_noise_sample;
end

% autocorrelation coefficient
lags = 0:n_samples-2;
autocorrelations = zeros(n_ensemble, numel(lags));

for i_ensemble = 1:n_ensemble
    for lag = lags
        corr_matrix = corrcoef(pink_noise_ensemble(i_ensemble, :), ...
            circshift(pink_noise_ensemble(i_ensemble, :), -lag));
        autocorrelations(i_ensemble, lag+1) = corr_matrix(1, 2);
    end
    % autocorrelations(i_ensemble,:)=autocorr_image(ys(i_ensemble,:),'NumLags',len-2);
end

figure; hold on
h_samp = plot(lags/n_samples, autocorrelations(i_ensemble, :), 'Color', [0 0 0 .1]);
for i_ensemble = 2:10
    plot(lags/n_samples, autocorrelations(i_ensemble, :), 'Color', [0 0 0 .1])
end

h_mean = plot(lags/n_samples, mean(autocorrelations), '-k', 'LineWidth', 1);

% analytical: discrete sum
corr_coef_sum = zeros(size(lags));
k_list = 1:n_samples/2;
for k = k_list
    corr_coef_sum = corr_coef_sum+cos(2*pi*k*lags/n_samples)/k;
end

corr_coef = corr_coef_sum/sum(1./k_list);

h_anal_disc = plot(lags/n_samples, corr_coef, 'r-', 'LineWidth', 1);

% analytical: continuous integral from k_min to k_max
corr_coef_continuous = (cosint(2*pi*lags*max(k_list)/n_samples) - ...
    cosint(2*pi*lags*min(k_list)/n_samples))/log(max(k_list)/min(k_list));
corr_coef_continuous(1) = 1;
h_anal_cont = plot(lags/n_samples, corr_coef_continuous, '-b', 'LineWidth', 1);

xlim([-.01 .5]); ylim([-.4 1.1])
xlabel ('d (in units of longest wavelength)')
ylabel('autocorrelation coefficient r(d)')
set(gca, 'fontsize', 13)
legend([h_samp, h_mean, h_anal_disc, h_anal_cont], {'sample', 'sample mean', ...
    'theory', 'theory (continuous frequencies)'});
legend boxoff

%% 2D pink noise: autocorrelation (corrected)

n_samples = 1e2;
n_ensemble = 100;

% autocorrelation coefficient
autocorrelations = nan(n_samples, n_samples, n_ensemble);

parfor i_ensemble = 1:n_ensemble
    i_ensemble
    pink_noise_2d = colored_noise(n_samples, 2, -1);
    % compute autocorr_image by squaring the FFT
    autocorr_image = ifft2(abs(fft2(pink_noise_2d)).^2);
    autocorr_image = fftshift(autocorr_image/autocorr_image(1, 1));
    autocorrelations(:, :, i_ensemble) = autocorr_image;
end

mean_autocorr = mean(autocorrelations, 3);
surf(mean_autocorr, 'edgecolor', 'none');

% theoretical 2d autocorr_image
[freq_u, freq_v] = meshgrid(1:n_samples/2);
[x_values, y_values] = meshgrid(-n_samples/2:n_samples/2);

autocorr_theoretical = nan(size(x_values));
for row = 1:size(autocorr_theoretical, 1)
    for col = 1:size(autocorr_theoretical, 2)
        [row, col]  % deliberate: progress display through this slow double loop
        autocorr_theoretical(row, col) = sum(sum(cos(freq_u*x_values(row, col) + ...
            freq_v*y_values(row, col))./(freq_u.^2+freq_v.^2)));
    end
end

figure;
surf(autocorr_theoretical, 'edgecolor', 'none');

autocorr_image = lib.radial_avg(autocorr_image, n_samples/2+1);
autocorrelations(i_ensemble, :) = autocorr_image(2:end)/autocorr_image(2);

lags = 0:n_samples/2-1;
figure; hold on
h_samp = plot(lags/n_samples, autocorrelations(1, :), 'Color', [0 0 0 .1]);
for i_ensemble = 2:n_ensemble
    plot(lags/n_samples, autocorrelations(i_ensemble, :), 'Color', [0 0 0 .1])
end

mean_autocorr = mean(autocorrelations, 1);
h_mean = plot(lags/n_samples, mean_autocorr, '-k', 'LineWidth', 1);

% analytical: discrete sum
corr_coef_sum = zeros(size(lags));
k_list = 1:n_samples/2;
for k = k_list
    corr_coef_sum = corr_coef_sum+besselj(0, 2*pi*k*lags/n_samples)/k;
end

corr_coef = corr_coef_sum/sum(k_list.^(-1));

h_anal_disc = plot(lags/n_samples, corr_coef, 'r-', 'LineWidth', 1);

% analytical: continuous integral from k_min to k_max
% corr_coef_continuous=(hypergeom(-1/2, [1/2 1], -lags.^2*pi^2*min(k_list)^2/n_samples^2)/min(k_list)...
%     -hypergeom(-1/2, [1/2 1], -lags.^2*pi^2*max(k_list)^2/n_samples^2)/max(k_list))/...
%     (1/min(k_list)-1/max(k_list));
% h_anal_cont=plot(lags/n_samples,corr_coef_continuous,'-b','LineWidth',1);

xlim([-.01 .5]); ylim([-.4 1.1])
xlabel ('d (in units of longest wavelength)')
ylabel('autocorrelation coefficient r(d)')
set(gca, 'fontsize', 13)
legend([h_samp, h_mean, h_anal_disc], {'sample', 'sample mean', 'theory'});
legend boxoff

%% properties of Bessel J
x_values = linspace(-100, 100, 1e3);
cos_curve = cos(x_values);
bessel_curve = besselj(0, x_values);
figure; hold on
plot(x_values, cos_curve)
plot(x_values, bessel_curve)

%% test properties of filtered noise

white_noise = normrnd(0, 1, 100);
white_noise_raw_fft = fft2(white_noise);
white_noise_amplitude = abs(white_noise_raw_fft);
% histogram(white_noise_amplitude.^2);
hold off
histogram(real(white_noise_raw_fft))
hold on
histogram(imag(white_noise_raw_fft))
[var(real(white_noise_raw_fft(:))) var(imag(white_noise_raw_fft(:)))]  % deliberate print
