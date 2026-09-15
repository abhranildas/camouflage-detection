% shuffle_unshuffle_expt  Shuffle a pink-noise experiment's trial order
%     into an unblocked session, and unshuffle a subject's unblocked
%     results back into blocked order.
%
%     shuffle_unshuffle_expt
%
% Script, not a function — run it cell by cell, and expects `ExpSettings`/
% `SubjectExpFile`/`SubjectExpFile_unblocked` in the workspace as each
% cell needs them (see the load comments in cells 2-3, which are notes
% to the user rather than live code).
%
% BUG (new, B2-level, display only): cell 1's loop reassigns its own loop
% variable (`i_stim = i_stim+1`, unsuppressed) — MATLAB's `for` ignores
% this for iteration purposes, so the loop still runs correctly, but the
% printed progress count is off by one every iteration. Left as found.
%
% Inputs: workspace `ExpSettings`/`SubjectExpFile`/
%     `SubjectExpFile_unblocked` structs, as above.
% Output: `ExpSettings2`, `ExpSettings_shuffle` (shuffled copies) and an
%     updated `SubjectExpFile` (unshuffled in place) in the workspace.
%     Nothing is saved to disk (the save is a comment, a note to the
%     user).
%
% See also general.analyze_shuffled_expt.

%% shuffle pink noise experiment
idx = randperm(numel(ExpSettings.stimuliSeed));

ExpSettings2.stimuliSeed = reshape(ExpSettings.stimuliSeed(idx), size(ExpSettings.stimuliSeed));
ExpSettings2.bTargetPresent = reshape(ExpSettings.bTargetPresent(idx), ...
    size(ExpSettings.bTargetPresent));
ExpSettings2.edgePowers = reshape(ExpSettings.edgePowers(idx), size(ExpSettings.edgePowers));
ExpSettings2.pClipped = reshape(ExpSettings.pClipped(idx), size(ExpSettings.pClipped));
stimuli = nan(size(ExpSettings.stimuli));

for i_stim = 1:numel(idx)
    [i_trial_new, i_level_new, i_session_new] = ind2sub(size(ExpSettings.stimuliSeed), i_stim);
    [i_trial_orig, i_level_orig, i_session_orig] = ind2sub(size(ExpSettings.stimuliSeed), ...
        idx(i_stim));
    stimuli(:, :, i_trial_new, i_level_new, i_session_new) = ...
        ExpSettings.stimuli(:, :, i_trial_orig, i_level_orig, i_session_orig);
    i_stim = i_stim+1
end

ExpSettings2.stimuli = stimuli;

SubjectExpFile.stimuliSeed = ExpSettings.stimuliSeed;
SubjectExpFile.bTargetPresent = ExpSettings.bTargetPresent;
SubjectExpFile.edgePowers = ExpSettings.edgePowers;
SubjectExpFile.stimuli = ExpSettings.stimuli;

%% shuffle the experiment
% load ExpSettings and shuffle indices
ExpSettings_shuffle = ExpSettings;
for i_orig = 1:ExpSettings_shuffle.nSessions*ExpSettings_shuffle.nLevels*ExpSettings_shuffle.nTrials
    ExpSettings_shuffle.bTargetPresent(i_orig) = ExpSettings.bTargetPresent(idx(i_orig));
    ExpSettings_shuffle.edgePowers(i_orig) = ExpSettings.edgePowers(idx(i_orig));
    ExpSettings_shuffle.seeds(i_orig) = ExpSettings.seeds(idx(i_orig));

    [i_trial, i_level, i_session] = ind2sub([30 10 4], i_orig);
    [i_trial_shuffle, i_level_shuffle, i_session_shuffle] = ind2sub([30 10 4], idx(i_orig));
    ExpSettings_shuffle.stimuli(:, :, i_trial, i_level, i_session) = ...
        ExpSettings.stimuli(:, :, i_trial_shuffle, i_level_shuffle, i_session_shuffle);
end


%% unshuffle the data

% load unblocked experiment, and rename SubjectExpFile to SubjectExpFile_unblocked
% load shuffle indices
% load blocked experiment

SubjectExpFile.response(idx) = SubjectExpFile_unblocked.response;
SubjectExpFile.hit(idx) = SubjectExpFile_unblocked.hit;
SubjectExpFile.miss(idx) = SubjectExpFile_unblocked.miss;
SubjectExpFile.falseAlarm(idx) = SubjectExpFile_unblocked.falseAlarm;
SubjectExpFile.correctRejection(idx) = SubjectExpFile_unblocked.correctRejection;
SubjectExpFile.correct(idx) = SubjectExpFile_unblocked.correct;

% save SubjectExpFile and SubjectExpFile_unblocked
