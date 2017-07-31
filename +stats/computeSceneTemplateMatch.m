function Tstats = computeSceneTemplateMatch(imIn, tarIn, sampleCoords) 
%%COMPUTESCENETEMPLATEMATCH Computes the template match between the target
%%                          and image at every location 
%%      each location under the window.
%
% Example:
%   Tstats = stats.COMPUTESCENETEMPLATEMATCH(imIn, tarIn, sampleCoords)
%
% Output:
%   Sstats.pClipped:  proportion of pixels clipped
%
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% v1.0, 1/14/2016, Steve Sebastian <sebastian@utexas.edu>

%%

tMatch = lib.fftconv2(imIn, tarIn);

%% output
if(isempty(sampleCoords))
    Tstats.tMatch = tMatch;
else
    inds = sub2ind(size(imIn), sampleCoords(:,1), sampleCoords(:,2));
    Tstats.tMatch = tMatch(inds);
end