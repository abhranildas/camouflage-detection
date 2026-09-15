function [surround_patch, patch, patch_windowed] = loadPatchAtIndex(ImgStats, patchIndex, ...
    filePath, bDisp, envelope)
% LOADPATCHATINDEX  Returns a surround and target patch at a sampled index.
%   [surround_patch, patch, patch_windowed] = lib.loadPatchAtIndex(ImgStats, patchIndex, ...
%       filePath, bDisp, envelope)
%
%   Output
%     surround_patch - image surround patch.
%     patch          - image target patch (cropped from surround_patch).
%     patch_windowed - patch, contrast-blended through envelope, or []
%                      if no envelope was given.
%
%   v1.0, 1/15/2016, Steve Sebastian <sebastian@utexas.edu>
%
%   See also lib.CROPIMAGE, lib.SAMPLEPATCHCOORDINATES.

    %% Set parameters

    % if the file path is not specified, set it to a default
    if (~exist('filePath', 'var'))
        filePath = ImgStats.Settings.imgFilePath;
    end

    % if the display boolean is not set, default to 0
    if (~exist('bDisp', 'var'))
        bDisp = 0;
    end

    if (~exist('envelope', 'var'))
        envelope = [];
    end

    surround_size_px = ImgStats.Settings.surroundSizePix;
    target_size_px = ImgStats.Settings.targetSizePix;

    [coord_index, image_index] = ind2sub(size(ImgStats.C), patchIndex);

    %%

    image_name = ImgStats.imgDir(image_index).name;
    load([filePath '/' image_name]);

    % crop out the surround patch
    surround_patch = lib.cropImage(I_PPM, ImgStats.sampleCoords(coord_index, :), ...
        surround_size_px, [], 1);

    % crop out the patch
    center_coord = ceil(surround_size_px/2);
    patch = lib.cropImage(surround_patch, [center_coord, center_coord], target_size_px, [], 1);

    if (~isempty(envelope))
        patch = double(patch);
        patch_windowed = ((patch-mean(patch(:))).*envelope) + mean(patch(:));
    else
        patch_windowed = [];
    end

    % plot
    if (bDisp)

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
