function [surround_patch, patch, patch_windowed] = load_patch_at_index(ImgStats, patch_index, ...
    file_path, b_disp, envelope)
% LOAD_PATCH_AT_INDEX  Returns a surround and target patch at a sampled index.
%   [surround_patch, patch, patch_windowed] = lib.load_patch_at_index(ImgStats, patch_index, ...
%       file_path, b_disp, envelope)
%
%   Output
%     surround_patch - image surround patch.
%     patch          - image target patch (cropped from surround_patch).
%     patch_windowed - patch, contrast-blended through envelope, or []
%                      if no envelope was given.
%
%   v1.0, 1/15/2016, Steve Sebastian <sebastian@utexas.edu>
%
%   See also lib.CROP_IMAGE, lib.SAMPLE_PATCH_COORDINATES.

    %% Set parameters

    % if the file path is not specified, set it to a default
    if (~exist('file_path', 'var'))
        file_path = ImgStats.Settings.imgFilePath;
    end

    % if the display boolean is not set, default to 0
    if (~exist('b_disp', 'var'))
        b_disp = 0;
    end

    if (~exist('envelope', 'var'))
        envelope = [];
    end

    surround_size_px = ImgStats.Settings.surroundSizePix;
    target_size_px = ImgStats.Settings.targetSizePix;

    [coord_index, image_index] = ind2sub(size(ImgStats.C), patch_index);

    %%

    image_name = ImgStats.imgDir(image_index).name;
    load([file_path '/' image_name]);

    % crop out the surround patch
    surround_patch = lib.crop_image(I_PPM, ImgStats.sampleCoords(coord_index, :), ...
        surround_size_px, [], 1);

    % crop out the patch
    center_coord = ceil(surround_size_px/2);
    patch = lib.crop_image(surround_patch, [center_coord, center_coord], target_size_px, [], 1);

    if (~isempty(envelope))
        patch = double(patch);
        patch_windowed = ((patch-mean(patch(:))).*envelope) + mean(patch(:));
    else
        patch_windowed = [];
    end

    % plot
    if (b_disp)

        if (isempty(envelope))
            n_bits = 14;
            subplot(1, 2, 1);
            % display the image
            imagesc(surround_patch, [0 2^n_bits-1]); colormap gray; axis square;
            axis square;
            set(gca, 'xtick', []); set(gca, 'ytick', []);

            subplot(1, 2, 2);
            imagesc(patch, [0 2^n_bits-1]); colormap gray; axis square;   % display the image
            axis square;
            set(gca, 'xtick', []); set(gca, 'ytick', []);
        else
            n_bits = 8;
            patch_envelope = double(patch);
            patch_envelope = (patch_envelope-mean(patch_envelope(:))).*envelope + ...
                mean(patch_envelope(:));
            % display the image
            imagesc(patch_envelope, [0 2^n_bits-1]); colormap gray; axis square;
            axis square;
            set(gca, 'xtick', []); set(gca, 'ytick', []);
        end

    end
end
