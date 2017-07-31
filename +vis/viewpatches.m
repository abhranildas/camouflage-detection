function viewpatches(ImgStats, L,C,S, targetNr, bText)
% VIEWPATCHES Step through patches in a bin.
%   Description: Step through one image at a time.
% 
%   v1 1/28/2016 R.C.Walshe (calen.walshe@utexas.edu)

if nargin == 1
    L = 8;
    C = 8;
    S = 1;
    targetNr    = 1;
    bText       = 1;
    bSave       = 0;
    imgDir      = ImgStats.Settings.imgFilePath;
end

target = ImgStats.Settings.targets(:,:,targetNr);
envelope = ImgStats.Settings.envelope;
targetSize = size(target);

patchList = ImgStats.patchIndex{targetNr,1}(L,C,S);
try 
    randPatch = randsample(patchList{1}, 100);
catch
    error('Error in acquiring patches');
end
    
[patchNr, imgNr] = ind2sub(size(ImgStats.L), randPatch);

% figure('Position', [100, 100, 21, 21]);

for i = 1:length(patchNr)

    I_PPM = load([ImgStats.Settings.imgFilePath, '\' ImgStats.imgDir(imgNr(i)).name]);
    I     = I_PPM.I_PPM;
    
    
%    cropped = lib.cropImage(I, ImgStats.sampleCoords(patchNr(i),:), targetSize(1),1,1).*envelope;
    cropped = lib.cropImage(I, ImgStats.sampleCoords(patchNr(i),:), 513,1,1);

    colormap(gray(2^14)); imagesc(cropped);

    if bText
        fprintf('L:%f\n',round(ImgStats.L(patchNr(i), imgNr(i)),2));
        fprintf('C:%f\n',round(ImgStats.C(patchNr(i), imgNr(i)),2)); 
        fprintf('S:%f\n\n',round(ImgStats.Sa(patchNr(i), imgNr(i),targetNr),2));
    end
    axis image;
    pause(.25);            
end

end