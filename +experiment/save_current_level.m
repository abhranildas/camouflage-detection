function save_current_level(SessionSettings, response, level_number)
% SAVE_CURRENT_LEVEL  Score one finished level and write it into the subject file.
%   experiment.save_current_level(SessionSettings, response, level_number)
%
%   Called once per level during a running experiment. Loads the subject's
%   result file, marks the level complete, stores the trial-by-trial responses
%   and the four signal-detection outcomes derived from them, prints percent
%   correct, and saves the file back.
%
%   Inputs
%     SessionSettings - session settings from experiment.load_stimuli_camouflage;
%                       uses .subjectStr, .expTypeStr, .currentBin,
%                       .currentSession and .bTargetPresent.
%     response        - n_trials x 1 responses for this level: 1 for
%                       "target present", 0 for "absent", -1 for a timeout.
%     level_number    - index of the level just finished, count.
%
%   Output
%     none (side effect: overwrites exp_files/<exp_type_str>/subject_out/<subject_str>.mat).
%
%   Three recorded defects live in this file. A timeout response of -1 scores
%   false in all four of hit/miss/false_alarm/correct_rejection while still
%   counting in n_trials (B1.6). .levelCompleted is incremented rather than set,
%   so re-running an already-finished level overshoots the true count (B2.10).
%   And .bTargetPresent is written twice with the same value, once above the
%   Performance block and once inside it (S3.13).
%
%   See also experiment.LOAD_CURRENT_SESSION, experiment.SUBJECT_EXPERIMENT_FILE.

    %% Determine current session and update to completed
    subject_str = SessionSettings.subjectStr;
    exp_type_str = SessionSettings.expTypeStr;

    cfg = config();
    file_path_subject = fullfile(cfg.paths.exp_files, exp_type_str, 'subject_out', ...
        [subject_str '.mat']);
    load(file_path_subject);

    bin_number = SessionSettings.currentBin;
    session_number = SessionSettings.currentSession;

    b_target_present = ...
        SessionSettings.bTargetPresent(:, level_number);

    SubjectExpFile.levelCompleted(session_number, bin_number) = ...
        SubjectExpFile.levelCompleted(session_number, bin_number) + 1;

    % SubjectExpFile.seeds(:,level_number,session_number, bin_number) = ...
    %     SessionSettings.seeds(:,level_number);
    % SubjectExpFile.stimuli(:,:,:,level_number,session_number, bin_number) = ...
    %     SessionSettings.stimuli(:,:,:,level_number);
    % SubjectExpFile.edgePowers(:,level_number,session_number, bin_number) = ...
    %     SessionSettings.edgePowers(:,level_number);
    % SubjectExpFile.stimPosDeg(:,level_number,session_number, bin_number) = ...
    %     SessionSettings.stimPosDeg(:,level_number);
    % SubjectExpFile.fixPosDeg(:,level_number,session_number, bin_number) = ...
    %     SessionSettings.fixPosDeg(:,level_number);
    SubjectExpFile.bTargetPresent(:, level_number, session_number, bin_number) = ...
        SessionSettings.bTargetPresent(:, level_number);

    %% Performance
    SubjectExpFile.bTargetPresent(:, level_number, session_number, bin_number) = b_target_present;
    SubjectExpFile.response(:, level_number, session_number, bin_number) = response;
    SubjectExpFile.correct(:, level_number, session_number, bin_number) = ...
        b_target_present == response;
    SubjectExpFile.hit(:, level_number, session_number, bin_number) = ...
        (b_target_present == 1 & response == 1);
    SubjectExpFile.miss(:, level_number, session_number, bin_number) = ...
        (b_target_present == 1 & response == 0);
    SubjectExpFile.falseAlarm(:, level_number, session_number, bin_number) = ...
        (b_target_present == 0 & response == 1);
    SubjectExpFile.correctRejection(:, level_number, session_number, bin_number) = ...
        (b_target_present == 0 & response == 0);

    disp(['Level ' num2str(level_number) ' completed.']);
    disp(['Percent correct: ' num2str(mean(b_target_present == response)*100)]);
    save(file_path_subject, 'SubjectExpFile');
end
