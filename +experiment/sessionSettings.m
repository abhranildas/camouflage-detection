function SessionSettings = sessionSettings(ImgStats, targetTypeStr, binIndex, targetLvls)
%SESSIONSETTINGS Loads settings and stimuli for each experimental session 
% 
% Example: 
%  ExpSettings = SESSIONSETTINGS(ImgStats, 'fovea', [5 5 5], linspace(0.05, 0.2, 5)); 
%
% Output: 
%  ExpSettings Structure containing stimuli and experiment settings
%
% See also:
%   LOADSTIMULIADDITIVE
%
% v1.0, 1/22/2016, Steve Sebastian <sebastian@utexas.edu>
% v1.1, 2/4/2016,  R. Calen Walshe <calen.walshe@utexas.edu> Added
% peripheral settings.


%% CAMOUFLAGE

stimulusIntervalMs = 200;
responseInvervalMs = 1000;
fixationIntervalMs = 400;
blankIntervalMs    = 100;

monitorMaxPix = 255;    

imgFilePath = ImgStats.Settings.imgFilePath;

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);
target = ImgStats.Settings.targets(:,:,targetIndex);

nLevels = length(targetLvls);
nTrials = 30;
nSessions = 2;

pTarget = 0.5;

pixelsPerDeg = 120;

edgeEnergy = repmat(targetLvls, [nTrials, 1, nSessions]);

stimPosDeg = zeros(nTrials, nLevels, nSessions, 2);
fixPosDeg = zeros(nTrials, nLevels, nSessions, 2);

loadSessionStimuli = @experiment.loadStimuliAdditive;

bTargetPresent  = experiment.generateTargetPresentMatrix(nTrials, nLevels, nSessions, pTarget);

sampleMethod = 'random';
imgSet       = 'N';

[stimuli, stimulusSeed] = experiment.samplePatchesForExperiment(ImgStats, ...
    targetTypeStr, binIndex, nTrials, nLevels, nSessions, sampleMethod, imgSet);

bgPixVal = ImgStats.Settings.binCenters.L(binIndex(1))*monitorMaxPix./100;

SessionSettings = struct('binIndex', binIndex, 'monitorMaxPix', monitorMaxPix, ...
    'imgFilePath', imgFilePath, 'target', target, 'targetTypeStr', targetTypeStr, ...
    'nLevels', nLevels, 'nTrials', nTrials, 'nSessions', nSessions, 'sampleMethod', sampleMethod, ...
    'pTarget', pTarget, 'pixelsPerDeg', pixelsPerDeg, 'stimPosDeg', stimPosDeg, ...
    'fixPosDeg', fixPosDeg, 'loadSessionStimuli', loadSessionStimuli, ...
    'bTargetPresent', bTargetPresent, 'edgeEnergy', edgeEnergy, ...
    'stimuli', stimuli, 'stimulusSeed', stimulusSeed, 'bgPixVal', bgPixVal, ...
    'stimulusIntervalMs', stimulusIntervalMs, 'responseIntervalMs', responseInvervalMs, ...
    'fixationIntervalMs', fixationIntervalMs, 'blankIntervalMs', blankIntervalMs);  
    
end
