% compute_noise_colour  Estimate a synthesised texture's 1/f^alpha spectral
%     exponent (overall and per orientation) and its correlation length.
%
%     compute_noise_colour
%
% Script, not a function — run it cell by cell. Cell 1 synthesises a
% Portilla-Simoncelli texture from `bark.png`, draws `n_samples` stimuli,
% averages their Fourier power spectra, and fits a log-log slope (alpha)
% to the radial spectrum, then repeats the fit within each of `n_angles`
% orientation bins. Cell 2 estimates the texture's spatial correlation
% length via 2-D autocorrelation.
%
% NOTE: `alphas` (appended to at the end of each cell) is never
% initialised in this script — it is a workspace accumulator meant to
% persist across repeated manual runs (see B3.11: this repo has several
% scripts that read workspace variables they never define).
%
% Inputs: `cfg.paths.textures`/natural/bark.png (source texture for the P-S
%     synthesis model).
% Output: several figures (log-log spectrum fits, per-orientation slices);
%     `alphas` appended to in the workspace. Nothing is saved to disk.
%
% See also general.compute_edge_powers_camo, general.compute_texture_autocorrelation.

cfg = config();
addpath(genpath(cfg.paths.por_sim))
source_image_path = fullfile(cfg.paths.textures, 'natural', 'bark.png');
source_image_grey = double(im2gray(imread(source_image_path)));
n_scales = 4;  % Number of scales
n_orientations = 4;  % Number of orientations
neighborhood_size = 9;  % Spatial neighborhood is neighborhood_size x neighborhood_size coefficients
n_synthesis_iter = 25;  % Number of iterations of synthesis loop
texture = struct;
texture.type = 'por_sim';
texture.stats = textureAnalysis(source_image_grey, n_scales, n_orientations, neighborhood_size);
texture.Niter = n_synthesis_iter;

% texture.type='pink_noise';
% texture.alpha=8;

bg_size = 256;
n_samples = 10;
n_angles = 20;

%% estimate noise alpha exponent

stim_fft = nan(bg_size, bg_size, n_samples);
tic
parfor i_samp = 1:n_samples
    i_samp
    stim = lib.stimulus('texture', texture);
    stim_fft(:, :, i_samp) = fft2(stim);
end
toc

mean_spectrum = fftshift(mean(abs(stim_fft), 3));

figure
subplot(2, 1, 1);
imagesc(log(mean_spectrum)); axis square

freq_x = -bg_size/2+1:bg_size/2;
freq_y = freq_x';
freq_radius = sqrt(freq_x.^2+freq_y.^2);

x = log(freq_radius(freq_radius~=0)); y = log(mean_spectrum(freq_radius~=0));
subplot(2, 1, 2); plot(x, y, '.')
fit_coeffs = polyfit(x, y, 1);
lsline
alpha = abs(fit_coeffs(1));
title(alpha)

% separate by orientation
figure
theta = atan(freq_x./freq_y);
[~, ~, theta_bin] = histcounts(theta(:), n_angles);
theta_bin = reshape(theta_bin, [256 256]);
alpha_ang = nan(1, n_angles);
for i_samp = 1:n_angles
    % i_samp indexes orientation bins here, not samples — it ranges over
    % n_angles, not n_samples, matching the roles the two parfor loops
    % above and below use this counter for (see general note on this
    % pattern: one old name maps to one new name per check_stage1).
    spectrum_slice = log(mean_spectrum);
    spectrum_slice(theta_bin~=i_samp) = nan;
    subplot(2, 1, 1);
    imagesc(spectrum_slice); axis square

    x = log(freq_radius(freq_radius~=0 & theta_bin==i_samp));
    y = log(mean_spectrum(freq_radius~=0 & theta_bin==i_samp));
    subplot(2, 1, 2); plot(x, y, '.')
    fit_coeffs = polyfit(x, y, 1);
    lsline
    alpha_ang(i_samp) = fit_coeffs(1);
    title(alpha_ang(i_samp))
    pause
end
alpha = max(abs(alpha_ang));

alphas = [alphas; alpha]  % deliberate: printed for interactive inspection

%% estimate correlation length

corr_size = 2*bg_size-1;
x = linspace(-corr_size/2, corr_size/2, corr_size);
y = x';
[theta, lag_distance] = cart2pol(x, y);
% d=sqrt(x.^2+y.^2);

tic
parfor i_samp = 1:n_samples
    stim = lib.stimulus('texture', texture, 'bg_size', bg_size);
    autocorr = xcorr2(stim);
    autocorr = autocorr/max(autocorr(:));
    autocorr = autocorr>exp(-1);
    corr_interp = scatteredInterpolant(autocorr(:), theta(:), lag_distance(:));
    plot(corr_interp(zeros([1 100]), linspace(0, 10, 100)))
end
toc

figure(1)
subplot(2, 1, 1);
imagesc(log(mean_spectrum)); axis square


x = log(freq_radius(freq_radius~=0)); y = log(mean_spectrum(freq_radius~=0));
subplot(2, 1, 2); plot(x, y, '.')
fit_coeffs = polyfit(x, y, 1);
lsline
alpha = abs(fit_coeffs(1));
title(alpha)

% % separate by orientation
% figure(2)
% th=atan(u./v);
% [~,~,th_bin]=histcounts(th(:),n_ang);
% th_bin=reshape(th_bin,[256 256]);
% alpha_ang=nan(1,n_ang);
% for i=1:n_ang
%     f_slice=log(mean_f);
%     f_slice(th_bin~=i)=nan;
%     subplot(2,1,1);
%     imagesc(f_slice); axis square
%
%     x=log(k(k~=0 & th_bin==i)); y=log(mean_f(k~=0 & th_bin==i));
%     subplot(2,1,2); plot(x,y,'.')
%     p=polyfit(x,y,1);
%     lsline
%     alpha_ang(i)=p(1);
%     title(alpha_ang(i))
%     pause
% end
% alpha=max(abs(alpha_ang));

alphas = [alphas; alpha]  % deliberate: printed for interactive inspection
