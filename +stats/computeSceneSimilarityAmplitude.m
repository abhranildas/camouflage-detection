function StatsOut = computeSceneSimilarityAmplitude(imIn, tarIn, wWin, sampleCoords)
%%COMPUTESCENCESIMILARITYAMPLITUDE Computes the similarity of the image to a target in the Fourier domain
%
% Example:
%   StatsOut = COMPUTESCENESIMILARITYAMPLITUDE(imIn, tarIn, wWin, sampleCoords)
%
% Output:
%   StatsOut.S:         similarity (signed)
%   StatsOut.Smag:      magnitude of similarity (unsigned)
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>


%% Variable set up
iWin = wWin > 0;

targetSizePix  = size(tarIn);
rampSizePix = (targetSizePix(1)-1)*.1;
diskSizePix = targetSizePix(1) - rampSizePix;

cosWin = lib.cosWindowFlattop2(targetSizePix, diskSizePix, rampSizePix); 

% Pad to 128
paddedSizePix = 128;
paddedCenterPix = paddedSizePix/2;
paddedImage = zeros([paddedSizePix, paddedSizePix]);

ampRange = (paddedCenterPix-floor(size(tarIn,1)/2)):(paddedCenterPix+floor(size(tarIn,2)/2));

tarIn = tarIn.*cosWin;
tarInPadded = paddedImage;
tarInPadded(1:targetSizePix(1),1:targetSizePix(2)) = tarIn;

tarInPaddedF = fftshift(abs(fft2(tarInPadded)));
tarInNorm = sqrt(sum(tarInPaddedF(:).^2));

nSamples = size(sampleCoords, 1);

StatsOut.S    = zeros(nSamples, 1);
StatsOut.Smag = zeros(nSamples, 1);

%% Compute Similarity at each location in sampleCoords.
for sItr = 1:nSamples
    imgSmall       = lib.cropImage(imIn, sampleCoords(sItr,:), targetSizePix, [], 1);
    imgSmall       = imgSmall.*iWin;
    meanImg        = mean(imgSmall(iWin));
    imgSmall(iWin) = imgSmall(iWin) - meanImg;
    imgSmall       = imgSmall.*cosWin;
    
    imgSmallPadded = paddedImage;
    imgSmallPadded(1:targetSizePix(1),1:targetSizePix(2)) = imgSmall;
    
    imgSmallPaddedF = fftshift(abs(fft2(imgSmallPadded)));
    imgNorm = sqrt(sum(imgSmallPaddedF(:).^2));
    
    templateMatch = sum(imgSmallPaddedF(:).*tarInPaddedF(:));
   
    StatsOut.S(sItr)    = templateMatch./(imgNorm.*tarInNorm);  
    StatsOut.Smag(sItr) = abs(StatsOut.S(sItr));
end