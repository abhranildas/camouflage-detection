function show_patch_grid(ImgStats, L, target_nr, b_save, out_path)
% SHOW_PATCH_GRID  Presents a grid of patches.
%   show_patch_grid(ImgStats, L, target_nr, b_save, out_path)
%
%   Description: View a grid of patches. Can be used to view images from
%   bins to provide a quick sanity check on the image processing routine.
%
%   Example:
%
%   % v1.0, 1/28/2016, R. C. Walshe <calen.walshe@utexas.edu>
%close all;
h = figure('Position', [100, 100, 1920, 1200], ...
    'Name', ['Luminance bin = ' num2str(L), ' Contrast x Similarity']);

envelope = ImgStats.Settings.envelope;
target_size_pix = ImgStats.Settings.targetSizePix;

for i_con = 1:10
    for i_sim = 1:10
        patch_list = ImgStats.patchIndex{target_nr, 1}(L, i_con, i_sim);
        if ~isempty(patch_list{1})
            h = lib.subplot_tight(10, 10, ((i_con-1)*10)+i_sim);
            rand_patch = randsample(patch_list{1}, 1);

            [patch_nr, img_nr] = ind2sub(size(ImgStats.L), rand_patch);

            I_PPM = load([ImgStats.Settings.imgFilePath, '/' ImgStats.imgDir(img_nr).name]);
            I = I_PPM.I_PPM;

            % B2.15: lib.crop_image's guard variable is misspelled
            % ('indColorChannel'), so ind_color_channels below is always
            % overridden to every channel regardless of the `1` passed
            % here. Left as found (Stage 1 is behaviour-preserving).
            cropped = lib.crop_image(I, ImgStats.sampleCoords(patch_nr, :), ...
                target_size_pix, 1, 1).*envelope;

            cropped = experiment.gamma_correct(cropped, 2, 14, 14);

            colormap(gray(2^14)); image(cropped)
            axis image;
            set(gca, 'xtick', [], 'ytick', []);
        end
    end

end
if b_save
    saveas(h, [out_path, 'L', num2str(L), '-T', num2str(target_nr)], 'jpg');
end
