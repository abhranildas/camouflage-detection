function StatsOut = computeSceneSimilaritySpatial(imIn, tarIn, wWin, sampleCoords)
%%COMPUTESCENCESIMILARITYSPATIAL Computes the similarity of the image to a target in the space domain
%
% Example:
%   Sstats = COMPUTESCENESIMILARITYSPATIAL(imIn, tarIn, wWin, sampleCoords)
%
% Output:
%   Sstats.S:         similarity
%   Sstats.Smag:      magnitude of similarity
%
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>

%% Compute Similarity
%% Variable set up
iWin = wWin > 0;

tarInNorm = sqrt(sum(tarIn(:).^2));

targetSizePix  = size(tarIn);
nSamples = size(sampleCoords, 1);

StatsOut.S    = zeros(nSamples, 1);
StatsOut.Smag = zeros(nSamples, 1);

%% Compute Similarity at each location in sampleCoords.
for sItr = 1:nSamples
    imgSmall       = lib.cropImage(imIn, sampleCoords(sItr,:), targetSizePix, [], 1);
    imgSmall       = imgSmall.*iWin;
    meanImg        = mean(imgSmall(iWin));
    imgSmall(iWin) = imgSmall(iWin) - meanImg;
    imgSmall       = imgSmall.*iWin;
 
    imgNorm = sqrt(sum(imgSmall(:).^2));
    
    templateMatch = sum(imgSmall(:).*tarIn(:));
   
    StatsOut.S(sItr)    = templateMatch./(imgNorm.*tarInNorm);  
    StatsOut.Smag(sItr) = abs(StatsOut.S(sItr));
end
