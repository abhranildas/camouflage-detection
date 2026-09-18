function fixation_interval(SessionSettings, trial_number, level_number)
% FIXATION_INTERVAL  Draw the fixation cross, and (peripheral runs) confirm gaze on it.
%   experiment.main.fixation_interval(SessionSettings, trial_number, level_number)
%
%   Draws the fixation cross and holds it for fixation_interval_s seconds. In a
%   foveal experiment (bFovea true), follows it with a blank screen for
%   blank_interval_s seconds. In a peripheral experiment (bFovea false), instead
%   calls experiment.main.check_fixation_cross to block until gaze is confirmed
%   on the cross (skipped in dummy-tracker mode).
%
%   Inputs
%     SessionSettings - session settings struct; uses .fixationTarget,
%                       .fixPosPix, .fixationIntervalS, .window, .bFovea,
%                       .blankIntervalS, .bgPixValGamma, .el.
%     trial_number    - trial index into SessionSettings.fixPosPix.
%     level_number    - level index into SessionSettings.fixPosPix.
%
%   Output
%     none (side effect: draws to screen, may block on gaze).
%
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>
%
%   See also experiment.main.CHECK_FIXATION_CROSS, experiment.main.STIMULUS_INTERVAL.

    %% Set up
    fix_target = SessionSettings.fixationTarget;
    fix_pos_xy = SessionSettings.fixPosPix(trial_number, level_number, :);
    fixation_interval_s = SessionSettings.fixationIntervalS;

    fix_texture = Screen('Maketexture', SessionSettings.window, fix_target);
    target_rect = SetRect(0, 0, size(fix_target, 2), size(fix_target, 1));
    target_destination = floor(CenterRectOnPointd(target_rect, fix_pos_xy(1), fix_pos_xy(2)));

    %% Draw fix_target followed by blank if foveal experiment

    Screen('DrawTexture', SessionSettings.window, fix_texture, [], target_destination);
    Screen('Flip', SessionSettings.window, 0, 1);
    WaitSecs(fixation_interval_s);

    if(SessionSettings.bFovea)
        blank_interval_s = SessionSettings.blankIntervalS;
        Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma, ...
            target_destination);
        Screen('Flip', SessionSettings.window);
        WaitSecs(blank_interval_s);
    end

    if(~SessionSettings.bFovea)
        if ~SessionSettings.el.dummyconnected
            experiment.main.check_fixation_cross(SessionSettings, fix_pos_xy);
        end
    end

end
