function give_feedback(SessionSettings, response, trialNumber, levelNumber)
% GIVE_FEEDBACK  Play an auditory feedback tone for a trial's response.
%   experiment.main.give_feedback(SessionSettings, response, trialNumber, levelNumber)
%
%   Beeps at errorFreqHz for a timeout response (response == -1), at
%   correctFreqHz if the response matches SessionSettings.bTargetPresent for
%   this trial/level, and at incorrectFreqHz otherwise.
%
%   Inputs
%     SessionSettings - session settings struct; uses .bTargetPresent.
%     response        - the subject's response for this trial (-1 = timeout).
%     trialNumber     - trial index into SessionSettings.bTargetPresent.
%     levelNumber     - level index into SessionSettings.bTargetPresent.
%
%   Output
%     none (side effect: plays a tone).
%
%   See also experiment.main.RESPONSE_INTERVAL.

    %% Sound parameters
    sampleFreqHz = 22050;
    toneDurationS = 0.05;
    numSamples = sampleFreqHz * toneDurationS;
    soundData = (1:numSamples) / sampleFreqHz;

    correctFreqHz = 900;
    incorrectFreqHz = 300;
    errorFreqHz = 1500;

    correctTone = sin(2*pi*correctFreqHz*soundData);
    incorrectTone = sin(2*pi*incorrectFreqHz*soundData);
    errorTone = sin(2*pi*errorFreqHz*soundData);

    % Feedback
    if(response == -1)
        Beeper(errorFreqHz);
        %sound(errorTone, sampleFreqHz);
    elseif(SessionSettings.bTargetPresent(trialNumber, levelNumber) == response)
        Beeper(correctFreqHz);
        %sound(correctTone, sampleFreqHz);
    else
        Beeper(incorrectFreqHz);
        %sound(incorrectTone, sampleFreqHz);
    end

end
