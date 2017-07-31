function setUpExperiment(ImgStats)
%SETUPEXPERIMENT Creates and saves all experimental stimuli and settings
% 
% Example: 
%  SETUPEXPERIMENT(ImgStats, 'fovea'); 
%
% Output: 
%  None
%
% See also:
%   SESSIONSETTINGS
%
% v1.0, 2/18/2016, Steve Sebastian <sebastian@utexas.edu>

    %% CAMOUFLAGE    
    % Experimental bins
    binIndex = [1 5 5; 3 5 5; 5 5 5; 7 5 5; 10 5 5; ...
                5 1 5; 5 3 5; 5 7 5; 5 10 5; ...
                5 5 1; 5 5 3; 7 7 7; 10 5 5];
 
    % Contrast range for each level
    targetLvls = repmat(linspace(0.2, 0.05, 5), [size(binIndex,1) , 1]);    

    fpSettings = 'experiment_files/experiment_settings';
    fpSubjects = 'experiment_files/subject_out';
    
    nBins = size(binIndex, 1);
    nTargets = size(ImgStats.Settings.targets, 3);

    % Session files
    for iBin = 1:nBins
        for iTarget = 1:nTargets
            ExpSettings = experiment.sessionSettings(ImgStats, expTypeStr,...
                ImgStats.Settings.targetKey{iTarget}, binIndex(iBin,:), targetLvls(iBin,:));
            
            fpOut = [fpSettings '/' expTypeStr '/' ExpSettings.targetTypeStr ...
                '/L' num2str(binIndex(iBin,1)) '_C' num2str(binIndex(iBin,2)) ...
                '_S' num2str(binIndex(iBin,3)) '.mat'];
            save(fpOut, 'ExpSettings');
        end
    end
 
    %% Subject experiment files
    subjectStr = ['sps'; 'rcw'; 'jsa'; 'yhb'];

    nSubjects = size(subjectStr, 1);
    
    ExpSettings.targetTypeStr = {'gabor', 'dog'};
    
    for iSubject = 1:nSubjects
        for iTarget = 1:nTargets
            SubjectExpFile = experiment.subjectExperimentFile(ExpSettings, binIndex);
            
            fpOut = [fpSubjects '/' expTypeStr '/' ExpSettings.targetTypeStr{iTarget} ...
                '/' subjectStr(iSubject,:) '.mat']; 
            save(fpOut, 'SubjectExpFile');
        end
    end    
end
