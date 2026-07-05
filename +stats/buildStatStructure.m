function ImgStats = buildStatStructure(Settings)
%BUILDSTATSTRUCTURE Computes statistics for each image in filepath
%
% Example: 
%   Settings = stats.EXPERIMENTSETTINGS('fovea');
%   ImgStats = BUILDSTATSTRUCTURE(Settings);
%   
%   See also BINIMAGESTATS, COMPUTESCENESTATS.
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>

%% Variable set up.
surroundSizePix = Settings.surroundSizePix;
spacingPix      = Settings.spacingPix;
imgSizePix      = Settings.imgSizePix;

filePathStr = Settings.imgFilePath;

targets = Settings.targets;
envelope = Settings.envelope;

nTargets = size(Settings.targets,2);
pixelMax = Settings.pixelMax;

sampleCoords    = lib.samplePatchCoordinates(imgSizePix, [surroundSizePix surroundSizePix], spacingPix);

D = dir([filePathStr '/*.mat']);

nSamples = size(sampleCoords,1);
nTargets = length(Settings.targetKey);
nImages = size(D,1);

%% Compute statistics.

L  = zeros(nSamples, nImages);
C  = zeros(nSamples, nImages);
Sa = zeros(nSamples, nImages, nTargets);
Ss = zeros(nSamples, nImages, nTargets);
tMatch = zeros(nSamples, nImages, nTargets);
pClipped     = zeros(nSamples, nImages);

parfor iImg = 1:nImages
    disp(['Image: ' num2str(iImg) '/' num2str(nImages)]);
    
    % Load the image.
    I = load([filePathStr '/' D(iImg).name]);
    
    scene = I.I_PPM;
    
    StatsOut = stats.computeSceneStats(scene, targets, ...
        envelope, sampleCoords, pixelMax);
    
    % Save output
    L(:,iImg)        = StatsOut.L;
    C(:,iImg)        = StatsOut.C;
    pClipped(:,iImg) = StatsOut.pClipped;

    for iTarget = 1:nTargets
        Sa(:,iImg, iTarget)     = StatsOut.Sa{iTarget};
        Ss(:,iImg, iTarget)     = StatsOut.Ss{iTarget};
        tMatch(:,iImg, iTarget) = StatsOut.tMatch{iTarget};
    end
end

%% Save output.
ImgStats = struct('L', L, 'C', C, 'Sa', Sa, 'Ss', Ss, 'tMatch', tMatch, 'pClipped', pClipped,  ...
                  'sampleCoords', sampleCoords, 'imgDir', D, 'Settings', Settings);


