% COMPUTE_NAT_IMG_EFF_CODING_BINS  Efficient-coding histogram bins and the PCA
%   rotation of the steerable filter responses, measured on natural images.
%
%   Script, not a function — run it cell by cell. It is the head of the live
%   model chain: this script writes nat_im_eff_coding.mat, which
%   general.compute_edge_props_exp_pca then applies to an experiment's stimuli
%   and general.fit_edge_model_with_exps finally fits to the subjects' data.
%
%   It samples square patches from the CPS natural image database, applies the
%   eye's optical transfer function, takes steerable-filter gradients at five
%   scales, and quantises each gradient statistic into bins that each hold an
%   equal share of the natural distribution — the histogram-equalisation sense
%   of efficient coding. The same gradients also give a PCA rotation of the
%   ten filter responses (x and y at five scales), so a second, decorrelated
%   set of bins is produced alongside the raw one.
%
%   The script is meant to be run twice. The first pass computes pca_coeffs in
%   the second cell and saves it; the second pass uncomments the load in the
%   first cell so that the PCA-basis quantities are computed with it. As
%   committed, the first cell uses pca_coeffs about twenty lines before the
%   second cell computes it (B3.10), so a cold run errors there.
%
%   Inputs (all read from disk, nothing is taken from the workspace)
%     vislab-common/data/CPS natural images/*.png - 14-bit calibrated images
%       stored as 16-bit PNG, assumed 2844 x 4284 pixels.
%     vislab-common/data/nat_im_eff_coding.mat - only on a second pass, and
%       only via the commented-out load in the first cell.
%
%   Output
%     vislab-common/data/nat_im_eff_coding.mat - grey_hist_bins (1 x 17 bin
%     edges in greylevels), grad_m_bins, grad_o_bins, grad_p_bins and their
%     grad_pca_* counterparts (5 scales x 17 bin edges; magnitude in
%     greylevels per pixel, orientation in radians in [-pi, pi], product in
%     their product), and pca_coeffs (10 x 10 rotation, dimensionless). Also
%     several diagnostic figures.
%
%   Units and constants. ppd below is pixels per degree and is set to 106 here,
%   while config.m declares 60 for the stimuli these bins are later applied to,
%   and the optical transfer function is evaluated at 555 nm against config.m's
%   550 nm — that mismatch is B1.10, recorded and not fixed here. The pupil
%   diameter passed to vislab.lib.otf_filter is 4 mm. kernel sigma is in pixels
%   and kernel_n_sigma is the number of sigmas at which the filter is truncated.
%
%   Known defects on this path, recorded and not fixed here. B1.10, above.
%   B1.11: the patch start indices are drawn in the coordinates of the
%   border-cropped image but used as indices into the full image, so the
%   intended border margin is applied only at the bottom and right edges and
%   patches can still start in the top-left filter border. B3.10: pca_coeffs is
%   used before it is computed, as above, and the last cell calls pca(rgb) on an
%   rgb array that is all NaN because its only write is commented out.
%
%   The variable names saved by the last-but-one cell, and the names in the
%   commented-out cdfs.mat save, are fixed by the files on disk and were left
%   alone: grey_hist_bins, grad_m_bins, grad_o_bins, grad_p_bins,
%   grad_pca_m_bins, grad_pca_o_bins, grad_pca_p_bins, pca_coeffs, and ea, Na,
%   eb, Nb, er, Nr, coeff. That is why the bins keep the short _m/_o/_p spelling
%   while the arrays they are computed from now say magnitude, orientation and
%   product in full. thresh and pad_val keep their names because they are also
%   name-value parameter names elsewhere in the repo; both are assigned here and
%   read only by commented-out code.
%
%   See also general.COMPUTE_EDGE_PROPS_EXP_PCA, lib.STEERABLE_FILTER,
%   lib.STEERABLE_GRAD, vislab.lib.OTF_FILTER.

% compute efficient-coding histogram bins of gradient magnitude,
% orientation and product, from natural image database

% parameters
% rng(123,'twister');
ppd = 106;
norm_mean = 128;
norm_type = 3;
norm_contrast = 0.25;
n_bins_rgb = 16000;
max_pixel_value = 2^14 - 1;  % CPS images are actually 14-bit, even though saved as 16-bit
thresh = 0; %200;
pad_val = 128;  % pad patches with this mean greylevel value when taking gradients

n_samples_per_image = 20;
patch_size = 64;
n_scales = 5;
kernel_sigma_list = [1 2 4 8 16];  % steeerable kernel sd
kernel_sigma_max = kernel_sigma_list(end);
kernel_n_sigma = 3;

% maximum filter size
max_filter_size = size(lib.steerable_filter([kernel_sigma_max kernel_n_sigma]), 1);
% extra overflow size for each image patch for filtering
patch_padded_size = patch_size + 2*floor(max_filter_size/2);
% start and end indices of the larger patch, for the center part:
center_start_idx = floor((patch_padded_size - patch_size)/2) + 1;
center_end_idx = center_start_idx + patch_size - 1;

% load the PCA coefficients
% load('vislab-common/data/nat_im_eff_coding.mat');

% image size, original and after gradient border crop
source_image_size = [2844 4284];
source_image_size_crop = source_image_size - 2*kernel_sigma_max*kernel_n_sigma;

cfg = config();
files = dir(fullfile(cfg.paths.natural_images, '*.png'));
n_files = 10; %numel(files);
n_patches = n_files*n_samples_per_image;
% no. of array elements to store
n_elements = n_files*n_samples_per_image*patch_size^2;

rgb = nan(n_elements, 3);
grey_values = nan([patch_size patch_size n_patches]);
% grad_x=nan([patch_sz patch_sz num_scales n_patches]);
% grad_y=nan([patch_sz patch_sz num_scales n_patches]);
grad = nan([patch_size patch_size 2 n_scales n_patches]);
grad_magnitude = nan([patch_size patch_size n_scales n_patches]);
grad_orientation = nan([patch_size patch_size n_scales n_patches]);
grad_product = nan([patch_size patch_size n_scales n_patches]);

grad_pca = nan([patch_size patch_size 2 n_scales n_patches]);
grad_pca_magnitude = nan([patch_size patch_size n_scales n_patches]);
grad_pca_orientation = nan([patch_size patch_size n_scales n_patches]);
grad_pca_product = nan([patch_size patch_size n_scales n_patches]);

% i_el=1; % current array element
i_patch = 1;
for i_file = 1:n_files
    fprintf('%d of %d\n', i_file, n_files);
    % load image
    source_image_path = fullfile(cfg.paths.natural_images, files(i_file).name);
    source_image_rgb = double(imread(source_image_path))*255/max_pixel_value;
    % make greyscale
    source_image_grey = mean(source_image_rgb, 3);
    % apply OTF
    source_image_otf = vislab.lib.otf_filter(source_image_grey, ppd, 4, 555);

    % now sample patches
    for i_sample = 1:n_samples_per_image
        % choose patch location
        patch_row_start = randi(source_image_size_crop(1) - patch_padded_size);
        patch_col_start = randi(source_image_size_crop(2) - patch_padded_size);

        % for RGB, select patch of patch_size
        patch_rgb = source_image_rgb(patch_row_start:patch_row_start+patch_size-1, ...
            patch_col_start:patch_col_start+patch_size-1, :);
        % normalize means of each RGB channel
        patch_rgb_normalized = lib.ptch_norm(patch_rgb, norm_mean, norm_contrast, norm_type);
        % rgb(i_el:i_el+patch_sz^2-1,:)=reshape(permute(ptch_rgb, [2, 1, 3]), [], 3); % store rgb values

        % for grey values, select patch of patch_size
        patch_grey = source_image_otf(patch_row_start:patch_row_start+patch_size-1, ...
            patch_col_start:patch_col_start+patch_size-1, :);
        patch_grey = patch_grey/mean(patch_grey(:))*128;  % scale patch to a mean of 128
        grey_values(:, :, i_patch) = patch_grey;

        % for gradient, choose larger patch for filter overflow
        patch_grey = source_image_otf(patch_row_start:patch_row_start+patch_padded_size-1, ...
            patch_col_start:patch_col_start+patch_padded_size-1, :);
        patch_grey = patch_grey/mean(patch_grey(:))*128;  % scale patch to a mean of 128

        % compute patch gradients
        grad_raw_this = nan([patch_size patch_size 2 n_scales]);
        for i_scale = 1:n_scales
            kernel_size = [kernel_sigma_list(i_scale) kernel_n_sigma];

            % compute gradient using raw steerable filter
            grad_this = lib.steerable_grad(patch_grey, 'kernel_size', kernel_size);

            % OR compute gradient using custom PCA filter
            % pick out the x and y filters at this scale from the custom filter stack
            % filt=filters(:,:,[i_scale num_scales+i_scale]);
            % grad_this=lib.steerable_grad(patch_grey,'filter',filt,'kernel_size',kernel_size);

            % crop out center part of this gradient, equal to patch_size:
            grad_this = grad_this(center_start_idx:center_end_idx, ...
                center_start_idx:center_end_idx, :);

            grad_raw_this(:, :, 1, i_scale) = grad_this(:, :, 1);
            grad_raw_this(:, :, 2, i_scale) = grad_this(:, :, 2);

            % magnitude, orientation and product of gradients
            grad_magnitude_this = squeeze(vecnorm(grad_this, 2, 3));
            grad_orientation_this = squeeze(cart2pol(grad_raw_this(:, :, 1, i_scale), ...
                grad_raw_this(:, :, 2, i_scale)));
            grad_product_this = grad_magnitude_this.*grad_orientation_this;

            % threshold the pixels based on gradient magnitude
            % thresh_px=grad_m_this>thresh;

            grad_magnitude(:, :, i_scale, i_patch) = grad_magnitude_this;
            grad_orientation(:, :, i_scale, i_patch) = grad_orientation_this;
            grad_product(:, :, i_scale, i_patch) = grad_product_this;
        end

        grad(:, :, :, :, i_patch) = grad_raw_this;

        % compute and store PCA responses of the patch
        grad_raw_this_flat = reshape(permute(grad_raw_this, [1 2 4 3]), patch_size^2, []);
        grad_pca_this_flat = grad_raw_this_flat*pca_coeffs;
        grad_pca_this = reshape(grad_pca_this_flat, [patch_size patch_size 2 n_scales]);

        grad_pca(:, :, :, :, i_patch) = grad_pca_this;

        % magnitude, orientation and product of PCA gradients
        grad_pca_magnitude_this = squeeze(vecnorm(grad_pca_this, 2, 3));
        grad_pca_orientation_this = squeeze(cart2pol(grad_pca_this(:, :, 1, :), ...
            grad_pca_this(:, :, 2, :)));
        grad_pca_product_this = grad_pca_magnitude_this.*grad_pca_orientation_this;

        grad_pca_magnitude(:, :, :, i_patch) = grad_pca_magnitude_this;
        grad_pca_orientation(:, :, :, i_patch) = grad_pca_orientation_this;
        grad_pca_product(:, :, :, i_patch) = grad_pca_product_this;

        i_patch = i_patch + 1;
    end
end

%% PCA of gradient filters
grad_flat = reshape(permute(grad, [1 2 5 4 3]), [], n_scales*2);

[pca_coeffs, scores, ~, ~, explained] = pca(grad_flat);
figure
imagesc(pca_coeffs); colormap gray

% pca_responses=grad_flat*pca_coeffs;
pca_responses = reshape(permute(grad_pca, [1 2 5 4 3]), [], n_scales*2);

% show correlations of raw and PCA filter responses
corr_raw = corrcoef(grad_flat);
figure; imagesc(corr_raw)
axis square
set(gca, 'xtick', [], 'ytick', [])
colorbar_handle = vislab.lib.colorbarpzn(-1, 1);
colorbar_handle.Ticks = [-1 0 1];
title 'corr. coeff. of raw filter responses'

corr_pca = corrcoef(pca_responses);
figure; imagesc(corr_pca)
axis square
set(gca, 'xtick', [], 'ytick', [])
colorbar_handle = vislab.lib.colorbarpzn(-1, 1);
colorbar_handle.Ticks = [-1 0 1];
title 'corr. coeff. of PCA filter responses'

% show histograms of PCA responses
% figure; sgtitle('PCA responses')
% for i_scale=1:2*num_scales
%     subplot(2*num_scales,1,i_scale)
%     histogram(scores(:,i_scale),'EdgeColor','none','Normalization','pdf')
%     xlim([-100 100])
%     set(gca,'ytick',[])
% end

%% histogram equalization (efficient coding bins)
n_bins_grad = [16 16 16 16 16];
n_bins_hist = 16;
grey_hist_bins = [-inf, quantile(grey_values(:), n_bins_hist-1), inf];

grad_magnitude_flat = reshape(permute(grad_magnitude, [1 2 4 3]), [], size(grad_magnitude, 3));
grad_orientation_flat = reshape(permute(grad_orientation, [1 2 4 3]), [], size(grad_magnitude, 3));
grad_product_flat = reshape(permute(grad_product, [1 2 4 3]), [], size(grad_magnitude, 3));

grad_pca_magnitude_flat = ...
    reshape(permute(grad_pca_magnitude, [1 2 4 3]), [], size(grad_magnitude, 3));
grad_pca_orientation_flat = ...
    reshape(permute(grad_pca_orientation, [1 2 4 3]), [], size(grad_magnitude, 3));
grad_pca_product_flat = ...
    reshape(permute(grad_pca_product, [1 2 4 3]), [], size(grad_magnitude, 3));

figure(4); sgtitle('gradient magnitude');
figure(5); sgtitle('gradient orientation');
figure(6); sgtitle('gradient product');
for i_scale = 1:n_scales
    grad_m_bins(i_scale, :) = ...
        [-inf, quantile(grad_magnitude_flat(:, i_scale), n_bins_grad(i_scale)-1), inf];
    grad_o_bins(i_scale, :) = ...
        [-inf, quantile(grad_orientation_flat(:, i_scale), n_bins_grad(i_scale)-1), inf];
    grad_p_bins(i_scale, :) = ...
        [-inf, quantile(grad_product_flat(:, i_scale), n_bins_grad(i_scale)-1), inf];

    grad_pca_m_bins(i_scale, :) = ...
        [-inf, quantile(grad_pca_magnitude_flat(:, i_scale), n_bins_grad(i_scale)-1), inf];
    grad_pca_o_bins(i_scale, :) = ...
        [-inf, quantile(grad_pca_orientation_flat(:, i_scale), n_bins_grad(i_scale)-1), inf];
    grad_pca_p_bins(i_scale, :) = ...
        [-inf, quantile(grad_pca_product_flat(:, i_scale), n_bins_grad(i_scale)-1), inf];

    figure(4);
    subplot(n_scales, 2, 2*i_scale-1)
    histogram(grad_magnitude_flat(:, i_scale), 'EdgeColor', 'none', 'Normalization', 'pdf')
    xline(grad_m_bins(i_scale, :))
    xlim([0 grad_m_bins(i_scale, end-1)])

    subplot(n_scales, 2, 2*i_scale)
    histogram(grad_pca_magnitude_flat(:, i_scale), 'EdgeColor', 'none', 'Normalization', 'pdf')
    xline(grad_pca_m_bins(i_scale, :))
    xlim([0 grad_pca_m_bins(i_scale, end-1)])

    figure(5);
    subplot(n_scales, 2, 2*i_scale-1)
    histogram(grad_orientation_flat(:, i_scale), 'EdgeColor', 'none', 'Normalization', 'pdf')
    xline(grad_o_bins(i_scale, :))
    xlim([-pi pi])

    subplot(n_scales, 2, 2*i_scale)
    histogram(grad_pca_orientation_flat(:, i_scale), 'EdgeColor', 'none', 'Normalization', 'pdf')
    xline(grad_pca_o_bins(i_scale, :))
    xlim([-pi pi])

    figure(6);
    subplot(n_scales, 2, 2*i_scale-1)
    histogram(grad_product_flat(:, i_scale), 'EdgeColor', 'none', 'Normalization', 'pdf')
    xline(grad_p_bins(i_scale, :))
    xlim(grad_p_bins(i_scale, [2 end-1]))

    subplot(n_scales, 2, 2*i_scale)
    histogram(grad_pca_product_flat(:, i_scale), 'EdgeColor', 'none', 'Normalization', 'pdf')
    xline(grad_pca_p_bins(i_scale, :))
    xlim(grad_pca_p_bins(i_scale, [2 end-1]))
end

%% save efficient-coding bins and PCA coeffs and filters
save(fullfile(cfg.paths.data_root, 'nat_im_eff_coding.mat'), 'grey_hist_bins', ...
    'grad_m_bins', 'grad_o_bins', 'grad_p_bins', ...
    'grad_pca_m_bins', 'grad_pca_o_bins', 'grad_pca_p_bins', ...
    'pca_coeffs')

%% compute PCA filters
% (these are not truly PCA filters, since due to the normalization by SD, it's
% not a linear operation)

% stack all the raw steerable filters
x_filters = nan([max_filter_size max_filter_size n_scales]);
y_filters = nan([max_filter_size max_filter_size n_scales]);
for i_scale = 1:n_scales
    filter_kernel = lib.steerable_filter([kernel_sigma_list(i_scale) kernel_n_sigma]);
    pad_size = (max_filter_size - size(filter_kernel, 1))/2;
    filter_kernel = padarray(filter_kernel, [pad_size, pad_size], 0, 'both');
    x_filters(:, :, i_scale) = filter_kernel(:, :, 1);
    y_filters(:, :, i_scale) = filter_kernel(:, :, 2);
end
filters = cat(3, x_filters, y_filters);

% compute PCA filters
filters_flat = reshape(filters, [], size(filters, 3));
filters_pca_flat = filters_flat*pca_coeffs;
filters_pca = reshape(filters_pca_flat, size(filters));

% flip and re-order some of them as needed
filters_pca = filters_pca(:, :, [10 8 6 4 2 9 7 5 3 1]);
filters_pca(:, :, 2) = -filters_pca(:, :, 2);
filters_pca(:, :, 3) = -filters_pca(:, :, 3);
filters_pca(:, :, 7) = -filters_pca(:, :, 7);
filters_pca(:, :, 8) = -filters_pca(:, :, 8);

% filters_pca=nan([max_filter_sz max_filter_sz 2*num_scales]);
figure
for i_scale = 1:2*n_scales
    % filters_pca(:,:,i_scale)=sum(filters.*reshape(pca_coeffs(:,i_scale),[1 1 10]),3);
    subplot(2*n_scales, 1, i_scale); imagesc(filters_pca(:, :, i_scale));
    axis square
    colormap gray
    set(gca, 'xtick', [], 'ytick', [])
end

%% PCA of RGB
% PCA to get transformation matrix
coeff = pca(rgb);

% transform from rgb to abr
abr = rgb*coeff;

% cumulative channel responses
[Na, ea] = histcounts(abr(:, 1), n_bins_rgb, 'Normalization', 'cdf');
[Nb, eb] = histcounts(abr(:, 2), n_bins_rgb, 'Normalization', 'cdf');
[Nr, er] = histcounts(abr(:, 3), n_bins_rgb, 'Normalization', 'cdf');

% NEEDS TO BE REWRITTEN NOW THAT GM ETC HAVE 5 SCALES
% save("cdfs.mat","ea","Na","eb","Nb","er","Nr","egm","Ngm","coeff");

% plot RGB histograms
figure;
subplot(3, 1, 1);
histogram(rgb(:, 1), FaceColor='red', EdgeColor='none');
axis([0 255 0 inf]);
title 'red'
subplot(3, 1, 2);
histogram(rgb(:, 2), FaceColor='green', EdgeColor='none');
axis([0 255 0 inf]);
title 'green'
subplot(3, 1, 3);
histogram(rgb(:, 3), FaceColor='blue', EdgeColor='none');
axis([0 255 0 inf]);
title 'blue'

% plot ABR histograms
figure;
subplot(3, 1, 1);
histogram(abr(:, 1), FaceColor='black', EdgeColor='none');
axis([0 511 0 inf]);
title 'A'
subplot(3, 1, 2);
histogram(abr(:, 2), FaceColor='blue', EdgeColor='none');
axis([-128 128 0 inf]);
title 'B'
subplot(3, 1, 3);
histogram(abr(:, 3), FaceColor='red', EdgeColor='none');
axis([-128 128 0 inf]);
title 'R'

% plot gradient histograms
figure;
subplot(3, 1, 1);
histogram(grad_magnitude, EdgeColor='none');
xline(grad_m_bins)
title 'grad magnitude'
subplot(3, 1, 2);
histogram(grad_orientation, EdgeColor='none');
xline(grad_o_bins)
xlim([-pi pi]);
title 'grad orientation'
subplot(3, 1, 3);
histogram(grad_product, EdgeColor='none');
xline(grad_p_bins)
title 'grad product'

% illustrate histogram equalization
figure; hold on
plot(ea(1:end-1), Na, '-r')
axis([0 500 0 1.02])
cdf_array = linspace(0, 1, 15);
for i_cdf = 1:numel(cdf_array)
    bin_idx = find(Na>cdf_array(i_cdf), 1);
    plot([ea(bin_idx) ea(bin_idx)], [0 Na(bin_idx)], '-k')
    plot([0 ea(bin_idx)], [Na(bin_idx) Na(bin_idx)], '-k')
end
xlabel('$x$', 'Interpreter', 'latex')
ylabel cdf
set(gca, 'xtick', [], 'ytick', [0 1], 'fontsize', 13)
