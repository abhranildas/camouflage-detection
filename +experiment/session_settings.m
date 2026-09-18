function SessionSettings = session_settings(variant, exp_type, luminance, contrast, ...
    stimulus_size, target_radius, monitor_distance, options)
% SESSION_SETTINGS  Build the complete settings and stimulus set for one experiment.
%   SessionSettings = experiment.session_settings(variant, exp_type, luminance, ...
%       contrast, stimulus_size, target_radius, monitor_distance, ...)
%
%   Fixes the trial structure and display timings, synthesises the stimulus set
%   with the generator belonging to the chosen variant, and returns the struct
%   that gets saved as ExpSettings — the only record of how an experiment was
%   configured.
%
%   The switch below is the whole of the variant difference: what a level is,
%   how many levels and sessions there are, which generator makes the stimuli,
%   and the handful of struct fields that describe the level variable. The
%   trial structure, the display settings, the timings and the other twenty
%   struct fields are shared.
%
%   Inputs
%     variant          - 'edge_power', 'all', 'diff_bg', 'shape_exponent' or
%                        'texture_exponent'; see experiment.set_up_experiment.
%     exp_type         - experiment name, also the exp_files/ subdirectory.
%     luminance        - mean luminance, normalised, in [0, 1].
%     contrast         - RMS contrast, dimensionless fraction.
%     stimulus_size    - stimulus side, in pixels.
%     target_radius    - target radius, in pixels.
%     monitor_distance - misnamed: pixels per degree, not a distance (B3.8).
%
%   Name-value inputs, each used by the variants that need it
%     levels             - the level variable, one entry per level: an
%                          n_levels x 2 array of [lower, upper] edge-power
%                          limits for 'edge_power' (dimensionless edge power),
%                          or a vector of 1/f exponents for 'diff_bg'
%                          (background), 'shape_exponent' (target boundary) and
%                          'texture_exponent' (texture), all dimensionless.
%                          Unused by 'all', whose levels come from the texture
%                          list on disk.
%     texture_params     - texture struct for lib.stimulus: .type, and
%                          .stats/.Niter for a Portilla-Simoncelli texture.
%                          Unused by 'all', which records a per-trial texture
%                          instead.
%     target_exponent    - 'diff_bg' only: the target texture's 1/f exponent,
%                          dimensionless, held fixed while the background's
%                          varies.
%     transform_exp_name - 'edge_power' only: name of an experiment whose
%                          stimuli to rescale to this luminance and contrast
%                          instead of synthesising new ones, or '' for new.
%
%   Output
%     SessionSettings - the ExpSettings struct: the inputs above, the trial
%                       structure (.nLevels, .nTrials = 30, .nSessions,
%                       .pTarget), the stimuli and their seeds, .edgePowers and
%                       .pClipped, the display settings (.monitorMaxPix and
%                       .bgPixVal in 8-bit pixel values, monitor brightness and
%                       contrast in percent) and the four interval durations in
%                       milliseconds.
%
%   Every field name here is serialised into exp_settings.mat and read back by
%   the runtime and the analysis, so none may be renamed without a migration
%   (zone 3, S3.10). One of them is already misspelled and frozen that way:
%   .moniter_brightness. The field order differs between variants, and is
%   preserved exactly as each variant wrote it, which is why the struct is
%   assembled from three name-value lists rather than written out five times.
%
%   .nTrials is 30 and .nSessions 4, so a full experiment is 30 x n_levels x 4
%   trials per subject — except 'shape_exponent', which runs 16 sessions.
%
%   Two variant-specific quirks are deliberately kept, because they are what
%   two recorded bugs consist of. 'texture_exponent' alone stores the level
%   count and the seeds under .nBlocks and .stimuliSeed, while every consumer
%   of the settings file reads .nLevels and .seeds (B2.6). And the level
%   variable of both 'shape_exponent' and 'texture_exponent' goes into a field
%   named .alphas, which therefore means a boundary shape exponent in one and a
%   texture exponent in the other; the locals are named apart (0.1.7 decision
%   C) but the field is frozen on disk.
%
%   The guard on transform_exp_name carries a stray transpose, strcmp(x', ''),
%   which happens to behave the same way for a character row vector (B3.7).
%
%   See also experiment.SET_UP_EXPERIMENT, experiment.GENERATE_CAMOUFLAGE_STIMULI,
%   experiment.TRANSFORM_CAMOUFLAGE_STIMULI, experiment.LOAD_STIMULI_CAMOUFLAGE.

    arguments
        variant (1, :) char {mustBeMember(variant, {'edge_power', 'all', 'diff_bg', ...
            'shape_exponent', 'texture_exponent'})}
        exp_type char
        luminance (1, 1) double
        contrast (1, 1) double
        stimulus_size (1, 1) double
        target_radius (1, 1) double
        monitor_distance (1, 1) double
        options.levels double = []
        options.texture_params struct = struct('type', 'pink_noise')
        options.target_exponent double = []
        % Unconstrained in size on purpose: a (1, :) validator would widen the
        % default '' from 0x0 to 1x0, and the strcmp guard below would then
        % never fire.
        options.transform_exp_name char = ''
    end

    stimulus_interval_ms = 200;
    response_interval_ms = 1000;
    fixation_interval_ms = 100;
    blank_interval_ms = 0;

    monitor_max_pix = 255;
    bg_pix_val = luminance*255;
    monitor_brightness = 50;
    monitor_contrast = 100;

    load_session_stimuli = @experiment.load_stimuli_camouflage;
    p_target = .5;
    n_trials = 30;
    n_sessions = 4;

    % What a level is, and how its stimuli are made. Each case leaves n_levels,
    % b_target_present and three name-value lists: the fields that lead the
    % settings struct, the level-count fields, and the generator's outputs.
    switch variant
        case 'edge_power'
            n_levels = size(options.levels, 1);
            % edge_power_block_centers=movmean(options.levels,2,'Endpoints','discard');
            edge_power_block_centers = mean(options.levels, 2);
            if strcmp(options.transform_exp_name', '')
                % generate new stimuli
                b_target_present = logical(experiment.generate_target_present_matrix( ...
                    n_trials, n_levels, n_sessions, p_target));
                [stimuli, seeds, stim_edge_powers, p_clipped] = ...
                    experiment.generate_camouflage_stimuli(options.texture_params, exp_type, ...
                    options.levels, n_trials, n_sessions, stimulus_size, target_radius, ...
                    luminance, contrast, b_target_present);
            else
                % transform stimuli of existing experiment
                [stimuli, seeds, stim_edge_powers, p_clipped, b_target_present] = ...
                    experiment.transform_camouflage_stimuli(options.transform_exp_name, ...
                    luminance, contrast);
            end
            head_fields = {'exp_type', exp_type, 'texture_params', options.texture_params};
            count_fields = {'nLevels', n_levels};
            result_fields = {'edgePowerBlockEdges', options.levels, ...
                'edgePowerBlockCenters', edge_power_block_centers, ...
                'edgePowers', stim_edge_powers, 'seeds', seeds, 'stimuli', stimuli, ...
                'pClipped', p_clipped};

        case 'all'
            % load texture list
            cfg = config();
            load(fullfile(cfg.paths.exp_files, exp_type, 'texture_list.mat'));
            n_tex = length(texture_list);
            n_trials_eachtx = 40;
            n_levels = 10;
            % The trial count is derived, not chosen: n_tex textures x 40
            % trials each, redistributed over 10 levels and 4 sessions.
            n_trials = n_tex*n_trials_eachtx/(n_levels*n_sessions);
            % generate stimuli. This generator makes its own exactly-balanced
            % target-present assignment, so none is drawn here.
            [stimuli, textures, seeds, b_target_present, p_clipped] = ...
                experiment.generate_camouflage_stimuli_all(texture_list, n_tex, ...
                n_trials_eachtx, n_trials, n_levels, n_sessions, stimulus_size, ...
                target_radius, luminance, contrast);
            head_fields = {'exp_type', exp_type, 'textures', textures};
            count_fields = {'nTrials_eachtx', n_trials_eachtx, 'nLevels', n_levels, ...
                'nTex', n_tex};
            result_fields = {'seeds', seeds, 'stimuli', stimuli, 'pClipped', p_clipped};

        case 'diff_bg'
            n_levels = length(options.levels);
            % generate stimuli
            b_target_present = logical(experiment.generate_target_present_matrix( ...
                n_trials, n_levels, n_sessions, p_target));
            [stimuli, seeds, stim_edge_powers, p_clipped] = ...
                experiment.generate_camouflage_stimuli_diff_bg(options.target_exponent, ...
                options.levels, n_trials, n_sessions, stimulus_size, target_radius, ...
                luminance, contrast, b_target_present);
            head_fields = {'exp_type', exp_type, 'texture_params', options.texture_params, ...
                'target_exponent', options.target_exponent, 'bg_exponents', options.levels};
            count_fields = {'nLevels', n_levels};
            result_fields = {'edgePowers', stim_edge_powers, 'seeds', seeds, ...
                'stimuli', stimuli, 'pClipped', p_clipped};

        case 'shape_exponent'
            n_levels = length(options.levels);
            n_sessions = 16;
            % generate stimuli
            b_target_present = logical(experiment.generate_target_present_matrix( ...
                n_trials, n_levels, n_sessions, p_target));
            [stimuli, seeds, stim_edge_powers, p_clipped] = ...
                experiment.generate_camouflage_stimuli_shape_exponent(options.levels, ...
                options.texture_params, n_trials, n_sessions, stimulus_size, target_radius, ...
                luminance, contrast, b_target_present);
            head_fields = {'exp_type', exp_type, 'texture_params', options.texture_params, ...
                'alphas', options.levels};
            count_fields = {'nLevels', n_levels};
            result_fields = {'edgePowers', stim_edge_powers, 'seeds', seeds, ...
                'stimuli', stimuli, 'pClipped', p_clipped};

        case 'texture_exponent'
            % This variant alone calls the level count n_blocks and the seeds
            % stimuli_seed, and saves them under .nBlocks and .stimuliSeed
            % (B2.6). n_levels below only sizes the shared layout arrays.
            n_blocks = length(options.levels);
            n_levels = n_blocks;
            % generate stimuli
            b_target_present = logical(experiment.generate_target_present_matrix( ...
                n_trials, n_blocks, n_sessions, p_target));
            [stimuli, stimuli_seed, stim_edge_powers, p_clipped] = ...
                experiment.generate_camouflage_stimuli_texture_exponent(options.levels, ...
                n_trials, n_sessions, stimulus_size, target_radius, luminance, contrast, ...
                b_target_present);
            head_fields = {'exp_type', exp_type, 'texture_params', options.texture_params, ...
                'alphas', options.levels};
            count_fields = {'nBlocks', n_blocks};
            result_fields = {'edgePowers', stim_edge_powers, 'stimuliSeed', stimuli_seed, ...
                'stimuli', stimuli, 'pClipped', p_clipped};
    end

    stim_pos_deg = zeros(n_trials, n_levels, n_sessions, 2);
    fix_pos_deg = zeros(n_trials, n_levels, n_sessions, 2);

    settings_fields = [head_fields, ...
        {'luminance', luminance, ...
        'contrast', contrast, ...
        'target_radius', target_radius, ...
        'stimulus_size', stimulus_size, ...
        'monitor_distance', monitor_distance}, ...
        count_fields, ...
        {'nTrials', n_trials, ...
        'nSessions', n_sessions, ...
        'pTarget', p_target, ...
        'loadSessionStimuli', load_session_stimuli, ...
        'bTargetPresent', b_target_present}, ...
        result_fields, ...
        {'moniter_brightness', monitor_brightness, ...
        'monitor_contrast', monitor_contrast, ...
        'stimPosDeg', stim_pos_deg, ...
        'fixPosDeg', fix_pos_deg, ...
        'monitorMaxPix', monitor_max_pix, ...
        'bgPixVal', bg_pix_val, ...
        'stimulusIntervalMs', stimulus_interval_ms, ...
        'responseIntervalMs', response_interval_ms, ...
        'fixationIntervalMs', fixation_interval_ms, ...
        'blankIntervalMs', blank_interval_ms}];
    SessionSettings = struct(settings_fields{:});
end
