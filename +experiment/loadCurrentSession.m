function SettingsOut = loadCurrentSession(subjectStr, expTypeStr, condition, sessionNumber, ...
    levelNumber)
% LOADCURRENTSESSION  Find and load the next session a subject has still to run.
%   SettingsOut = experiment.loadCurrentSession(subjectStr, expTypeStr)
%   SettingsOut = experiment.loadCurrentSession(subjectStr, expTypeStr, condition, ...
%       sessionNumber, levelNumber)
%
%   With two arguments, scans the subject's result file for the first session
%   and bin whose levels are not all complete and resumes there, lowest
%   session first. With five, jumps straight to the level named by the
%   caller, which is how a single level is re-run.
%
%   Inputs
%     subjectStr    - subject initials, matching the subject .mat filename.
%     expTypeStr    - experiment name, matching the exp_files/ subdirectory.
%     condition     - bin identifier, matched row-wise against
%                     SubjectExpFile.binIndex. Five-argument path only.
%     sessionNumber - session to run, count. Five-argument path only.
%     levelNumber   - level to start at, count. Five-argument path only.
%
%   Output
%     SettingsOut - the stored ExpSettings struct with the current run's
%                   bookkeeping added: .bgPixVal rescaled from 8-bit pixel
%                   values to [0, 1], .bgPixValGamma its gamma-compressed
%                   form, plus .subjectStr, .expTypeStr, .levelStartIndex,
%                   .currentBin and .currentSession.
%
%   Two recorded defects. SubjectExpFile.binIndex, read on the five-argument
%   path, is never created by experiment.subjectExperimentFile (B2.7). And the
%   subject file is saved back unmodified before the settings are returned,
%   rewriting a large file for nothing (S3.13).
%
%   The gamma value 2.089 and bit depth 8 are hardcoded here and separately in
%   experiment.loadStimuliCamouflage; they describe the same monitor.
%
%   See also experiment.SAVECURRENTLEVEL, experiment.LOADSTIMULICAMOUFLAGE.

    %% Determine current session
    filePathSubject = ['exp_files/' expTypeStr '/subject_out/' subjectStr '.mat'];
    load(filePathSubject);

    if(nargin < 4)
        nLevels = size(SubjectExpFile.bTargetPresent, 2);

        % Check for experiment files that have not been completed
        % Check for not completed session
        [notCompletedSession, notCompletedBin] = ...
            find(SubjectExpFile.levelCompleted < nLevels);

        if(isempty(notCompletedBin) && isempty(notCompletedSession))
            error('Error: All bins, sessions, and levels have been completed');
        end

        % lower sessions first
        earliestSessionIndex = find(min(notCompletedSession) == notCompletedSession);

        currentBin = notCompletedBin(earliestSessionIndex(1));
        currentSession = notCompletedSession(earliestSessionIndex(1));

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
end
