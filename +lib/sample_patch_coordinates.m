function patch_coords_rc = samplePatchCoordinates(image_size, patch_size, patch_spacing, n_patches)
% SAMPLEPATCHCOORDINATES  Returns spaced coordinates across an image.
%   patch_coords_rc = lib.samplePatchCoordinates(image_size, patch_size, patch_spacing, n_patches)
%
%   Example
%     Return all coordinates with 128 spacing between them
%       patch_coords_rc = lib.samplePatchCoordinates(size(I), size(P), 128);
%
%     Return 10 coordinates sampled from all patches with 128 pixel spacing
%       patch_coords_rc = lib.samplePatchCoordinates(size(I), size(P), 128, 10);
%
%   Output
%     patch_coords_rc - row and column indices corresponding to patch location.
%
%   Johannes Burge
%
%   See also lib.CROPIMAGE, lib.LOADPATCHATINDEX.

    % 1/2 patch width zone in which images are not selected
    row_coord_limits = [1+round(patch_size(1)/2) image_size(1)-ceil(3*patch_size(1)/2)+1];
    col_coord_limits = [1+round(patch_size(2)/2) image_size(2)-ceil(3*patch_size(2)/2)+1];
    [row_coords, col_coords] = meshgrid(row_coord_limits(1):patch_spacing:row_coord_limits(2), ...
        col_coord_limits(1):patch_spacing:col_coord_limits(2));

    % Patch coordinates
    patch_coords_rc = [row_coords(:) col_coords(:)];

    if exist('n_patches', 'var') && ~isempty(n_patches)
        ind_p = randsample(size(patch_coords_rc, 1), n_patches);
        patch_coords_rc = patch_coords_rc(ind_p, :);
    end
end
