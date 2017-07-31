function Lstats = computeSceneLuminance(imIn, wWin, sampleCoords)
%COMPUTESCENELUMINANCE Computes the windowed mean luminance for a single image
%
% Example: 
%   Lstats = COMPUTESCENELUMINANCE(imIn, wWin, sampleCoords);
%   
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% v1.0, 1/5/2016, Steve Sebastian, Yoon Bai, Spencer Chen <sebastian@utexas.edu>



%% Preprocess images

% force envelope volume to 1
wWin = wWin / sum(wWin(:));

% local mean luminance
lumBar  = lib.fftconv2(imIn, wWin);

%% output
if(isempty(sampleCoords))
    Lstats.L       = lumBar;
else
    inds = sub2ind(size(imIn), sampleCoords(:,1), sampleCoords(:,2));
    Lstats.L = lumBar(inds);
end
