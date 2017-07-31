function SessionSettings = loadStimuliUniform(ExpSettings)
%LOADSTIMULIADDITIVE Formats and loads stimuli for experiment 
% 
% Example: 
%  SessionSettings = LOADSTIMULIOCCLUDING(ExpSettings, monitorSizePix, 1); 
%
% Output: 
%  SessionSettings Structure containing stimuli and experiment settings
%
% v1.0, 2/4/2016 R. Calen Walshe <calen.walshe@utexas.edu>

%LOADSTIMULIADDITIVE Formats and loads stimuli for experiment 
% 
% Example: 
%  SessionSettings = LOADSTIMULIADDITIVE(ExpSettings, monitorSizePix, 1); 
%
% Output: 
%  SessionSettings Structure containing stimuli and experiment settings
%
% v1.0, 1/22/2016, Steve Sebastian <sebastian@utexas.edu>

%% Set up 

gammaValue = 1.972;

bFovea = 0;

 levelStartIndex = ExpSettings.levelStartIndex;
subjectStr = ExpSettings.subjectStr; 
expTypeStr = ExpSettings.expTypeStr;
targetTypeStr = ExpSettings.targetTypeStr;

currentBin = ExpSettings.currentBin;
currentSession = ExpSettings.currentSession;

monitorSizePix = ExpSettings.monitorSizePix;

stimuliIndex = ExpSettings.stimuliIndex(:,:,currentSession); 
stimuli = ExpSettings.stimuli(:,:,:,:,currentSession);
target = ExpSettings.target;
targetContrast = ExpSettings.targetContrast(:,:,currentSession);
targetAmplitude = ExpSettings.targetAmplitude(:,:,currentSession);
bTargetPresent = ExpSettings.bTargetPresent(:,:,currentSession);
bgPixVal = ExpSettings.bgPixVal; 
bgPixValGamma = ExpSettings.bgPixValGamma; 
pixelsPerDeg = ExpSettings.pixelsPerDeg; 

stimPosDeg = ExpSettings.stimPosDeg(:,:,currentSession, :);
fixPosDeg = ExpSettings.fixPosDeg(:,:,currentSession, :);

stimPosPix = lib.monitorDegreesToPixels(stimPosDeg, monitorSizePix, pixelsPerDeg);
fixPosPix = lib.monitorDegreesToPixels(fixPosDeg, monitorSizePix, pixelsPerDeg);

bAdditive   = 0;
bitDepthIn  = 16;
bitDepthOut = 8;

responseIntervalS = ExpSettings.responseIntervalMs/1000;
stimulusIntervalS = ExpSettings.stimulusIntervalMs/1000;
fixationIntervalS = ExpSettings.fixationIntervalMs/1000;
blankIntervalS    = ExpSettings.blankIntervalMs/1000;

% Create the circular mask
maskSizePix      = size(stimuli(:,:,:,1,1));
maskCenterXY     = [ceil(maskSizePix(1)/2) ceil(maskSizePix(2)/2)];
maskRadiusPix    = ceil((maskSizePix(1)-1)/2); 
[maskX, maskY]   = meshgrid(-(maskCenterXY(1)-1):(maskSizePix(1)-maskCenterXY(1)), -(maskCenterXY(2)-1):(maskSizePix(2)-maskCenterXY(2)));
circMask        = ((maskX.^2+maskY.^2)<=(maskRadiusPix.^2));

nTrials = ExpSettings.nTrials;
nLevels = ExpSettings.nLevels;

tWin = ExpSettings.envelope;

%% Add stimuli to backgrounds
for iTrials = 1:nTrials
    for iLevels = 1:nLevels
        thisStimulus = stimuli(:,:,iTrials,iLevels);
        %thisStimulus(:,:) = bgPixVal; % Uniform background.
        
        if(bTargetPresent(iTrials, iLevels))
            thisTarget = target/std(target(:)) .* targetContrast(iTrials,iLevels) .* (2^bitDepthIn-1)/2 + (2^bitDepthIn-1)/2;
            
             thisStimulus = ...
                round(lib.embedImageinCenter(thisStimulus, thisTarget, bAdditive, bitDepthOut, [], [], tWin));
        end
        
        % Apply the mask
        thisStimulus(~circMask) = bgPixVal;
        
        % Apply the gamma correction
        thisStimulus = experiment.gammaCorrect(thisStimulus, gammaValue, bitDepthIn, bitDepthOut);
        
        stimuli(:,:,iTrials,iLevels) = thisStimulus;

    end
end

%% Create target examples
targetSamples = bgPixVal.*ones([size(stimuli, 1) size(stimuli,2), iLevels]);


for iLevels = 1:nLevels
    thisTarget ...
               = target .* mean(targetContrast(:,iLevels)) .* floor((2^bitDepthIn-1)/2) + floor((2^bitDepthIn-1)/2);
    
    thisSample = ...
        lib.embedImageinCenter(targetSamples(:,:,iLevels), thisTarget, bAdditive, bitDepthOut, [], [], tWin);
    targetSamples(:,:,iLevels) = experiment.gammaCorrect(thisSample, gammaValue, bitDepthIn, bitDepthOut);
end

%% Create the fixation target
crossWidth          = round(pixelsPerDeg.*0.1);
fixationSize        = floor(pixelsPerDeg.*0.5)-1;
fixationPixelVal    = 127;
fixationTarget      = zeros(fixationSize, fixationSize,3);
fixationTarget(round(fixationSize/2) - crossWidth/2:round(fixationSize/2) + crossWidth/2,:,1) = fixationPixelVal; % Only in the R dimension
fixationTarget(:,round(fixationSize/2) - crossWidth/2:round(fixationSize/2) + crossWidth/2,1) = fixationPixelVal; % Only in the R dimension

%% Save

SessionSettings = struct('stimuli', stimuli, 'bTargetPresent', bTargetPresent, 'stimPosPix', stimPosPix, ...
    'fixPosPix', fixPosPix,'bgPixValGamma', bgPixValGamma, 'targetSamples', targetSamples, ...
    'responseIntervalS', responseIntervalS, 'fixationIntervalS', fixationIntervalS, ...
    'stimulusIntervalS', stimulusIntervalS, 'blankIntervalS', blankIntervalS, ...
    'fixationTarget', fixationTarget, 'nTrials', nTrials, 'nLevels', nLevels, ...
    'pixelsPerDeg', pixelsPerDeg, 'bFovea', bFovea, ...
    'levelStartIndex', levelStartIndex, 'subjectStr', subjectStr, 'expTypeStr', expTypeStr, ...
    'targetTypeStr', targetTypeStr, 'currentBin', currentBin, 'currentSession', currentSession, ...
    'stimuliIndex', stimuliIndex, 'targetAmplitude', targetAmplitude, ...
    'stimPosDeg', stimPosDeg, 'fixPosDeg', fixPosDeg);
