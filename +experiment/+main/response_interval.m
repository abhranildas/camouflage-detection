function [response, RT] = response_interval(SessionSettings, trialNumber, levelNumber)
% RESPONSE_INTERVAL  Wait for a left/right-arrow response within the response window.
%   [response, RT] = experiment.main.response_interval(SessionSettings, trialNumber, levelNumber)
%
%   Draws the fixation target and polls the keyboard for responseIntervalS
%   seconds. If neither arrow key is pressed in that window, returns without
%   a response (response == -1, RT == -1).
%
%   Inputs
%     SessionSettings - session settings struct; uses .responseIntervalS,
%                       .fixationTarget, .fixPosPix, .window.
%     trialNumber     - trial index into SessionSettings.fixPosPix.
%     levelNumber     - level index into SessionSettings.fixPosPix.
%
%   Output
%     response - 1 for right arrow, 0 for left arrow, -1 for timeout (no key
%                pressed within responseIntervalS). See B1.6 in the plan:
%                a timeout response of -1 corrupts SDT scoring downstream.
%     RT       - reaction time in seconds from stimulus onset to the key
%                press, or -1 for timeout.
%
%  R. Calen Walshe January 14, 2016.
%
%   See also experiment.main.STIMULUS_INTERVAL, experiment.main.GIVE_FEEDBACK.

    %% Set up
    responseIntervalS = SessionSettings.responseIntervalS;

    target = SessionSettings.fixationTarget;
    fixPosXY = SessionSettings.fixPosPix(trialNumber, levelNumber, :);

    targetTexture = Screen('Maketexture', SessionSettings.window, target);
    targetRect = SetRect(0, 0, size(target, 2), size(target, 1));
    targetDestination = floor(CenterRectOnPointd(targetRect, fixPosXY(1), fixPosXY(2)));

    %% Draw fixation target and wait for response

    Screen('DrawTexture', SessionSettings.window, targetTexture, [], targetDestination);
    Screen('Flip', SessionSettings.window, 0, 1);

    response = -1;
    RT = -1;

    t0 = GetSecs();
    t = GetSecs();
    while t < t0 + responseIntervalS
        [~, ~, keyCode] = KbCheck;
        if(keyCode(KbName('rightarrow')))
            response = 1;
            RT = t - t0;
        elseif(keyCode(KbName('leftarrow')))
            response = 0;
            RT = t - t0;
        end
        t = GetSecs();
    end

end
