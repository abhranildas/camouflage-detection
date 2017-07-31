function stimulusOnsetMs = stimulusInterval(SessionSettings, trialNumber, levelNumber)
%DRAWSTIMULUS Draw the detection stimulus.
%
% Description:
%   The stimulus is presented at the x and y coordinates provided.
%
% Example: 
%   stimulusOnsetMs = DRAWSTIMULUS(SessionSettings, x, y, stimulus);
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>

%% Set up 
 stimulusIntervalS = SessionSettings.stimulusIntervalS;

stimulus = SessionSettings.stimuli(:,:,trialNumber,levelNumber);

stimulusTexture     = Screen('Maketexture', SessionSettings.window, stimulus);
stimPosXY = SessionSettings.stimPosPix(trialNumber, levelNumber,:);

stimulusRect         = SetRect(0, 0, size(stimulus,2), size(stimulus,1));
stimulusDestination  = floor(CenterRectOnPointd(stimulusRect, stimPosXY(1), stimPosXY(2)));  

%% Display stimulus

Screen('DrawTexture', SessionSettings.window, stimulusTexture, [], stimulusDestination);

if ~SessionSettings.bFovea % If not foveal experiment. Make sure cross is always a layer above the stimulus.
    Eyelink('Message', 'STIMULUS_ON');
    
    fixTarget = SessionSettings.fixationTarget; 
    fixPosXY = SessionSettings.fixPosPix(trialNumber, levelNumber, :);

    fixTexture  = Screen('Maketexture', SessionSettings.window, fixTarget);
    targetRect         = SetRect(0, 0, size(fixTarget,2), size(fixTarget,1));
    targetDestination  = floor(CenterRectOnPointd(targetRect, fixPosXY(1), fixPosXY(2)));  

    Screen('DrawTexture', SessionSettings.window, fixTexture, [], targetDestination); 
    
    Eyelink('Message', 'FIX_CROSS_RECT %d %d %d %d', targetDestination(1), targetDestination(2),...
        targetDestination(3), targetDestination(4));
end
[~, StimulusOnsetTime] = Screen('Flip', SessionSettings.window, 0, 1);

WaitSecs(stimulusIntervalS); % Stimulus is on for stimulusIntervalS seconds.

Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma, stimulusDestination);

if ~SessionSettings.bFovea % If not foveal experiment. Make sure cross is always a layer above the stimulus.
    Screen('DrawTexture', SessionSettings.window, fixTexture, [], targetDestination);
    
end

[~, StimulusOnsetTime] = Screen('Flip', SessionSettings.window, 0, 1);

stimulusOnsetMs = StimulusOnsetTime;
