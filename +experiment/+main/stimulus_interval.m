function stimulus_onset_ms = stimulus_interval(SessionSettings, trial_number, level_number)
% STIMULUS_INTERVAL  Draw the detection stimulus for stimulus_interval_s seconds.
%   stimulus_onset_ms = experiment.main.stimulus_interval(SessionSettings, trial_number, ...
%       level_number)
%
%   Draws the stimulus (with the fixation cross layered on top, for a
%   peripheral experiment) at the trial's position, holds it for
%   stimulus_interval_s seconds, then blanks it.
%
%   Inputs
%     SessionSettings - session settings struct; uses .stimulusIntervalS,
%                       .stimuli, .window, .stimPosPix, .bFovea,
%                       .fixationTarget, .fixPosPix, .bgPixValGamma.
%     trial_number    - trial index into SessionSettings.stimuli/.stimPosPix.
%     level_number    - level index into SessionSettings.stimuli/.stimPosPix.
%
%   Output
%     stimulus_onset_ms - flip timestamp, in the units Screen('Flip') returns
%                         (seconds). Note: this is captured from the *second*
%                         Screen('Flip') call below (:52), which blanks the
%                         stimulus, not the first, which turns it on (:41) --
%                         see this tranche's findings log, a latent naming/
%                         value mismatch not fixed here.
%
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>
%
%   See also experiment.main.FIXATION_INTERVAL, experiment.main.RESPONSE_INTERVAL.

    %% Set up
    stimulus_interval_s = SessionSettings.stimulusIntervalS;

    stimulus = SessionSettings.stimuli(:, :, trial_number, level_number);

    stimulus_texture = Screen('Maketexture', SessionSettings.window, stimulus);
    stim_pos_xy = SessionSettings.stimPosPix(trial_number, level_number, :);

    stimulus_rect = SetRect(0, 0, size(stimulus, 2), size(stimulus, 1));
    stimulus_destination = floor(CenterRectOnPointd(stimulus_rect, stim_pos_xy(1), stim_pos_xy(2)));

    %% Display stimulus

    Screen('DrawTexture', SessionSettings.window, stimulus_texture, [], stimulus_destination);

    % If not foveal experiment. Make sure cross is always a layer above the stimulus.
    if ~SessionSettings.bFovea
        Eyelink('Message', 'STIMULUS_ON');

        fix_target = SessionSettings.fixationTarget;
        fix_pos_xy = SessionSettings.fixPosPix(trial_number, level_number, :);

        fix_texture = Screen('Maketexture', SessionSettings.window, fix_target);
        target_rect = SetRect(0, 0, size(fix_target, 2), size(fix_target, 1));
        target_destination = floor(CenterRectOnPointd(target_rect, fix_pos_xy(1), fix_pos_xy(2)));

        Screen('DrawTexture', SessionSettings.window, fix_texture, [], target_destination);

        Eyelink('Message', 'FIX_CROSS_RECT %d %d %d %d', ...
            target_destination(1), target_destination(2), target_destination(3), ...
            target_destination(4));
    end
    [~, stimulus_onset_time] = Screen('Flip', SessionSettings.window, 0, 1);

    WaitSecs(stimulus_interval_s); % Stimulus is on for stimulus_interval_s seconds.

    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma, stimulus_destination);

    % If not foveal experiment. Make sure cross is always a layer above the stimulus.
    if ~SessionSettings.bFovea
        Screen('DrawTexture', SessionSettings.window, fix_texture, [], target_destination);

    end

    [~, stimulus_onset_time] = Screen('Flip', SessionSettings.window, 0, 1);

    stimulus_onset_ms = stimulus_onset_time;

end
