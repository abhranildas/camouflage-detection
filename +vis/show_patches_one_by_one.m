function show_patches_one_by_one(ImgStats, L, C, S, targetNr, bText)
% SHOW_PATCHES_ONE_BY_ONE  Step through patches in a bin.
%   show_patches_one_by_one(ImgStats, L, C, S, targetNr, bText)
%
%   Description: Step through one image at a time.
%
%   v1 1/28/2016 R.C.Walshe (calen.walshe@utexas.edu)

if nargin == 1
    L = 8;
    C = 8;
    S = 1;
    targetNr = 1;
    bText = 1;
end

patchList = ImgStats.patchIndex{targetNr, 1}(L, C, S);
try
    randPatch = randsample(patchList{1}, 100);
catch
    error('Error in acquiring patches');
end

[patchNr, imgNr] = ind2sub(size(ImgStats.L), randPatch);

% figure('Position', [100, 100, 21, 21]);

for i_patch = 1:length(patchNr)

    I_PPM = load([ImgStats.Settings.imgFilePath, '\' ImgStats.imgDir(imgNr(i_patch)).name]);
    I = I_PPM.I_PPM;

    % B2.15: lib.crop_image's guard variable is misspelled
    % ('indColorChannel'), so indColorChannels below is always overridden
    % to every channel regardless of the `1` passed here. Left as found
    % (Stage 1 is behaviour-preserving).
    % cropped = lib.crop_image(I, ImgStats.sampleCoords(patchNr(i_patch), :), ...
    %     targetSize(1), 1, 1).*envelope;
    cropped = lib.crop_image(I, ImgStats.sampleCoords(patchNr(i_patch), :), 513, 1, 1);

    colormap(gray(2^14)); imagesc(cropped);

    if bText
        fprintf('L:%f\n', round(ImgStats.L(patchNr(i_patch), imgNr(i_patch)), 2));
        fprintf('C:%f\n', round(ImgStats.C(patchNr(i_patch), imgNr(i_patch)), 2));
        fprintf('S:%f\n\n', round(ImgStats.Sa(patchNr(i_patch), imgNr(i_patch), targetNr), 2));
    end
    axis image;
    pause(.25);
end

end
