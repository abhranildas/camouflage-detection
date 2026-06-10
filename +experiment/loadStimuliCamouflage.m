function SessionSettings = loadStimuliCamouflage(ExpSettings)
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

gammaValue = 2.089;

bFovea = 1;

levelStartIndex = ExpSettings.levelStartIndex;
subjectStr = ExpSettings.subjectStr; 
expTypeStr = ExpSettings.expTypeStr;

currentBin = ExpSettings.currentBin;
currentSession = ExpSettings.currentSession;

monitorSizePix = ExpSettings.monitorSizePix;

seeds = ExpSettings.seeds(:,:,currentSession); 
stimuli = ExpSettings.stimuli(:,:,:,:,currentSession);
% edgePowerBlockEdges = ExpSettings.edgePowerBlockEdges;
% edgePowers = ExpSettings.edgePowers(:,:,currentSession); 
bTargetPresent = ExpSettings.bTargetPresent(:,:,currentSession);
bgPixVal = ExpSettings.bgPixVal; 
bgPixValGamma = ExpSettings.bgPixValGamma; 
pixelsPerDeg = ExpSettings.monitor_distance; 

stimPosDeg = ExpSettings.stimPosDeg(:,:,currentSession, :);
fixPosDeg = ExpSettings.fixPosDeg(:,:,currentSession, :);

stimPosPix = lib.monitorDegreesToPixels(stimPosDeg, monitorSizePix, pixelsPerDeg);
fixPosPix = lib.monitorDegreesToPixels(fixPosDeg, monitorSizePix, pixelsPerDeg);
  
responseIntervalS = ExpSettings.responseIntervalMs/1000;
stimulusIntervalS = ExpSettings.stimulusIntervalMs/1000;
fixationIntervalS = ExpSettings.fixationIntervalMs/1000;
blankIntervalS    = ExpSettings.blankIntervalMs/1000;

nTrials = ExpSettings.nTrials;
nLevels = ExpSettings.nLevels;

%% Gamma correct stimuli
% and change to 8-bits

bitDepthOut = 8;

for iTrial = 1:nTrials
    for iLevel = 1:nLevels
        thisStimulus = stimuli(:,:,iTrial,iLevel);
        % clip:
        thisStimulus(thisStimulus>1)=1;
        thisStimulus(thisStimulus<0)=0;
        
        thisStimulus = experiment.gammaCorrect(thisStimulus, gammaValue, bitDepthOut);        
        stimuli(:,:,iTrial,iLevel) = thisStimulus;
    end
end

%% Create target examples

% target outline
[~,target_outline]=lib.target_mask('bg_size',ExpSettings.stimulus_size,'target_radius',ExpSettings.target_radius);
target_outline(:,[1 end])=1;
target_outline([1 end],:)=1;
target_outline=double(~target_outline);
target_outline(target_outline==1)=ExpSettings.luminance;
targetSamples=repmat(experiment.gammaCorrect(target_outline,gammaValue,bitDepthOut),[1 1 ExpSettings.nLevels]);

% example camouflage target at each level
% targetSamples=experiment.gammaCorrect(experiment.generate_camouflage_stimuli...
%     (1,ExpSettings.edgeEnergies(1,:,1),size(ExpSettings.stimuli,1),...
%     ExpSettings.condition(3),ExpSettings.condition(1),ExpSettings.condition(2),...
%     ones(1,ExpSettings.nLevels)),gammaValue,bitDepthOut);
%% Create the fixation target

fixationSize = round(pixelsPerDeg.*0.1);
fixationPixelVal = 0.5*bgPixVal;
fixationTarget = fixationPixelVal.*ones(fixationSize, fixationSize);
fixationTarget = experiment.gammaCorrect(fixationTarget, gammaValue, bitDepthOut);

%% Save

SessionSettings = struct('bTargetPresent', bTargetPresent, 'stimPosPix', stimPosPix, ...
    'fixPosPix', fixPosPix,'bgPixValGamma', bgPixValGamma, 'targetSamples', targetSamples, ...
    'responseIntervalS', responseIntervalS, 'fixationIntervalS', fixationIntervalS, ...
    'stimulusIntervalS', stimulusIntervalS, 'blankIntervalS', blankIntervalS, ...
    'fixationTarget', fixationTarget, 'nTrials', nTrials, 'nLevels', nLevels, ...
    'pixelsPerDeg', pixelsPerDeg, 'bFovea', bFovea, ...
    'levelStartIndex', levelStartIndex, 'subjectStr', subjectStr, 'expTypeStr', expTypeStr, ...
    'currentBin', currentBin, 'currentSession', currentSession, ...
    'seeds', seeds, 'stimuli', stimuli,... %     'edgePowerBlockEdges', edgePowerBlockEdges, 'edgePowers', edgePowers,...
    'stimPosDeg', stimPosDeg, 'fixPosDeg', fixPosDeg);