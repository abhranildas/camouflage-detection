function check_fixation_cross(SessionSettings, fix_pos_pix)
% CHECK_FIXATION_CROSS  Block until gaze lands on the fixation cross, or run drift correction.
%   experiment.main.check_fixation_cross(SessionSettings, fix_pos_pix)
%
%   Samples the EyeLink gaze position (or the mouse position in dummy mode).
%   If SessionSettings.checkFix is true, polls until a gaze sample falls
%   inside a fixed window around the fixation cross before letting the trial
%   proceed. If fixation is not found within max_time seconds, runs a drift
%   correction and keeps polling; pressing 'c' instead runs a full tracker
%   calibration.
%
%   Inputs
%     SessionSettings - session settings struct; uses .el (EyeLink handle),
%                       .window, .checkFix, .fixationTarget, .bgPixValGamma.
%     fix_pos_pix     - [x, y] fixation cross position, in pixels.
%
%   Output
%     none (side effect: blocks until fixation is confirmed, may trigger
%     drift correction or calibration).
%
%   See also experiment.main.FIXATION_INTERVAL, experiment.main.CONFIGURE_EYETRACKER.

    if SessionSettings.el.dummyconnected % in dummy mode use mouse coordinates
        [x, y, button] = GetMouse(SessionSettings.window);
        evt.type = SessionSettings.el.ENDSACC;
        evt.genx = x;
        evt.geny = y;
        event_type = SessionSettings.el.ENDSACC;
    else % check for events
        evt = Eyelink('NewestFloatSample');

        t0 = GetSecs();
        max_time = 5;
        fix_rect = CenterRectOnPoint(SetRect(0, 0, 60, 60), fix_pos_pix(1), fix_pos_pix(2));

        if SessionSettings.checkFix
            while 1
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt = Eyelink('NewestFloatSample');
                end
                if IsInRect(evt.gx(1), evt.gy(1), fix_rect)
                    break;
                elseif GetSecs() > t0 + max_time
                    Eyelink('Command', 'set_idle_mode');
                    Eyelink('Command', 'clear_screen 0');
                    EyelinkDoDriftCorrection(SessionSettings.el);
                    Eyelink('Command', 'set_idle_mode');
                    Eyelink('StartRecording');
                    % record a few samples before we actually start displaying
                    WaitSecs(0.1);

                    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma);

                    target = SessionSettings.fixationTarget;
                    %% Redraw fixation cross and see how we do.

                    target_texture = Screen('Maketexture', SessionSettings.window, target);
                    target_rect = SetRect(0, 0, size(target, 2), size(target, 1));
                    target_destination = floor(CenterRectOnPointd(target_rect, ...
                        fix_pos_pix(1), fix_pos_pix(2)));

                    Screen('DrawTexture', SessionSettings.window, target_texture, [], ...
                        target_destination);
                    Screen('Flip', SessionSettings.window, 0, 1);

                    t0 = GetSecs();
                end

                [~, ~, key_code] = KbCheck;
                if key_code(KbName('c'))
                    Eyelink('Command', 'set_idle_mode');
                    Eyelink('Command', 'clear_screen 0');
                    EyelinkDoTrackerSetup(SessionSettings.el, 'c');
                    Eyelink('Command', 'set_idle_mode');
                    Eyelink('StartRecording');
                    target = SessionSettings.fixationTarget;
                    %% Redraw fixation cross and see how we do.

                    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma);
                    target_texture = Screen('Maketexture', SessionSettings.window, target);
                    target_rect = SetRect(0, 0, size(target, 2), size(target, 1));
                    target_destination = floor(CenterRectOnPointd(target_rect, ...
                        fix_pos_pix(1), fix_pos_pix(2)));

                    Screen('DrawTexture', SessionSettings.window, target_texture, [], ...
                        target_destination);
                    Screen('Flip', SessionSettings.window, 0, 1);
                    t0 = GetSecs();
                    WaitSecs(0.1);
                end
                WaitSecs(.001);
            end
        end

    end

end
