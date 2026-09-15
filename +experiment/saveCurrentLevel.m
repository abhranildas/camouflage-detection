function saveCurrentLevel(SessionSettings, response, levelNumber)
% SAVECURRENTLEVEL  Score one finished level and write it into the subject file.
%   experiment.saveCurrentLevel(SessionSettings, response, levelNumber)
%
%   Called once per level during a running experiment. Loads the subject's
%   result file, marks the level complete, stores the trial-by-trial responses
%   and the four signal-detection outcomes derived from them, prints percent
%   correct, and saves the file back.
%
%   Inputs
%     SessionSettings - session settings from experiment.loadStimuliCamouflage;
%                       uses .subjectStr, .expTypeStr, .currentBin,
%                       .currentSession and .bTargetPresent.
%     response        - nTrials x 1 responses for this level: 1 for
%                       "target present", 0 for "absent", -1 for a timeout.
%     levelNumber     - index of the level just finished, count.
%
%   Output
%     none (side effect: overwrites exp_files/<expTypeStr>/subject_out/<subjectStr>.mat).
%
%   Three recorded defects live in this file. A timeout response of -1 scores
%   false in all four of hit/miss/falseAlarm/correctRejection while still
%   counting in nTrials (B1.6). .levelCompleted is incremented rather than set,
%   so re-running an already-finished level overshoots the true count (B2.10).
%   And .bTargetPresent is written twice with the same value, once above the
%   Performance block and once inside it (S3.13).
%
%   See also experiment.LOADCURRENTSESSION, experiment.SUBJECTEXPERIMENTFILE.

    %% Determine current session and update to completed
    subjectStr = SessionSettings.subjectStr;
    expTypeStr = SessionSettings.expTypeStr;

    filePathSubject = ['exp_files/' expTypeStr '/subject_out/' subjectStr '.mat'];
    load(filePathSubject);

    binNumber = SessionSettings.currentBin;
    sessionNumber = SessionSettings.currentSession;

    bTargetPresent = ...
        SessionSettings.bTargetPresent(:, levelNumber);

    SubjectExpFile.levelCompleted(sessionNumber, binNumber) = ...
        SubjectExpFile.levelCompleted(sessionNumber, binNumber) + 1;

    % SubjectExpFile.seeds(:,levelNumber,sessionNumber, binNumber) = ...
    %     SessionSettings.seeds(:,levelNumber);
    % SubjectExpFile.stimuli(:,:,:,levelNumber,sessionNumber, binNumber) = ...
    %     SessionSettings.stimuli(:,:,:,levelNumber);
    % SubjectExpFile.edgePowers(:,levelNumber,sessionNumber, binNumber) = ...
    %     SessionSettings.edgePowers(:,levelNumber);
    % SubjectExpFile.stimPosDeg(:,levelNumber,sessionNumber, binNumber) = ...
    %     SessionSettings.stimPosDeg(:,levelNumber);
    % SubjectExpFile.fixPosDeg(:,levelNumber,sessionNumber, binNumber) = ...
    %     SessionSettings.fixPosDeg(:,levelNumber);
    SubjectExpFile.bTargetPresent(:, levelNumber, sessionNumber, binNumber) = ...
        SessionSettings.bTargetPresent(:, levelNumber);

    %% Performance
    SubjectExpFile.bTargetPresent(:, levelNumber, sessionNumber, binNumber) = bTargetPresent;
    SubjectExpFile.response(:, levelNumber, sessionNumber, binNumber) = response;
    SubjectExpFile.correct(:, levelNumber, sessionNumber, binNumber) = ...
        bTargetPresent == response;
    SubjectExpFile.hit(:, levelNumber, sessionNumber, binNumber) = ...
        (bTargetPresent == 1 & response == 1);
    SubjectExpFile.miss(:, levelNumber, sessionNumber, binNumber) = ...
        (bTargetPresent == 1 & response == 0);
    SubjectExpFile.falseAlarm(:, levelNumber, sessionNumber, binNumber) = ...
        (bTargetPresent == 0 & response == 1);
    SubjectExpFile.correctRejection(:, levelNumber, sessionNumber, binNumber) = ...
        (bTargetPresent == 0 & response == 0);

    disp(['Level ' num2str(levelNumber) ' completed.']);
    disp(['Percent correct: ' num2str(mean(bTargetPresent == response)*100)]);
    save(filePathSubject, 'SubjectExpFile');
end
