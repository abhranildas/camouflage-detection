function Sarray = addToStatStruct(ImgStats, statFunction, statNameStr, target)
%ADDTOSTATSTRUCT Computes statistics for each image in filepath
%
% Example: 
%
%   statFunction = @stats.computeSceneSimilarityAmplitude;
%   Sarray = ADDTOSTATSTRUCT(ImgStats, @statFunction, 'S', gabor);
%   ImgStats.NameOfStatistic = Sarray;
%
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% v1.0, 3/14/2016, Steve Sebastian <sebastian@utexas.edu>

%% Variable set up.

if(nargin < 4)
    target = [];
end

surroundSizePix = ImgStats.Settings.surroundSizePix;
spacingPix      = ImgStats.Settings.spacingPix;
imgSizePix      = ImgStats.Settings.imgSizePix;

filePathStr = ImgStats.Settings.imgFilePath;

envelope = ImgStats.Settings.envelope;

sampleCoords    = lib.samplePatchCoordinates(imgSizePix, [surroundSizePix surroundSizePix], spacingPix);

D = dir([filePathStr '/*.mat']);

nSamples = size(sampleCoords,1);
nImages = size(D,1);

%% Compute statistics.

Sarray  = zeros(nSamples, nImages);

parfor iImg = 1:nImages
    disp(['Image: ' num2str(iImg) '/' num2str(nImages)]);
    
    % Load the image.
    I = load([filePathStr '/' D(iImg).name]);
    
    scene = I.I_PPM;
    
    if(isempty(target))
        StatsOut = statFunction(scene, envelope, sampleCoords);
    else
        StatsOut = statFunction(scene, target, sampleCoords);
    end
    
    % Save output
    Sarray(:,iImg) = getStatFromStruct(StatsOut, statNameStr);
    
end

end

function Sout = getStatFromStruct(StatsOut, statNameStr)
    Sout = eval(['StatsOut.' statNameStr]);
end


