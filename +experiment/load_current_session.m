function SettingsOut = load_current_session(subject_str, exp_type_str, condition, ...
    session_number, ...
    level_number)
% LOAD_CURRENT_SESSION  Find and load the next session a subject has still to run.
%   SettingsOut = experiment.load_current_session(subject_str, exp_type_str)
%   SettingsOut = experiment.load_current_session(subject_str, exp_type_str, condition, ...
%       session_number, level_number)
%
%   With two arguments, scans the subject's result file for the first session
%   and bin whose levels are not all complete and resumes there, lowest
%   session first. With five, jumps straight to the level named by the
%   caller, which is how a single level is re-run.
%
%   Inputs
%     subject_str    - subject initials, matching the subject .mat filename.
%     exp_type_str   - experiment name, matching the exp_files/ subdirectory.
%     condition      - bin identifier, matched row-wise against
%                      SubjectExpFile.binIndex. Five-argument path only.
%     session_number - session to run, count. Five-argument path only.
%     level_number   - level to start at, count. Five-argument path only.
%
%   Output
%     SettingsOut - the stored ExpSettings struct with the current run's
%                   bookkeeping added: .bgPixVal rescaled from 8-bit pixel
%                   values to [0, 1], .bgPixValGamma its gamma-compressed
%                   form, plus .subjectStr, .expTypeStr, .levelStartIndex,
%                   .currentBin and .currentSession.
%
%   Two recorded defects. SubjectExpFile.binIndex, read on the five-argument
%   path, is never created by experiment.subject_experiment_file (B2.7). And the
%   subject file is saved back unmodified before the settings are returned,
%   rewriting a large file for nothing (S3.13).
%
%   The gamma value 2.089 and bit depth 8 are hardcoded here and separately in
%   experiment.load_stimuli_camouflage; they describe the same monitor.
%
%   See also experiment.SAVE_CURRENT_LEVEL, experiment.LOAD_STIMULI_CAMOUFLAGE.

    %% Determine current session
    cfg = config();
    file_path_subject = fullfile(cfg.paths.exp_files, exp_type_str, 'subject_out', ...
        [subject_str '.mat']);
    load(file_path_subject);

    if(nargin < 4)
        n_levels = size(SubjectExpFile.bTargetPresent, 2);

        % Check for experiment files that have not been completed
        % Check for not completed session
        [not_completed_session, not_completed_bin] = ...
            find(SubjectExpFile.levelCompleted < n_levels);

        if(isempty(not_completed_bin) && isempty(not_completed_session))
            error('Error: All bins, sessions, and levels have been completed');
        end

        % lower sessions first
        earliest_session_index = find(min(not_completed_session) == not_completed_session);

        current_bin = not_completed_bin(earliest_session_index(1));
        current_session = not_completed_session(earliest_session_index(1));

        %condition = SubjectExpFile.condition(current_bin, :);
        level_completed = SubjectExpFile.levelCompleted(current_session, current_bin);
        level_start_index = level_completed + 1;
    else
        current_session = session_number;
        current_bin = find(ismember(SubjectExpFile.binIndex, condition, 'rows') == 1);
        level_start_index = level_number;
    end

    % disp(['Loading bin: L' num2str(SubjectExpFile.luminance) ' C' num2str(SubjectExpFile.contrast)]);
    disp(['Session ' num2str(current_session) ', Level ' num2str(level_start_index)]);

    %% Load settings
    file_path_session = fullfile(cfg.paths.exp_files, exp_type_str, 'exp_settings.mat');
    load(file_path_session);

    save(file_path_subject, 'SubjectExpFile');

    SettingsOut = ExpSettings;
    SettingsOut.bgPixVal = ExpSettings.bgPixVal./255;
    SettingsOut.bgPixValGamma = experiment.gamma_correct(SettingsOut.bgPixVal, 2.089, 8);
    SettingsOut.subjectStr = subject_str;
    SettingsOut.expTypeStr = exp_type_str;
    SettingsOut.levelStartIndex = level_start_index;
    SettingsOut.currentBin = current_bin;
    SettingsOut.currentSession = current_session;
end
