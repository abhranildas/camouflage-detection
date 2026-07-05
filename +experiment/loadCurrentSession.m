function SettingsOut = loadCurrentSession(subjectStr, expTypeStr, condition, sessionNumber, levelNumber)
%LOADCURRENTSESSION Load the stimuli and experiment info for the next
%session. Called only during experiment.
%
% v1.0, 1/26/2016, Steve Sebastian <sebastian@utexas.edu>

%% Determine current session

filePathSubject = ['exp_files/' expTypeStr '/subject_out/' subjectStr '.mat'];
load(filePathSubject);

if(nargin < 4)
    nLevels = size(SubjectExpFile.bTargetPresent,2);        

    % Check for experiment files that have not been completed
    % Check for not completed session
    [notCompletedSession, notCompletedBin] = ...
        find(SubjectExpFile.levelCompleted < nLevels);

    if(isempty(notCompletedBin) && isempty(notCompletedSession))
        error('Error: All bins, sessions, and levels have been completed');
    end

    % lower sessions first
    sIndex = find(min(notCompletedSession)==notCompletedSession);
    
    currentBin     = notCompletedBin(sIndex(1));
    currentSession = notCompletedSession(sIndex(1));
    
    %condition = SubjectExpFile.condition(currentBin, :);
    levelCompleted = SubjectExpFile.levelCompleted(currentSession, currentBin);
    levelStartIndex = levelCompleted + 1;
else
    currentSession = sessionNumber; 
    currentBin = find(ismember(SubjectExpFile.binIndex, condition, 'rows') == 1);
    levelStartIndex = levelNumber;
end


% disp(['Loading bin: L' num2str(SubjectExpFile.luminance) ' C' num2str(SubjectExpFile.contrast)]);
disp(['Session ' num2str(currentSession) ', Level ' num2str(levelStartIndex)]);

%% Load settings

filePathSession = ['exp_files/' expTypeStr '/exp_settings.mat'];
load(filePathSession);

save(filePathSubject, 'SubjectExpFile');

SettingsOut = ExpSettings;
SettingsOut.bgPixVal = ExpSettings.bgPixVal./255;
SettingsOut.bgPixValGamma = experiment.gammaCorrect(SettingsOut.bgPixVal, 2.089, 8);
SettingsOut.subjectStr = subjectStr;
SettingsOut.expTypeStr = expTypeStr;
SettingsOut.levelStartIndex = levelStartIndex;
SettingsOut.currentBin = currentBin;
SettingsOut.currentSession = currentSession;

