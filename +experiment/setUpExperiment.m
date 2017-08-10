function setUpExperiment()
%SETUPEXPERIMENT Creates and saves all experimental stimuli and settings
% 
% Example: 
%  SETUPEXPERIMENT(); 
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
    binIndex = [1];
 
    % Contrast range for each level
    targetLvls = repmat(0.15, [size(binIndex,1) , 1]);    

    fpSettings = 'experiment_files/experiment_settings';
    fpSubjects = 'experiment_files/subject_out';
    
    nBins = size(binIndex, 1);
    % nTargets = size(ImgStats.Settings.targets, 3);

    % Session files
    for iBin = 1:nBins
        %for iTarget = 1:nTargets
            ExpSettings = experiment.sessionSettings(binIndex(iBin,:), targetLvls(iBin,:));
            
            fpOut = [fpSettings '/camo.mat'];
            save(fpOut, 'ExpSettings');
        %end
    end
 
    %% Subject experiment files
    subjectStr = ['ad'; 'ss'; 'cw'];

    nSubjects = size(subjectStr, 1);   

    
    for iSubject = 1:nSubjects
        %for iTarget = 1:nTargets
            SubjectExpFile = experiment.subjectExperimentFile(ExpSettings, binIndex);
            
            fpOut = [fpSubjects '/camo_' subjectStr(iSubject,:) '.mat']; 
            save(fpOut, 'SubjectExpFile');
        %end
    end    
end
