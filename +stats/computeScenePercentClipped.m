function Pstats = computeScenePercentClipped(imIn, wWin, sampleCoords) 
%%COMPUTESCENEPERCENTCLIPPED Computes the percentage of clipped pixels in
%%      each location under the window.
%
% Example:
%   Pstats = stats.COMPUTESCENEPERCENTCLIPPED(imIn, wWin, sampleCoords)
%
% Output:
%   Pstats.pClipped:  proportion of pixels clipped
%
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% v1.0, 1/14/2016, Steve Sebastian <sebastian@utexas.edu>

%%

wWin = wWin./sum(wWin(:));

maxPixelVal = max(imIn(:));

clippedImg = imIn == maxPixelVal; 

pClippedImg = lib.fftconv2(clippedImg, wWin);

%% output
if(isempty(sampleCoords))
    Pstats.pClipped = pClippedImg;
else
    inds = sub2ind(size(imIn), sampleCoords(:,1), sampleCoords(:,2));
    Pstats.pClipped = pClippedImg(inds);
end