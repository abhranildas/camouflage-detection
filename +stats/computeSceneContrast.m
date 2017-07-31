function Cstats = computeSceneContrast(imIn, wWin, sampleCoords)
%COMPUTESCENECONTRAST Computes the windowed contrast for a single image
%
% Example: 
%   Cstats = COMPUTESCENECONTRAST(imIn, wWin, sampleCoords);
%   
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% Steve Sebastian, Yoon Bai, Spencer Chen 2016, University of Texas, sebastian@utexas.edu

%% Preprocess images

% force envelope volume to 1
wWin = wWin./sum(sum(wWin));

% luminance variance
lumBar  = lib.fftconv2(imIn, wWin);

weightedSquaredNorm   = lib.fftconv2(imIn.^2, wWin) - lumBar.^2;
weightedSquaredNorm(weightedSquaredNorm < 0) = 0;
lumWeightedLocalNorm  = sqrt(weightedSquaredNorm);

cRms                  = lumWeightedLocalNorm ./ lumBar;

%% save patch information and statistics
% store image statistics 
if(isempty(sampleCoords))
    Cstats.Crms = cRms;
else
    inds = sub2ind(size(imIn), sampleCoords(:,1), sampleCoords(:,2));
    Cstats.Crms = cRms(inds);
end
