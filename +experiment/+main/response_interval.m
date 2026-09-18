function [response, reaction_time] = response_interval(SessionSettings, trial_number, level_number)
% RESPONSE_INTERVAL  Wait for a left/right-arrow response within the response window.
%   [response, reaction_time] = experiment.main.response_interval(SessionSettings, ...
%       trial_number, level_number)
%
%   Draws the fixation target and polls the keyboard for response_interval_s
%   seconds. If neither arrow key is pressed in that window, returns without
%   a response (response == -1, reaction_time == -1).
%
%   Inputs
%     SessionSettings - session settings struct; uses .responseIntervalS,
%                       .fixationTarget, .fixPosPix, .window.
%     trial_number    - trial index into SessionSettings.fixPosPix.
%     level_number    - level index into SessionSettings.fixPosPix.
%
%   Output
%     response      - 1 for right arrow, 0 for left arrow, -1 for timeout (no key
%                     pressed within response_interval_s). See B1.6 in the plan:
%                     a timeout response of -1 corrupts SDT scoring downstream.
%     reaction_time - reaction time in seconds from stimulus onset to the key
%                     press, or -1 for timeout.
%
%  R. Calen Walshe January 14, 2016.
%
%   See also experiment.main.STIMULUS_INTERVAL, experiment.main.GIVE_FEEDBACK.

    %% Set up
    response_interval_s = SessionSettings.responseIntervalS;

    target = SessionSettings.fixationTarget;
    fix_pos_xy = SessionSettings.fixPosPix(trial_number, level_number, :);

    target_texture = Screen('Maketexture', SessionSettings.window, target);
    target_rect = SetRect(0, 0, size(target, 2), size(target, 1));
    target_destination = floor(CenterRectOnPointd(target_rect, fix_pos_xy(1), fix_pos_xy(2)));

    %% Draw fixation target and wait for response

    Screen('DrawTexture', SessionSettings.window, target_texture, [], target_destination);
    Screen('Flip', SessionSettings.window, 0, 1);

    response = -1;
    reaction_time = -1;

    t0 = GetSecs();
    t = GetSecs();
    while t < t0 + response_interval_s
        [~, ~, key_code] = KbCheck;
        if(key_code(KbName('rightarrow')))
            response = 1;
            reaction_time = t - t0;
        elseif(key_code(KbName('leftarrow')))
            response = 0;
            reaction_time = t - t0;
        end
        t = GetSecs();
    end

end
