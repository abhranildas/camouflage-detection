function [response, RT] = responseInterval(SessionSettings, trialNumber, levelNumber)
%% waitforresponse
%
%   Waits for a response to be made. If the response is made during the
%   response interval the response value is returned. Otherwise, the
%   function returns without any response.
%
%  R. Calen Walshe January 14, 2016.

%% Set up
responseIntervalS = SessionSettings.responseIntervalS;

target   = SessionSettings.fixationTarget; 
fixPosXY = SessionSettings.fixPosPix(trialNumber, levelNumber, :);

targetTexture      = Screen('Maketexture', SessionSettings.window, target);
targetRect         = SetRect(0, 0, size(target,2), size(target,1));
targetDestination  = floor(CenterRectOnPointd(targetRect, fixPosXY(1), fixPosXY(2)));  

%% Draw fixation target and wait for response

Screen('DrawTexture', SessionSettings.window, targetTexture, [], targetDestination);
Screen('Flip', SessionSettings.window, 0, 1);

response = -1;
RT = -1;

t0 = GetSecs();
t = GetSecs();
while t < t0 + responseIntervalS
    [~,~, keyCode] = KbCheck;
    if(keyCode(KbName('rightarrow')))
        response = 1;
        RT = t - t0;
    elseif(keyCode(KbName('leftarrow')))
        response = 0;
        RT = t - t0;
    end
    t = GetSecs();
end


