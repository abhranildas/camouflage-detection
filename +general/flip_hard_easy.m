% flip_hard_easy  Reverse the level order (hard <-> easy) of an
%     experiment's settings and, separately, of one subject's results.
%
%     flip_hard_easy
%
% Script, no arguments. Expects `ExpSettings` and/or `SubjectExpFile`
% already in the workspace. Flips `ExpSettings.bTargetPresent` (dimension
% 2, levels) and `.stimuli` (dimension 4, levels) before running an
% experiment, and flips `SubjectExpFile`'s per-trial outcome fields
% (dimension 2, levels) after running it, then flips `ExpSettings` back —
% cited in B1.2 as evidence that a level-order mismatch elsewhere is not
% explained by this script.
%
% Inputs: workspace `ExpSettings`/`SubjectExpFile` structs, as above.
% Output: the same structs, with the fields above flipped along their
%     level dimension. Nothing is saved to disk.
%
% See also general.compute_edge_props_exp_pca.

% before running experiment
ExpSettings.bTargetPresent = flip(ExpSettings.bTargetPresent, 2);
ExpSettings.stimuli = flip(ExpSettings.stimuli, 4);

% after running experiment
SubjectExpFile.bTargetPresent = flip(SubjectExpFile.bTargetPresent, 2);
SubjectExpFile.response = flip(SubjectExpFile.response, 2);
SubjectExpFile.hit = flip(SubjectExpFile.hit, 2);
SubjectExpFile.miss = flip(SubjectExpFile.miss, 2);
SubjectExpFile.falseAlarm = flip(SubjectExpFile.falseAlarm, 2);
SubjectExpFile.correct = flip(SubjectExpFile.correct, 2);
SubjectExpFile.correctRejection = flip(SubjectExpFile.correctRejection, 2);

ExpSettings.bTargetPresent = flip(ExpSettings.bTargetPresent, 2);
ExpSettings.stimuli = flip(ExpSettings.stimuli, 4);
