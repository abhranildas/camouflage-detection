function experiment_struct = test_experiment_struct(BlockStimuli)
% TEST_EXPERIMENT_STRUCT  Build a minimal experiment_struct for ad-hoc Psychtoolbox testing.
%   experiment_struct = experiment.main.testscripts.test_experiment_struct(BlockStimuli)
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
%     experiment_struct - struct with fields bFovea, stimulusPosX/Y,
%                        fixcrossPosX/Y, stimulusDuration (s), ppd (pixels
%                        per degree), correctResponse, nTrials, target
%                        (21x21 placeholder image), backgroundcolour,
%                        STIMULUSDELAY (s), nLevels.
%
%   See also experiment.main.testscripts.RUN_SINGLE_TRIAL_TEST.

    experiment_struct.bFovea = 1;

    experiment_struct.stimulusPosX = BlockStimuli.stimPosPix(:, :, 1);
    experiment_struct.stimulusPosY = BlockStimuli.stimPosPix(:, :, 2);

    experiment_struct.fixcrossPosX = BlockStimuli.stimPosPix(:, :, 1);
    experiment_struct.fixcrossPosY = BlockStimuli.stimPosPix(:, :, 2);

    experiment_struct.stimulusDuration = 3;
    experiment_struct.ppd = 120;
    experiment_struct.correctResponse = BlockStimuli.bTargetPresent(:, 1);
    experiment_struct.nTrials = size(BlockStimuli.stimPosPix(:, :, 1), 1);
    experiment_struct.target = zeros(21, 21);
    experiment_struct.backgroundcolour = 44.0609;
    experiment_struct.STIMULUSDELAY = 1;

    experiment_struct.nLevels = size(BlockStimuli.bTargetPresent, 2);
end
