function show_patches_one_by_one(ImgStats, L, C, S, target_nr, b_text)
% SHOW_PATCHES_ONE_BY_ONE  Step through patches in a bin.
%   show_patches_one_by_one(ImgStats, L, C, S, target_nr, b_text)
%
%   Description: Step through one image at a time.
%
%   v1 1/28/2016 R.C.Walshe (calen.walshe@utexas.edu)

if nargin == 1
    L = 8;
    C = 8;
    S = 1;
    target_nr = 1;
    b_text = 1;
end

patch_list = ImgStats.patchIndex{target_nr, 1}(L, C, S);
try
    rand_patch = randsample(patch_list{1}, 100);
catch
    error('Error in acquiring patches');
end

[patch_nr, img_nr] = ind2sub(size(ImgStats.L), rand_patch);

% figure('Position', [100, 100, 21, 21]);

for i_patch = 1:length(patch_nr)

    I_PPM = load([ImgStats.Settings.imgFilePath, '\' ImgStats.imgDir(img_nr(i_patch)).name]);
    I = I_PPM.I_PPM;

    % B2.15: lib.crop_image's guard variable is misspelled
    % ('indColorChannel'), so ind_color_channels below is always overridden
    % to every channel regardless of the `1` passed here. Left as found
    % (Stage 1 is behaviour-preserving).
    % cropped = lib.crop_image(I, ImgStats.sampleCoords(patchNr(i_patch), :), ...
    %     targetSize(1), 1, 1).*envelope;
    cropped = lib.crop_image(I, ImgStats.sampleCoords(patch_nr(i_patch), :), 513, 1, 1);

    colormap(gray(2^14)); imagesc(cropped);

    if b_text
        fprintf('L:%f\n', round(ImgStats.L(patch_nr(i_patch), img_nr(i_patch)), 2));
        fprintf('C:%f\n', round(ImgStats.C(patch_nr(i_patch), img_nr(i_patch)), 2));
        fprintf('S:%f\n\n', round(ImgStats.Sa(patch_nr(i_patch), img_nr(i_patch), target_nr), 2));
    end
    axis image;
    pause(.25);
end

end
