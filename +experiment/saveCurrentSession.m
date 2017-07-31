function saveCurrentSession(subjectStr, expTypeStr, targetTypeStr, SessionSettings, SessionData)
%LOADCURRENSESSIONS Saves the stimuli and experiment info for the next
%session. Called only during experiment.
%
% v1.0, 1/26/2016, Steve Sebastian <sebastian@utexas.edu>

%% Determine current session and update to completed

filePathSubject = ['../subject_out/' expTypeStr '/' targetTypeStr '/' subjectStr '.mat'];
load(filePathSubject);

response = SessionData.response; 
bTargetPresent = SessionSettings.bTargetPresent;

binNumber     = SessionSettings.currentBin;
sessionNumber = SessionSettings.currentSession;

SubjectExpFile.bCompleted(binNumber, sessionNumber) = 1;

SubjectExpFile.stimuliIndex(:,:,sessionNumber, binNumber) = ...
    SessionSettings.stimuliIndex(:,:,sessionNumber);
SubjectExpFile.targetAmplitude(:,:,sessionNumber, binNumber) = ...
    SessionSettings.targetAmplitude(:,:,sessionNumber);
SubjectExpFile.targetPosDeg(:,:,sessionNumber, binNumber) = ...
    SessionSettings.targetPosDeg(:,:,sessionNumber);
SubjectExpFile.fixPosDeg(:,:,sessionNumber, binNumber) = ...
    SessionSettings.fixPosDeg(:,:,sessionNumber);
SubjectExpFile.bTargetPresent(:,:,sessionNumber, binNumber) = ...
    SessionSettings.bTargetPresent(:,:,sessionNumber);

%% Performance
SubjectExpFile.response(:,:,sessionNumber, binNumber) = response;
SubjectExpFile.correct(:,:,sessionNumber, binNumber) = ...
    bTargetPresent == response;
SubjectExpFile.hit(:,:,sessionNumber, binNumber) = ...
    (bTargetPresent == 1 && response == 1);
SubjectExpFile.miss(:,:,sessionNumber, binNumber) = ...
    (bTargetPresent == 1 && response == 0);
SubjectExpFile.falseAlarm(:,:,sessionNumber, binNumber) = ...
    (bTargetPresent == 0 && response == 1);
SubjectExpFile.correctRejection(:,:,sessionNumber, binNumber) = ...
    (bTargetPresent == 0 && response == 0);

filePathSubject = ['../subject_out/' expTypeStr '/' targetTypeStr '/' subjectStr '.mat'];

save(filePathSubject, SubjectExpFile);