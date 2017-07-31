function examplePatches(ImgStats, lIndex, targetKeyStr, bSave, filePathOut)
% PRESENTPATCHES Presents a grid of patches.
%
%   Description: View a grid of patches. Can be used to view images from
%   bins to provide a quick sanity check on the image processing routine.
%
%   Example:
%
%   % v1.0, 1/28/2016, R. C. Walshe <calen.walshe@utexas.edu>

envelope = ImgStats.Settings.envelope;
targetSizePix = ImgStats.Settings.targetSizePix;

imgFilePath = ImgStats.Settings.imgFilePath;
% imgFilePath = 'D:\sebastian\natural_images\images_disp';

bitsIn = 14;

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetKeyStr);

numBins = size(ImgStats.Settings.binCenters.L, 2);

patchMeanPercent = ImgStats.Settings.binCenters.L(lIndex)/100; 
patchMeanPix     = patchMeanPercent*(2^bitsIn-1);

h = figure('Position', [100,100, 1920,1200], ...
    'Name', ['Luminance bin = ' num2str(lIndex), ' Contrast x Similarity'], ...
    'Color', [patchMeanPercent, patchMeanPercent, patchMeanPercent]);

for iCon = 1:numBins
    for iSim = 1:numBins
         patchList = ImgStats.patchIndex{targetIndex}(lIndex,iCon,iSim);
         if ~isempty(patchList)
             
            h = lib.subplot_tight(numBins,numBins,((iCon-1)*numBins)+iSim);
            
            randPatch = randsample(patchList{1},1);

            [patchIndex, imageIndex] = ind2sub(size(ImgStats.L), randPatch);

            load([imgFilePath, '/' ImgStats.imgDir(imageIndex).name]);
            
            imgPatch = double(lib.cropImage(I_PPM, ImgStats.sampleCoords(patchIndex,:), targetSizePix,1,1));
            imgPatch = (imgPatch - patchMeanPix).*envelope + patchMeanPix;
            colormap(gray(2^bitsIn)); image(imgPatch)
            axis image;          
            set(h, 'Visible','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[])
         end
    end

end
if bSave
    saveas(h, [filePathOut, 'L',num2str(L),'-T',num2str(targetNr)],'jpg');
end