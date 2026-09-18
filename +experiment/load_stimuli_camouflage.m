function SessionSettings = load_stimuli_camouflage(ExpSettings)
% LOAD_STIMULI_CAMOUFLAGE  Prepare one session's stimuli and timings for display.
%   SessionSettings = experiment.load_stimuli_camouflage(ExpSettings)
%
%   Takes the settings for the session about to be run, clips and gamma-
%   compresses that session's stimuli to 8-bit pixel values, builds the
%   target-outline example image and the fixation cross, converts the
%   stimulus and fixation positions from degrees to pixels and the interval
%   durations from milliseconds to seconds, and returns everything the
%   Psychtoolbox runtime in experiment.main needs.
%
%   Inputs
%     ExpSettings - settings struct from experiment.load_current_session; uses
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
%   not a viewing distance, which is why it is read into pixels_per_deg here
%   (B3.8). Renaming the field needs a migration, so it is deferred to S3.10.
%
%   b_fovea is hardcoded to 1, so the whole peripheral / EyeLink half of the
%   runtime is unreachable from this entry point (see S3.17).
%
%   The gamma value 2.089 and bit depth 8 are hardcoded here and separately in
%   experiment.load_current_session; they describe the same monitor.
%
%   See also experiment.LOAD_CURRENT_SESSION, experiment.GAMMA_CORRECT,
%   experiment.main.RUN_CAMOUFLAGE_EXPERIMENT.

    %% Set up
    gamma_value = 2.089;

    b_fovea = 1;

    level_start_index = ExpSettings.levelStartIndex;
    subject_str = ExpSettings.subjectStr;
    exp_type_str = ExpSettings.expTypeStr;

    current_bin = ExpSettings.currentBin;
    current_session = ExpSettings.currentSession;

    monitor_size_pix = ExpSettings.monitorSizePix;

    seeds = ExpSettings.seeds(:, :, current_session);
    stimuli = ExpSettings.stimuli(:, :, :, :, current_session);
    % edgePowerBlockEdges = ExpSettings.edgePowerBlockEdges;
    % edgePowers = ExpSettings.edgePowers(:,:,current_session);
    b_target_present = ExpSettings.bTargetPresent(:, :, current_session);
    bg_pix_val = ExpSettings.bgPixVal;
    bg_pix_val_gamma = ExpSettings.bgPixValGamma;
    pixels_per_deg = ExpSettings.monitor_distance;

    stim_pos_deg = ExpSettings.stimPosDeg(:, :, current_session, :);
    fix_pos_deg = ExpSettings.fixPosDeg(:, :, current_session, :);

    stim_pos_pix = lib.monitor_deg_to_pix(stim_pos_deg, monitor_size_pix, pixels_per_deg);
    fix_pos_pix = lib.monitor_deg_to_pix(fix_pos_deg, monitor_size_pix, pixels_per_deg);

    response_interval_s = ExpSettings.responseIntervalMs/1000;
    stimulus_interval_s = ExpSettings.stimulusIntervalMs/1000;
    fixation_interval_s = ExpSettings.fixationIntervalMs/1000;
    blank_interval_s = ExpSettings.blankIntervalMs/1000;

    n_trials = ExpSettings.nTrials;
    n_levels = ExpSettings.nLevels;

    %% Gamma correct stimuli
    % and change to 8-bits
    bit_depth_out = 8;

    for i_trial = 1:n_trials
        for i_level = 1:n_levels
            this_stimulus = stimuli(:, :, i_trial, i_level);
            % clip:
            this_stimulus(this_stimulus > 1) = 1;
            this_stimulus(this_stimulus < 0) = 0;

            this_stimulus = experiment.gamma_correct(this_stimulus, gamma_value, bit_depth_out);
            stimuli(:, :, i_trial, i_level) = this_stimulus;
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
    target_samples = repmat( ...
        experiment.gamma_correct(target_outline, gamma_value, bit_depth_out), ...
        [1 1 ExpSettings.nLevels]);

    % example camouflage target at each level
    % target_samples=experiment.gamma_correct(experiment.generate_camouflage_stimuli...
    %     (1,ExpSettings.edgeEnergies(1,:,1),size(ExpSettings.stimuli,1),...
    %     ExpSettings.condition(3),ExpSettings.condition(1),ExpSettings.condition(2),...
    %     ones(1,ExpSettings.nLevels)),gamma_value,bit_depth_out);

    %% Create the fixation target
    fixation_size = round(pixels_per_deg.*0.1);
    fixation_pixel_val = 0.5*bg_pix_val;
    fixation_target = fixation_pixel_val.*ones(fixation_size, fixation_size);
    fixation_target = experiment.gamma_correct(fixation_target, gamma_value, bit_depth_out);

    %% Save
    % Two further fields were passed through here and are commented out below,
    % alongside their reads near the top of the file:
    %     'edgePowerBlockEdges', edgePowerBlockEdges, 'edgePowers', edgePowers,...
    SessionSettings = struct('bTargetPresent', b_target_present, 'stimPosPix', stim_pos_pix, ...
        'fixPosPix', fix_pos_pix, 'bgPixValGamma', bg_pix_val_gamma, ...
        'targetSamples', target_samples, ...
        'responseIntervalS', response_interval_s, 'fixationIntervalS', fixation_interval_s, ...
        'stimulusIntervalS', stimulus_interval_s, 'blankIntervalS', blank_interval_s, ...
        'fixationTarget', fixation_target, 'nTrials', n_trials, 'nLevels', n_levels, ...
        'pixelsPerDeg', pixels_per_deg, 'bFovea', b_fovea, ...
        'levelStartIndex', level_start_index, 'subjectStr', subject_str, ...
        'expTypeStr', exp_type_str, ...
        'currentBin', current_bin, 'currentSession', current_session, ...
        'seeds', seeds, 'stimuli', stimuli, ...
        'stimPosDeg', stim_pos_deg, 'fixPosDeg', fix_pos_deg);
end
