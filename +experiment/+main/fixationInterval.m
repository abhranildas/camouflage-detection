function fixationInterval(SessionSettings, trialNumber, levelNumber)
%PRESENTFIXATIONCROSS Draw a fixation cross at the specified position.
%
% Example: 
%   SINGLETRIALDETECTION(SessionSettings, fixationcrossPosX, fixationcrossPosY);
%   
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>

%% Set up 
fixTarget = SessionSettings.fixationTarget; 
fixPosXY = SessionSettings.fixPosPix(trialNumber, levelNumber, :);
fixationIntervalS = SessionSettings.fixationIntervalS;

fixTexture  = Screen('Maketexture', SessionSettings.window, fixTarget);
targetRect         = SetRect(0, 0, size(fixTarget,2), size(fixTarget,1));
targetDestination  = floor(CenterRectOnPointd(targetRect, fixPosXY(1), fixPosXY(2)));  

%% Draw fixTarget followed by blank if foveal experiment

Screen('DrawTexture', SessionSettings.window, fixTexture, [], targetDestination);
Screen('Flip', SessionSettings.window, 0, 1);
WaitSecs(fixationIntervalS);

if(SessionSettings.bFovea)
    blankIntervalS = SessionSettings.blankIntervalS; 
    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma, targetDestination);
    Screen('Flip', SessionSettings.window);
    WaitSecs(blankIntervalS);
end

if(~SessionSettings.bFovea)    
    if ~SessionSettings.el.dummyconnected
        experiment.main.checkFixationCross(SessionSettings, fixPosXY);
    end
end