function SubjectExpFile = subjectExperimentFile(ExpSettings)
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
nLevels     = ExpSettings.nBlocks;
nSessions   = ExpSettings.nSessions;
nBins       = 1;

%% Experimental values
SubjectExpFile.exp_type = ExpSettings.exp_type;
SubjectExpFile.luminance = ExpSettings.luminance;
SubjectExpFile.contrast = ExpSettings.contrast;
SubjectExpFile.target_radius = ExpSettings.target_radius;
SubjectExpFile.stimulus_size = ExpSettings.stimulus_size;
SubjectExpFile.monitor_distance = ExpSettings.monitor_distance;
SubjectExpFile.levelCompleted = zeros(nSessions, nBins);
SubjectExpFile.edgePowerBlockEdges = ExpSettings.edgePowerBlockEdges;
SubjectExpFile.edgePowerBlockCenters = ExpSettings.edgePowerBlockCenters;
SubjectExpFile.edgePowers = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.stimuliSeed = zeros(size(ExpSettings.stimuliSeed));
SubjectExpFile.stimuli = zeros(size(ExpSettings.stimuli));
SubjectExpFile.stimPosDeg = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.fixPosDeg = zeros(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.bgPixVal = ExpSettings.bgPixVal;

%% Performance values
SubjectExpFile.bTargetPresent = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.response = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.hit = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.miss = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.falseAlarm = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.correctRejection = false(nTrials, nLevels, nSessions, nBins);
SubjectExpFile.correct = false(nTrials, nLevels, nSessions, nBins);
