function show_example_patches(ImgStats, l_index, target_key_str, b_save, file_path_out)
% SHOW_EXAMPLE_PATCHES  Presents a grid of patches.
%   show_example_patches(ImgStats, l_index, target_key_str, b_save, file_path_out)
%
%   Description: View a grid of patches. Can be used to view images from
%   bins to provide a quick sanity check on the image processing routine.
%
%   Example:
%
%   % v1.0, 1/28/2016, R. C. Walshe <calen.walshe@utexas.edu>
%
%   BUG (new, B2-level): the final `if b_save` branch references `L` and
%   `target_nr`, neither of which is a parameter or local of this function
%   (its parameters are ImgStats, l_index, target_key_str, b_save,
%   file_path_out). Calling with b_save true errors with "Undefined
%   function or variable 'L'". Apparently copy-pasted from
%   vis.show_patch_grid, which does take L/target_nr. Left as found.

envelope = ImgStats.Settings.envelope;
target_size_pix = ImgStats.Settings.targetSizePix;

img_file_path = ImgStats.Settings.imgFilePath;
% img_file_path = 'D:\sebastian\natural_images\images_disp';

bits_in = 14;

target_index = lib.target_index_from_string(ImgStats.Settings, target_key_str);

num_bins = size(ImgStats.Settings.binCenters.L, 2);

patch_mean_percent = ImgStats.Settings.binCenters.L(l_index)/100;
patch_mean_pix = patch_mean_percent*(2^bits_in-1);

h = figure('Position', [100, 100, 1920, 1200], ...
    'Name', ['Luminance bin = ' num2str(l_index), ' Contrast x Similarity'], ...
    'Color', [patch_mean_percent, patch_mean_percent, patch_mean_percent]);

for i_con = 1:num_bins
    for i_sim = 1:num_bins
        patch_list = ImgStats.patchIndex{target_index}(l_index, i_con, i_sim);
        if ~isempty(patch_list)

            h = lib.subplot_tight(num_bins, num_bins, ((i_con-1)*num_bins)+i_sim);

            rand_patch = randsample(patch_list{1}, 1);

            [patch_index, image_index] = ind2sub(size(ImgStats.L), rand_patch);

            load([img_file_path, '/' ImgStats.imgDir(image_index).name]);

            % B2.15: lib.crop_image's guard variable is misspelled
            % ('indColorChannel'), so ind_color_channels below is always
            % overridden to every channel regardless of the `1` passed
            % here. Left as found (Stage 1 is behaviour-preserving).
            img_patch = double(lib.crop_image(I_PPM, ImgStats.sampleCoords(patch_index, :), ...
                target_size_pix, 1, 1));
            img_patch = (img_patch - patch_mean_pix).*envelope + patch_mean_pix;
            colormap(gray(2^bits_in)); image(img_patch)
            axis image;
            set(h, 'Visible', 'off', 'XTickLabel', [], 'XTick', [], 'YTickLabel', [], 'YTick', [])
        end
    end

end
if b_save
    saveas(h, [file_path_out, 'L', num2str(L), '-T', num2str(target_nr)], 'jpg');
end
