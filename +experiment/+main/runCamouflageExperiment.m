function SessionData = runCamouflageExperiment(subjectStr, expTypeStr, condition, sessionNumber, levelNumber)
% RUNCAMOUFLAGEEXPERIMENT  Launch the camouflage detection experiment.
%   runCamouflageExperiment(subjectStr, expTypeStr [, condition, sessionNumber, levelNumber])
%
%   Delegates the session->level->trial loop, screen setup, and teardown to the
%   shared vision-commons harness (psychexp.run_experiment), wiring this repo's
%   interval functions (fixationInterval / stimulusInterval / responseInterval /
%   giveFeedback / displayLevelStart) and its EyeLink layer as hooks. The old
%   monolithic runCamouflageExperiment + runSession + runTrial were retired in
%   favour of this shared harness.
%
%   Run `setup` first (adds vision-commons). Requires Psychtoolbox (+ EyeLink for
%   peripheral / non-foveal runs).

    if nargin < 4
        ExpSettings = experiment.loadCurrentSession(subjectStr, expTypeStr);
    else
        ExpSettings = experiment.loadCurrentSession(subjectStr, expTypeStr, condition, sessionNumber, levelNumber);
    end

    hooks.load_session = @load_session;
    hooks.level_start  = @(S, l)       experiment.main.displayLevelStart(S, l);
    hooks.fixation     = @(S, t, l)    experiment.main.fixationInterval(S, t, l);
    hooks.stimulus     = @(S, t, l)    experiment.main.stimulusInterval(S, t, l);
    hooks.response     = @(S, t, l)    experiment.main.responseInterval(S, t, l);
    hooks.feedback     = @(S, r, t, l) experiment.main.giveFeedback(S, r, t, l);
    hooks.save_level   = @(S, resp, l) experiment.saveCurrentLevel(S, resp, l);
    % EyeLink lifecycle (all no-ops for foveal runs, gated by S.bFovea)
    hooks.session_pre  = @session_pre;
    hooks.session_post = @session_post;
    hooks.level_pre    = @level_pre;
    hooks.level_post   = @level_post;
    hooks.trial_pre    = @trial_pre;
    hooks.trial_post   = @trial_post;

    SessionData = psychexp.run_experiment(ExpSettings, hooks);
end

% ------------------------------------------------------------------------------
function S = load_session(ExpSettings)
% Use the settings' injected stimulus loader, then define the level range to run.
    S = ExpSettings.loadSessionStimuli(ExpSettings);              % = @loadStimuliCamouflage
    S.level_list = ExpSettings.levelStartIndex : S.nLevels;
end

function S = session_pre(S)
    if ~S.bFovea
        Eyelink('Shutdown');
        S.el = experiment.main.configureEyetracker(S);
    end
end

function session_post(S)
    if S.bFovea, return; end
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    try
        edfFilePath = ['eyetracking_files/' S.expTypeStr '/' S.targetTypeStr '/' ...
            num2str(S.currentBin) '/' S.subjectStr '/'];
        edfFile = [num2str(S.currentSession) '.edf'];
        fprintf('Receiving data file ''%s''\n', edfFile);
        status = Eyelink('ReceiveFile', edfFile, edfFilePath, 1);
        if status > 0, fprintf('ReceiveFile status %d\n', status); end
        if 2 == exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd);
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
    experiment.main.checkFixationCross(S, S.fixPosPix(trial, level, :));
end

function trial_post(S, ~, ~, ~)
    if ~S.bFovea
        Eyelink('Message', 'TRIAL_RESULT 0');
    end
end
