function SubjectExpFile = subjectExperimentFile(ExpSettings, binIndex)
%SUBJECTEXPERIMENTFILE Initialize all matrices for subject out in
%experiment
% 
% Example: 
%  ExpSettings = SUBJECTEXPERIMENTFILE(ExpSettings, nBins); 
%
% Output: 
%  SubjectExpFile Structure containing subject output values
%
% See also:
%   SETUPEXPERIMENT, SESSIONSETTINGS
%
% v1.0, 2/18/2016, Steve Sebastian <sebastian@utexas.edu>

%% 
nTrials     = ExpSettings.nTrials;
nLevels     = ExpSettings.nLevels;
nSessions   = ExpSettings.nSessions;
nBins       = size(binIndex, 1);

%% Experimental values
SubjectExpFile.binIndex = binIndex;
SubjectExpFile.levelCompleted = zeros(nSessions, nBins);
SubjectExpFile.edgeEnergy = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.stimPosDeg = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.fixPosDeg = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.stimulusSeed = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.pixelsPerDeg = ExpSettings.pixelsPerDeg;
SubjectExpFile.bgPixVal = ExpSettings.bgPixVal;

%% Performance values
SubjectExpFile.bTargetPresent = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.response = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.hit = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.miss = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.falseAlarm = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.correctRejection = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.correct = zeros(nTrials, nLevels, nSessions, nBins);
