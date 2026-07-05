function presentpatches(ImgStats, L, targetNr,bSave, outPath)
% PRESENTPATCHES Presents a grid of patches.
%
%   Description: View a grid of patches. Can be used to view images from
%   bins to provide a quick sanity check on the image processing routine.
%
%   Example:
%
%   % v1.0, 1/28/2016, R. C. Walshe <calen.walshe@utexas.edu>
%close all;
h = figure('Position', [100,100, 1920,1200], 'Name', ['Luminance bin = ' num2str(L), ' Contrast x Similarity']);

envelope = ImgStats.Settings.envelope;
targetSizePix = ImgStats.Settings.targetSizePix;

for i = 1:10
    for j = 1:10
         patchList        = ImgStats.patchIndex{targetNr,1}(L,i,j);
         if ~isempty(patchList{1})
            h = lib.subplot_tight(10,10,((i-1)*10)+j);
            randPatch        = randsample(patchList{1},1);

            [patchNr, imgNr] = ind2sub(size(ImgStats.L), randPatch);

            I_PPM = load([ImgStats.Settings.imgFilePath, '/' ImgStats.imgDir(imgNr).name]);
            I = I_PPM.I_PPM;
    
            cropped = lib.cropImage(I, ImgStats.sampleCoords(patchNr,:), targetSizePix,1,1).*envelope;
            
            cropped = experiment.gammaCorrect(cropped, 2, 14,14);
            
            colormap(gray(2^14));image(cropped)
            axis image;          
            set(gca,'xtick',[],'ytick',[]);
         end
    end

end
if bSave
    saveas(h, [outPath, 'L',num2str(L),'-T',num2str(targetNr)],'jpg');
end