function experimentStruct = test_experiment_struct(BlockStimuli)
% TEST_EXPERIMENT_STRUCT  Build a minimal experimentStruct for ad-hoc Psychtoolbox testing.
%   experimentStruct = experiment.main.testscripts.test_experiment_struct(BlockStimuli)
%
%   Packs one block's worth of stimulus positions and correctness labels,
%   plus hardcoded display parameters, into the struct shape the old
%   (retired) single-trial test harness expects. Used only by
%   experiment.main.testscripts.run_single_trial_test.
%
%   Inputs
%     BlockStimuli - struct with fields .stimPosPix (trials x levels x 2) and
%                    .bTargetPresent (trials x levels).
%
%   Output
%     experimentStruct - struct with fields bFovea, stimulusPosX/Y,
%                        fixcrossPosX/Y, stimulusDuration (s), ppd (pixels
%                        per degree), correctResponse, nTrials, target
%                        (21x21 placeholder image), backgroundcolour,
%                        STIMULUSDELAY (s), nLevels.
%
%   See also experiment.main.testscripts.RUN_SINGLE_TRIAL_TEST.

    experimentStruct.bFovea = 1;

    experimentStruct.stimulusPosX = BlockStimuli.stimPosPix(:, :, 1);
    experimentStruct.stimulusPosY = BlockStimuli.stimPosPix(:, :, 2);

    experimentStruct.fixcrossPosX = BlockStimuli.stimPosPix(:, :, 1);
    experimentStruct.fixcrossPosY = BlockStimuli.stimPosPix(:, :, 2);

    experimentStruct.stimulusDuration = 3;
    experimentStruct.ppd = 120;
    experimentStruct.correctResponse = BlockStimuli.bTargetPresent(:, 1);
    experimentStruct.nTrials = size(BlockStimuli.stimPosPix(:, :, 1), 1);
    experimentStruct.target = zeros(21, 21);
    experimentStruct.backgroundcolour = 44.0609;
    experimentStruct.STIMULUSDELAY = 1;

    experimentStruct.nLevels = size(BlockStimuli.bTargetPresent, 2);
end
