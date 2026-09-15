function fixationInterval(SessionSettings, trialNumber, levelNumber)
% FIXATIONINTERVAL  Draw the fixation cross, and (peripheral runs) confirm gaze on it.
%   experiment.main.fixationInterval(SessionSettings, trialNumber, levelNumber)
%
%   Draws the fixation cross and holds it for fixationIntervalS seconds. In a
%   foveal experiment (bFovea true), follows it with a blank screen for
%   blankIntervalS seconds. In a peripheral experiment (bFovea false), instead
%   calls experiment.main.checkFixationCross to block until gaze is confirmed
%   on the cross (skipped in dummy-tracker mode).
%
%   Inputs
%     SessionSettings - session settings struct; uses .fixationTarget,
%                       .fixPosPix, .fixationIntervalS, .window, .bFovea,
%                       .blankIntervalS, .bgPixValGamma, .el.
%     trialNumber     - trial index into SessionSettings.fixPosPix.
%     levelNumber     - level index into SessionSettings.fixPosPix.
%
%   Output
%     none (side effect: draws to screen, may block on gaze).
%
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>
%
%   See also experiment.main.CHECKFIXATIONCROSS, experiment.main.STIMULUSINTERVAL.

    %% Set up
    fixTarget = SessionSettings.fixationTarget;
    fixPosXY = SessionSettings.fixPosPix(trialNumber, levelNumber, :);
    fixationIntervalS = SessionSettings.fixationIntervalS;

    fixTexture = Screen('Maketexture', SessionSettings.window, fixTarget);
    targetRect = SetRect(0, 0, size(fixTarget, 2), size(fixTarget, 1));
    targetDestination = floor(CenterRectOnPointd(targetRect, fixPosXY(1), fixPosXY(2)));

    %% Draw fixTarget followed by blank if foveal experiment

    Screen('DrawTexture', SessionSettings.window, fixTexture, [], targetDestination);
    Screen('Flip', SessionSettings.window, 0, 1);
    WaitSecs(fixationIntervalS);

    if(SessionSettings.bFovea)
        blankIntervalS = SessionSettings.blankIntervalS;
        Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma, ...
            targetDestination);
        Screen('Flip', SessionSettings.window);
        WaitSecs(blankIntervalS);
    end

    if(~SessionSettings.bFovea)
        if ~SessionSettings.el.dummyconnected
            experiment.main.checkFixationCross(SessionSettings, fixPosXY);
        end
    end

end
