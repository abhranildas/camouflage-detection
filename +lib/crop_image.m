function [patch, patch_coords_rc] = cropImage(source_image, patch_coords_rc, ...
    patch_size, indColorChannels, bCenter)
% CROPIMAGE  Crops a patch from an image based on input coordinates in row-column form.
%   [patch, patch_coords_rc] = lib.cropImage(source_image, patch_coords_rc, ...
%       patch_size, indColorChannels, bCenter)
%
%   Output
%     patch           - cropped patch.
%     patch_coords_rc - row and column indices corresponding to patch location.
%
%   See B3.2 in the plan: the guard below tests the variable name
%   'indColorChannel' (missing the trailing 's'), so it is always false and
%   indColorChannels is always overridden to 1:size(source_image,3),
%   whatever the caller passed. Not fixed here (Stage 1 is behaviour-preserving).
%
%   Steve Sebastian, Johannes Burge
%
%   See also lib.LOADPATCHATINDEX, lib.SAMPLEPATCHCOORDINATES.

    if length(patch_size) == 1
        patch_size = [patch_size patch_size];
    end

    if ~exist('patch_coords_rc', 'var') || isempty(patch_coords_rc)
        patch_coords_rc(1) = floor((size(source_image, 1) - patch_size(1))/2 + 1);
        patch_coords_rc(2) = floor((size(source_image, 1) - patch_size(2))/2 + 1);
    end
    if ~exist('indColorChannel', 'var') || isempty(indColorChannels)
        indColorChannels = 1:size(source_image, 3);
    end
    if ~exist('bCenter', 'var') || isempty(bCenter)
        bCenter = 0;
    end

    if (bCenter)
        row_range = (patch_coords_rc(1, 1) - floor(patch_size(1)./2)): ...
            (patch_coords_rc(1, 1) + ceil(patch_size(1)./2) - 1);
        col_range = (patch_coords_rc(1, 2) - floor(patch_size(2)./2)): ...
            (patch_coords_rc(1, 2) + ceil(patch_size(2)./2) - 1);
        patch = source_image(row_range, col_range, indColorChannels);
    else
        patch = source_image(patch_coords_rc(1, 1):(patch_coords_rc(1, 1)+patch_size(2)-1), ...
            patch_coords_rc(1, 2):(patch_coords_rc(1, 2)+patch_size(1)-1), ...
            indColorChannels);
    end
end
