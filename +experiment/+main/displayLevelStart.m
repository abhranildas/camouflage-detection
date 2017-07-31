function displayLevelStart(SessionSettings, blockNumber)
%% presenttargetonly
%   Used for the beginning of blocks. Presents that target, with text, at
%   the beginning of the block.


% Display the fixation and stimulus position from a random trial in the
% block

randTrial = randsample(SessionSettings.nTrials,1);
fixPosPixXY = SessionSettings.fixPosPix(randTrial, blockNumber, :);
stimPosPixXY = SessionSettings.stimPosPix(randTrial, blockNumber, :);

w       = SessionSettings.window;

%% Set up 
fixTarget = SessionSettings.fixationTarget; 
fixPosXY = fixPosPixXY;
fixationIntervalS = SessionSettings.fixationIntervalS;

fixTexture  = Screen('Maketexture', SessionSettings.window, fixTarget);
fixRect         = SetRect(0, 0, size(fixTarget,2), size(fixTarget,1));
fixDestination  = floor(CenterRectOnPointd(fixRect, fixPosPixXY(1), fixPosPixXY(2)));  

%% Draw fixTarget followed by blank if foveal experiment

Screen('TextSize', w, 25);
DrawFormattedText(w, 'Observe the target that you will be required to detect.\nPress any key when ready to continue the experiment.', ...
    'center',SessionSettings.pixelsPerDeg);

target = SessionSettings.targetSamples(:,:,blockNumber);
targetTexture = Screen('MakeTexture', SessionSettings.window, target);

targetRect         = SetRect(0, 0, size(target,2), size(target,1));
targetDestination  = floor(CenterRectOnPointd(targetRect, stimPosPixXY(1), stimPosPixXY(2))); 
 


if SessionSettings.bFovea % If foveal experiment, then draw stimulus after fixation cross.
    Screen('DrawTexture', SessionSettings.window, fixTexture, [], fixDestination);
    Screen('DrawTexture', SessionSettings.window, targetTexture, [], targetDestination);
else
    Screen('DrawTexture', SessionSettings.window, targetTexture, [], targetDestination);    
    Screen('DrawTexture', SessionSettings.window, fixTexture, [], fixDestination);
end
Screen('Flip',SessionSettings.window);
   
%WaitSecs(10); %Adapt to background luminance

KbWait();

WaitSecs(1);

