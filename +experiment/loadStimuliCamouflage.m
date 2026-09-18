function SessionSettings = loadStimuliCamouflage(ExpSettings)
% LOADSTIMULICAMOUFLAGE  Prepare one session's stimuli and timings for display.
%   SessionSettings = experiment.loadStimuliCamouflage(ExpSettings)
%
%   Takes the settings for the session about to be run, clips and gamma-
%   compresses that session's stimuli to 8-bit pixel values, builds the
%   target-outline example image and the fixation cross, converts the
%   stimulus and fixation positions from degrees to pixels and the interval
%   durations from milliseconds to seconds, and returns everything the
%   Psychtoolbox runtime in experiment.main needs.
%
%   Inputs
%     ExpSettings - settings struct from experiment.loadCurrentSession; uses
%                   .stimuli, .seeds, .bTargetPresent, .stimPosDeg,
%                   .fixPosDeg (all indexed by .currentSession), .bgPixVal
%                   and .bgPixValGamma (8-bit pixel values), .monitor_distance
%                   (see below), .monitorSizePix, .stimulus_size and
%                   .target_radius (pixels), .luminance (normalised), the four
%                   *IntervalMs durations (milliseconds), .nTrials, .nLevels,
%                   and the run bookkeeping .levelStartIndex, .subjectStr,
%                   .expTypeStr, .currentBin, .currentSession.
%
%   Output
%     SessionSettings - struct for the runtime: .stimuli (gamma-compressed
%                       8-bit), .targetSamples, .fixationTarget, .stimPosPix
%                       and .fixPosPix (pixels), the four *IntervalS durations
%                       (seconds), .pixelsPerDeg, .bFovea, and the
%                       bookkeeping fields passed straight through.
%
%   ExpSettings.monitor_distance is misnamed: it holds 60 pixels per degree,
%   not a viewing distance, which is why it is read into pixelsPerDeg here
%   (B3.8). Renaming the field needs a migration, so it is deferred to S3.10.
%
%   bFovea is hardcoded to 1, so the whole peripheral / EyeLink half of the
%   runtime is unreachable from this entry point (see S3.17).
%
%   The gamma value 2.089 and bit depth 8 are hardcoded here and separately in
%   experiment.loadCurrentSession; they describe the same monitor.
%
%   See also experiment.LOADCURRENTSESSION, experiment.GAMMACORRECT,
%   experiment.main.RUNCAMOUFLAGEEXPERIMENT.

    %% Set up
    gammaValue = 2.089;

    bFovea = 1;

    levelStartIndex = ExpSettings.levelStartIndex;
    subjectStr = ExpSettings.subjectStr;
    expTypeStr = ExpSettings.expTypeStr;

    currentBin = ExpSettings.currentBin;
    currentSession = ExpSettings.currentSession;

    monitorSizePix = ExpSettings.monitorSizePix;

    seeds = ExpSettings.seeds(:, :, currentSession);
    stimuli = ExpSettings.stimuli(:, :, :, :, currentSession);
    % edgePowerBlockEdges = ExpSettings.edgePowerBlockEdges;
    % edgePowers = ExpSettings.edgePowers(:,:,currentSession);
    bTargetPresent = ExpSettings.bTargetPresent(:, :, currentSession);
    bgPixVal = ExpSettings.bgPixVal;
    bgPixValGamma = ExpSettings.bgPixValGamma;
    pixelsPerDeg = ExpSettings.monitor_distance;

    stimPosDeg = ExpSettings.stimPosDeg(:, :, currentSession, :);
    fixPosDeg = ExpSettings.fixPosDeg(:, :, currentSession, :);

    stimPosPix = lib.monitor_deg_to_pix(stimPosDeg, monitorSizePix, pixelsPerDeg);
    fixPosPix = lib.monitor_deg_to_pix(fixPosDeg, monitorSizePix, pixelsPerDeg);

    responseIntervalS = ExpSettings.responseIntervalMs/1000;
    stimulusIntervalS = ExpSettings.stimulusIntervalMs/1000;
    fixationIntervalS = ExpSettings.fixationIntervalMs/1000;
    blankIntervalS = ExpSettings.blankIntervalMs/1000;

    nTrials = ExpSettings.nTrials;
    nLevels = ExpSettings.nLevels;

    %% Gamma correct stimuli
    % and change to 8-bits
    bitDepthOut = 8;

    for iTrial = 1:nTrials
        for iLevel = 1:nLevels
            thisStimulus = stimuli(:, :, iTrial, iLevel);
            % clip:
            thisStimulus(thisStimulus > 1) = 1;
            thisStimulus(thisStimulus < 0) = 0;

            thisStimulus = experiment.gammaCorrect(thisStimulus, gammaValue, bitDepthOut);
            stimuli(:, :, iTrial, iLevel) = thisStimulus;
        end
    end

    %% Create target examples

    % target outline
    [~, target_outline] = lib.target_mask('bg_size', ExpSettings.stimulus_size, ...
        'target_radius', ExpSettings.target_radius);
    target_outline(:, [1 end]) = 1;
    target_outline([1 end], :) = 1;
    target_outline = double(~target_outline);
    target_outline(target_outline == 1) = ExpSettings.luminance;
    targetSamples = repmat(experiment.gammaCorrect(target_outline, gammaValue, bitDepthOut), ...
        [1 1 ExpSettings.nLevels]);

    % example camouflage target at each level
    % targetSamples=experiment.gammaCorrect(experiment.generate_camouflage_stimuli...
    %     (1,ExpSettings.edgeEnergies(1,:,1),size(ExpSettings.stimuli,1),...
    %     ExpSettings.condition(3),ExpSettings.condition(1),ExpSettings.condition(2),...
    %     ones(1,ExpSettings.nLevels)),gammaValue,bitDepthOut);

    %% Create the fixation target
    fixationSize = round(pixelsPerDeg.*0.1);
    fixationPixelVal = 0.5*bgPixVal;
    fixationTarget = fixationPixelVal.*ones(fixationSize, fixationSize);
    fixationTarget = experiment.gammaCorrect(fixationTarget, gammaValue, bitDepthOut);

    %% Save
    % Two further fields were passed through here and are commented out below,
    % alongside their reads near the top of the file:
    %     'edgePowerBlockEdges', edgePowerBlockEdges, 'edgePowers', edgePowers,...
    SessionSettings = struct('bTargetPresent', bTargetPresent, 'stimPosPix', stimPosPix, ...
        'fixPosPix', fixPosPix, 'bgPixValGamma', bgPixValGamma, 'targetSamples', targetSamples, ...
        'responseIntervalS', responseIntervalS, 'fixationIntervalS', fixationIntervalS, ...
        'stimulusIntervalS', stimulusIntervalS, 'blankIntervalS', blankIntervalS, ...
        'fixationTarget', fixationTarget, 'nTrials', nTrials, 'nLevels', nLevels, ...
        'pixelsPerDeg', pixelsPerDeg, 'bFovea', bFovea, ...
        'levelStartIndex', levelStartIndex, 'subjectStr', subjectStr, 'expTypeStr', expTypeStr, ...
        'currentBin', currentBin, 'currentSession', currentSession, ...
        'seeds', seeds, 'stimuli', stimuli, ...
        'stimPosDeg', stimPosDeg, 'fixPosDeg', fixPosDeg);
end
