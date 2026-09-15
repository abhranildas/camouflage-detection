% compute_texture_autocorrelation  Synthesise each named texture, compute
%     its normalised 2-D autocorrelation, and estimate its correlation
%     length from the exp(-1) contour.
%
%     compute_texture_autocorrelation
%
% Script, no arguments. For each texture (skipping the first, `'sand'`,
% at index 1), synthesises a Portilla-Simoncelli model from the matching
% `.jpg`, draws one large (2^11-pixel) sample, z-scores it, and computes
% `lib.autocorr` out to lag 50.
%
% NOTE: `rlist`/`corr_lengths` are appended to but never initialised here
% — workspace accumulators meant to persist across repeated manual runs
% (see B3.11).
%
% Inputs: `vislab-common/data/<texture_name>.jpg` for each texture in
%     `texture_names`.
% Output: one figure per texture (autocorrelation map with its exp(-1)
%     contour); `rlist` (autocorrelation maps) and `corr_lengths`
%     (pixels) appended to in the workspace. Nothing is saved to disk.
%
% See also lib.autocorr, general.compute_noise_colour.

% texture.type='pink_noise';
% texture.alpha=1;

texture_names = {'sand', 'moth', 'rock', 'spots', 'coral', 'bark', 'leaf', 'leather', ...
    'foliage', 'sand2'};

addpath(genpath('por_sim_tx_synth'))

for i_texture = 2:length(texture_names)
    source_image_path = ['vislab-common/data/' texture_names{i_texture} '.jpg'];
    source_image_grey = double(im2gray(imread(source_image_path)));
    n_scales = 4;  % Number of scales
    n_orientations = 4;  % Number of orientations
    % Spatial neighborhood is neighborhood_size x neighborhood_size coefficients
    neighborhood_size = 9;
    n_synthesis_iter = 25;  % Number of iterations of synthesis loop
    texture = struct;
    texture.type = 'por_sim';
    texture.stats = textureAnalysis(source_image_grey, n_scales, n_orientations, neighborhood_size);
    texture.Niter = n_synthesis_iter;

    tic
    stim = lib.stimulus('bg_size', 2^11, 'texture', texture);

    stim = (stim-mean(stim(:)))/std(stim(:));

    autocorr = lib.autocorr(stim, 50);
    toc

    % r=fftshift(r);

    figure;
    imagesc(autocorr); colormap gray; axis square
    hold on
    contour(autocorr, exp(-1)*[1 1], 'r');
    rlist = cat(3, rlist, autocorr);

    % avg. correlation length
    corr_length = regionprops(autocorr>=exp(-1), 'Perimeter').Perimeter/(2*pi);
    corr_lengths = [corr_lengths; corr_length]
end
