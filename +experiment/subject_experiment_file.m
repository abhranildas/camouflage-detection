function SubjectExpFile = subject_experiment_file(ExpSettings)
% SUBJECT_EXPERIMENT_FILE  Preallocate one subject's result file for an experiment.
%   SubjectExpFile = experiment.subject_experiment_file(ExpSettings)
%
%   Creates the empty per-subject record that the experiment fills in level by
%   level: which trials were target-present, what the subject responded, and
%   the four signal-detection outcome flags derived from the two.
%
%   Inputs
%     ExpSettings - experiment settings struct from experiment.session_settings;
%                   uses .nTrials, .nLevels and .nSessions (all counts).
%
%   Output
%     SubjectExpFile - struct with .levelCompleted (nSessions x nBins count of
%                      levels finished) and seven nTrials x nLevels x
%                      nSessions x nBins logical arrays: .bTargetPresent,
%                      .response, .hit, .miss, .falseAlarm,
%                      .correctRejection, .correct.
%
%   nBins is fixed at 1: the luminance/contrast bin structure of the earlier
%   natural-image experiments is not used by the camouflage experiment, but
%   the fourth dimension is kept so the stored arrays keep their shape.
%
%   Two recorded defects concern this file. .response is preallocated logical,
%   so the timeout code -1 that experiment.main.response_interval returns is
%   stored as false and scores in none of the four outcome categories (B1.6).
%   And .binIndex, which experiment.load_current_session reads on its
%   five-argument path, is never created here (B2.7).
%
%   These field names are serialised into every subject .mat file on disk, so
%   none of them may be renamed without a migration (zone 3, S3.10).
%
%   .nLevels is also the field the _texture_exponent chain stopped emitting,
%   renaming it .nBlocks, so this function errors on settings produced by
%   experiment.session_settings_texture_exponent (B2.6).
%
%   See also experiment.SET_UP_EXPERIMENT, experiment.SESSION_SETTINGS,
%   experiment.SAVE_CURRENT_LEVEL.

    nTrials = ExpSettings.nTrials;
    nLevels = ExpSettings.nLevels;
    nSessions = ExpSettings.nSessions;
    nBins = 1;

    SubjectExpFile.levelCompleted = zeros(nSessions, nBins);
    SubjectExpFile.bTargetPresent = false(nTrials, nLevels, nSessions, nBins);
    SubjectExpFile.response = false(nTrials, nLevels, nSessions, nBins);
    SubjectExpFile.hit = false(nTrials, nLevels, nSessions, nBins);
    SubjectExpFile.miss = false(nTrials, nLevels, nSessions, nBins);
    SubjectExpFile.falseAlarm = false(nTrials, nLevels, nSessions, nBins);
    SubjectExpFile.correctRejection = false(nTrials, nLevels, nSessions, nBins);
    SubjectExpFile.correct = false(nTrials, nLevels, nSessions, nBins);
end
