function SessionData = run_camouflage_experiment(subject_str, exp_type_str, condition, ...
    session_number, level_number)
% RUN_CAMOUFLAGE_EXPERIMENT  Launch the camouflage detection experiment.
%   SessionData = experiment.main.run_camouflage_experiment(subject_str, exp_type_str)
%   SessionData = experiment.main.run_camouflage_experiment(subject_str, exp_type_str, ...
%       condition, session_number, level_number)
%
%   Delegates the session->level->trial loop, screen setup, and teardown to the
%   shared vislab harness (vislab.psychframework.run_experiment), wiring this repo's
%   interval functions (fixation_interval / stimulus_interval / response_interval /
%   give_feedback / display_level_start) and its EyeLink layer as hooks. The old
%   monolithic run_camouflage_experiment + runSession + runTrial were retired in
%   favour of this shared harness.
%
%   Run `setup` first (adds vislab). Requires Psychtoolbox (+ EyeLink for
%   peripheral / non-foveal runs).
%
%   Inputs
%     subject_str    - subject identifier string.
%     exp_type_str    - experiment type string (selects the settings/data path).
%     condition     - (optional) condition to resume; with session_number and
%                     level_number, resumes a specific session/level instead of
%                     the subject's current progress.
%     session_number - (optional) session index to resume.
%     level_number   - (optional) level index to resume.
%
%   Output
%     SessionData - struct returned by vislab.psychframework.run_experiment,
%                   recording what ran this session.
%
%   See also experiment.LOAD_CURRENT_SESSION, experiment.SAVE_CURRENT_LEVEL,
%   vislab.psychframework.RUN_EXPERIMENT.

    if nargin < 4
        ExpSettings = experiment.load_current_session(subject_str, exp_type_str);
    else
        ExpSettings = experiment.load_current_session(subject_str, exp_type_str, condition, ...
            session_number, level_number);
    end

    hooks.load_session = @load_session;
    hooks.level_start  = @(S, l)       experiment.main.display_level_start(S, l);
    hooks.fixation     = @(S, t, l)    experiment.main.fixation_interval(S, t, l);
    hooks.stimulus     = @(S, t, l)    experiment.main.stimulus_interval(S, t, l);
    hooks.response     = @(S, t, l)    experiment.main.response_interval(S, t, l);
    hooks.feedback     = @(S, r, t, l) experiment.main.give_feedback(S, r, t, l);
    hooks.save_level   = @(S, resp, l) experiment.save_current_level(S, resp, l);
    % EyeLink lifecycle (all no-ops for foveal runs, gated by S.bFovea)
    hooks.session_pre  = @session_pre;
    hooks.session_post = @session_post;
    hooks.level_pre    = @level_pre;
    hooks.level_post   = @level_post;
    hooks.trial_pre    = @trial_pre;
    hooks.trial_post   = @trial_post;

    SessionData = vislab.psychframework.run_experiment(ExpSettings, hooks);
end

% ------------------------------------------------------------------------------
function S = load_session(ExpSettings)
% Use the settings' injected stimulus loader, then define the level range to run.
    S = ExpSettings.loadSessionStimuli(ExpSettings);              % = @load_stimuli_camouflage
    S.level_list = ExpSettings.levelStartIndex : S.nLevels;
end

function S = session_pre(S)
    if ~S.bFovea
        Eyelink('Shutdown');
        S.el = experiment.main.configure_eyetracker(S);
    end
end

function session_post(S)
    if S.bFovea, return; end
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    try
        edf_file_path = ['eyetracking_files/' S.expTypeStr '/' S.targetTypeStr '/' ...
            num2str(S.currentBin) '/' S.subjectStr '/'];
        edf_file = [num2str(S.currentSession) '.edf'];
        fprintf('Receiving data file ''%s''\n', edf_file);
        status = Eyelink('ReceiveFile', edf_file, edf_file_path, 1);
        if status > 0, fprintf('ReceiveFile status %d\n', status); end
        if 2 == exist(edf_file, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edf_file, pwd);
        end
    catch
        fprintf('Problem receiving data file\n');
    end
    Eyelink('ShutDown');
    Screen('CloseAll');
end

function level_pre(S, ~)
    if ~S.bFovea
        Eyelink('Command', 'set_idle_mode');
        Eyelink('Command', 'clear_screen 0');
        EyelinkDoDriftCorrection(S.el);
        Eyelink('Command', 'set_idle_mode');
        Screen('FillRect', S.window, S.bgPixValGamma);
    end
end

function level_post(S, ~)
    if ~S.bFovea
        Eyelink('StopRecording');
    end
end

function trial_pre(S, trial, level)
    if S.bFovea, return; end
    Eyelink('StartRecording');
    WaitSecs(0.01);
    Eyelink('Message', 'TRIALID %d', trial);
    Eyelink('Message', '!V TRIAL_VAR index %s',   num2str(trial));
    Eyelink('Message', '!V TRIAL_VAR session %s', num2str(S.currentSession));
    Eyelink('Message', '!V TRIAL_VAR level %s',   num2str(level));
    Eyelink('Message', '!V TRIAL_VAR bin %s',     num2str(S.currentBin));
    Eyelink('Message', '!V TRIAL_VAR FIX_CROSS_X %s', num2str(S.fixPosPix(trial, level, 1)));
    Eyelink('Message', '!V TRIAL_VAR FIX_CROSS_Y %s', num2str(S.fixPosPix(trial, level, 2)));
    experiment.main.check_fixation_cross(S, S.fixPosPix(trial, level, :));
end

function trial_post(S, ~, ~, ~)
    if ~S.bFovea
        Eyelink('Message', 'TRIAL_RESULT 0');
    end
end
