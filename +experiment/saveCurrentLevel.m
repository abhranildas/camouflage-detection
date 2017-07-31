function saveCurrentLevel(SessionSettings, response, levelNumber)
%LOADCURRENSESSIONS Saves the stimuli and experiment info for the next
%session. Called only during experiment.
%
% v1.0, 1/26/2016, Steve Sebastian <sebastian@utexas.edu>

%% Determine current session and update to completed

subjectStr    = SessionSettings.subjectStr;
expTypeStr    = SessionSettings.expTypeStr;
targetTypeStr = SessionSettings.targetTypeStr;

filePathSubject = ['experiment_files/subject_out/' expTypeStr '/' targetTypeStr '/' subjectStr '.mat'];
load(filePathSubject);

binNumber     = SessionSettings.currentBin;
sessionNumber = SessionSettings.currentSession;

bTargetPresent = ...
    SessionSettings.bTargetPresent(:,levelNumber);

  SubjectExpFile.levelCompleted(sessionNumber, binNumber) = ...
    SubjectExpFile.levelCompleted(sessionNumber, binNumber) + 1;

SubjectExpFile.stimuliIndex(:,levelNumber,sessionNumber, binNumber) = ...
    SessionSettings.stimuliIndex(:,levelNumber);
SubjectExpFile.targetAmplitude(:,levelNumber,sessionNumber, binNumber) = ...
    SessionSettings.targetAmplitude(:,levelNumber);
SubjectExpFile.stimPosDeg(:,levelNumber,sessionNumber, binNumber) = ...
    SessionSettings.stimPosDeg(:,levelNumber);
SubjectExpFile.fixPosDeg(:,levelNumber,sessionNumber, binNumber) = ...
    SessionSettings.fixPosDeg(:,levelNumber);
SubjectExpFile.bTargetPresent(:,levelNumber,sessionNumber, binNumber) = ...
    SessionSettings.bTargetPresent(:,levelNumber);

%% Performance
SubjectExpFile.bTargetPresent(:,levelNumber,sessionNumber, binNumber) = bTargetPresent;
SubjectExpFile.response(:,levelNumber,sessionNumber, binNumber) = response;
SubjectExpFile.correct(:,levelNumber,sessionNumber, binNumber) = ...
    bTargetPresent == response;
SubjectExpFile.hit(:,levelNumber,sessionNumber, binNumber) = ...
    (bTargetPresent == 1 & response == 1);
SubjectExpFile.miss(:,levelNumber,sessionNumber, binNumber) = ...
    (bTargetPresent == 1 & response == 0);
SubjectExpFile.falseAlarm(:,levelNumber,sessionNumber, binNumber) = ...
    (bTargetPresent == 0 & response == 1);
SubjectExpFile.correctRejection(:,levelNumber,sessionNumber, binNumber) = ...
    (bTargetPresent == 0 & response == 0);

disp(['Level ' num2str(levelNumber) ' completed.']);
disp(['Percent correct: ' num2str(mean(bTargetPresent == response)*100)]);
save(filePathSubject, 'SubjectExpFile');