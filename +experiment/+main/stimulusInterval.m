function stimulusOnsetMs = stimulusInterval(SessionSettings, trialNumber, levelNumber)
% STIMULUSINTERVAL  Draw the detection stimulus for stimulusIntervalS seconds.
%   stimulusOnsetMs = experiment.main.stimulusInterval(SessionSettings, trialNumber, levelNumber)
%
%   Draws the stimulus (with the fixation cross layered on top, for a
%   peripheral experiment) at the trial's position, holds it for
%   stimulusIntervalS seconds, then blanks it.
%
%   Inputs
%     SessionSettings - session settings struct; uses .stimulusIntervalS,
%                       .stimuli, .window, .stimPosPix, .bFovea,
%                       .fixationTarget, .fixPosPix, .bgPixValGamma.
%     trialNumber     - trial index into SessionSettings.stimuli/.stimPosPix.
%     levelNumber     - level index into SessionSettings.stimuli/.stimPosPix.
%
%   Output
%     stimulusOnsetMs - flip timestamp, in the units Screen('Flip') returns
%                       (seconds). Note: this is captured from the *second*
%                       Screen('Flip') call below (:52), which blanks the
%                       stimulus, not the first, which turns it on (:41) --
%                       see this tranche's findings log, a latent naming/
%                       value mismatch not fixed here.
%
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>
%
%   See also experiment.main.FIXATIONINTERVAL, experiment.main.RESPONSEINTERVAL.

    %% Set up
    stimulusIntervalS = SessionSettings.stimulusIntervalS;

    stimulus = SessionSettings.stimuli(:, :, trialNumber, levelNumber);

    stimulusTexture = Screen('Maketexture', SessionSettings.window, stimulus);
    stimPosXY = SessionSettings.stimPosPix(trialNumber, levelNumber, :);

    stimulusRect = SetRect(0, 0, size(stimulus, 2), size(stimulus, 1));
    stimulusDestination = floor(CenterRectOnPointd(stimulusRect, stimPosXY(1), stimPosXY(2)));

    %% Display stimulus

    Screen('DrawTexture', SessionSettings.window, stimulusTexture, [], stimulusDestination);

    % If not foveal experiment. Make sure cross is always a layer above the stimulus.
    if ~SessionSettings.bFovea
        Eyelink('Message', 'STIMULUS_ON');

        fixTarget = SessionSettings.fixationTarget;
        fixPosXY = SessionSettings.fixPosPix(trialNumber, levelNumber, :);

        fixTexture = Screen('Maketexture', SessionSettings.window, fixTarget);
        targetRect = SetRect(0, 0, size(fixTarget, 2), size(fixTarget, 1));
        targetDestination = floor(CenterRectOnPointd(targetRect, fixPosXY(1), fixPosXY(2)));

        Screen('DrawTexture', SessionSettings.window, fixTexture, [], targetDestination);

        Eyelink('Message', 'FIX_CROSS_RECT %d %d %d %d', ...
            targetDestination(1), targetDestination(2), targetDestination(3), targetDestination(4));
    end
    [~, StimulusOnsetTime] = Screen('Flip', SessionSettings.window, 0, 1);

    WaitSecs(stimulusIntervalS); % Stimulus is on for stimulusIntervalS seconds.

    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma, stimulusDestination);

    % If not foveal experiment. Make sure cross is always a layer above the stimulus.
    if ~SessionSettings.bFovea
        Screen('DrawTexture', SessionSettings.window, fixTexture, [], targetDestination);

    end

    [~, StimulusOnsetTime] = Screen('Flip', SessionSettings.window, 0, 1);

    stimulusOnsetMs = StimulusOnsetTime;

end
