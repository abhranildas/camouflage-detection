function SubjectExpFile = subjectExperimentFile_alpha(ExpSettings)
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
nBins       = 1;

SubjectExpFile.levelCompleted = zeros(nSessions, nBins);
SubjectExpFile.bTargetPresent = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.response = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.hit = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.miss = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.falseAlarm = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.correctRejection = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.correct = false(nTrials, nLevels, nSessions, nBins);
