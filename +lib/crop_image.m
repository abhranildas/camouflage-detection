function [patch, patch_coords_rc] = crop_image(source_image, patch_coords_rc, ...
    patch_size, ind_color_channels, b_center)
% CROP_IMAGE  Crops a patch from an image based on input coordinates in row-column form.
%   [patch, patch_coords_rc] = lib.crop_image(source_image, patch_coords_rc, ...
%       patch_size, ind_color_channels, b_center)
%
%   Output
%     patch           - cropped patch.
%     patch_coords_rc - row and column indices corresponding to patch location.
%
%   See B3.2 in the plan: the guard below tests the variable name
%   'indColorChannel' (missing the trailing 's', and never renamed alongside
%   ind_color_channels — the string is frozen evidence for the bug), so it is
%   always false and ind_color_channels is always overridden to
%   1:size(source_image,3), whatever the caller passed. Not fixed here
%   (Stage 1 is behaviour-preserving).
%
%   Steve Sebastian, Johannes Burge
%
%   See also lib.LOAD_PATCH_AT_INDEX, lib.SAMPLE_PATCH_COORDINATES.

    if length(patch_size) == 1
        patch_size = [patch_size patch_size];
    end

    if ~exist('patch_coords_rc', 'var') || isempty(patch_coords_rc)
        patch_coords_rc(1) = floor((size(source_image, 1) - patch_size(1))/2 + 1);
        patch_coords_rc(2) = floor((size(source_image, 1) - patch_size(2))/2 + 1);
    end
    if ~exist('indColorChannel', 'var') || isempty(ind_color_channels)
        ind_color_channels = 1:size(source_image, 3);
    end
    if ~exist('b_center', 'var') || isempty(b_center)
        b_center = 0;
    end

    if (b_center)
        row_range = (patch_coords_rc(1, 1) - floor(patch_size(1)./2)): ...
            (patch_coords_rc(1, 1) + ceil(patch_size(1)./2) - 1);
        col_range = (patch_coords_rc(1, 2) - floor(patch_size(2)./2)): ...
            (patch_coords_rc(1, 2) + ceil(patch_size(2)./2) - 1);
        patch = source_image(row_range, col_range, ind_color_channels);
    else
        patch = source_image(patch_coords_rc(1, 1):(patch_coords_rc(1, 1)+patch_size(2)-1), ...
            patch_coords_rc(1, 2):(patch_coords_rc(1, 2)+patch_size(1)-1), ...
            ind_color_channels);
    end
end
