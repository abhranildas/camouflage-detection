function check_fixation_cross(SessionSettings, fixPosPix)
% CHECK_FIXATION_CROSS  Block until gaze lands on the fixation cross, or run drift correction.
%   experiment.main.check_fixation_cross(SessionSettings, fixPosPix)
%
%   Samples the EyeLink gaze position (or the mouse position in dummy mode).
%   If SessionSettings.checkFix is true, polls until a gaze sample falls
%   inside a fixed window around the fixation cross before letting the trial
%   proceed. If fixation is not found within maxTime seconds, runs a drift
%   correction and keeps polling; pressing 'c' instead runs a full tracker
%   calibration.
%
%   Inputs
%     SessionSettings - session settings struct; uses .el (EyeLink handle),
%                       .window, .checkFix, .fixationTarget, .bgPixValGamma.
%     fixPosPix       - [x, y] fixation cross position, in pixels.
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
        eventType = SessionSettings.el.ENDSACC;
    else % check for events
        evt = Eyelink('NewestFloatSample');

        t0 = GetSecs();
        maxTime = 5;
        fixRect = CenterRectOnPoint(SetRect(0, 0, 60, 60), fixPosPix(1), fixPosPix(2));

        if SessionSettings.checkFix
            while 1
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt = Eyelink('NewestFloatSample');
                end
                if IsInRect(evt.gx(1), evt.gy(1), fixRect)
                    break;
                elseif GetSecs() > t0 + maxTime
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

                    targetTexture = Screen('Maketexture', SessionSettings.window, target);
                    targetRect = SetRect(0, 0, size(target, 2), size(target, 1));
                    targetDestination = floor(CenterRectOnPointd(targetRect, ...
                        fixPosPix(1), fixPosPix(2)));

                    Screen('DrawTexture', SessionSettings.window, targetTexture, [], ...
                        targetDestination);
                    Screen('Flip', SessionSettings.window, 0, 1);

                    t0 = GetSecs();
                end

                [keyIsDown, secs, keyCode] = KbCheck;
                if keyCode(KbName('c'))
                    Eyelink('Command', 'set_idle_mode');
                    Eyelink('Command', 'clear_screen 0');
                    EyelinkDoTrackerSetup(SessionSettings.el, 'c');
                    Eyelink('Command', 'set_idle_mode');
                    Eyelink('StartRecording');
                    target = SessionSettings.fixationTarget;
                    %% Redraw fixation cross and see how we do.

                    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma);
                    targetTexture = Screen('Maketexture', SessionSettings.window, target);
                    targetRect = SetRect(0, 0, size(target, 2), size(target, 1));
                    targetDestination = floor(CenterRectOnPointd(targetRect, ...
                        fixPosPix(1), fixPosPix(2)));

                    Screen('DrawTexture', SessionSettings.window, targetTexture, [], ...
                        targetDestination);
                    Screen('Flip', SessionSettings.window, 0, 1);
                    t0 = GetSecs()
                    WaitSecs(0.1);
                end
                WaitSecs(.001);
            end
        end

    end

end
