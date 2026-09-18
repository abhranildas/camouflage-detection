function give_feedback(SessionSettings, response, trial_number, level_number)
% GIVE_FEEDBACK  Play an auditory feedback tone for a trial's response.
%   experiment.main.give_feedback(SessionSettings, response, trial_number, level_number)
%
%   Beeps at error_freq_hz for a timeout response (response == -1), at
%   correct_freq_hz if the response matches SessionSettings.bTargetPresent for
%   this trial/level, and at incorrect_freq_hz otherwise.
%
%   Inputs
%     SessionSettings - session settings struct; uses .bTargetPresent.
%     response        - the subject's response for this trial (-1 = timeout).
%     trial_number    - trial index into SessionSettings.bTargetPresent.
%     level_number    - level index into SessionSettings.bTargetPresent.
%
%   Output
%     none (side effect: plays a tone).
%
%   See also experiment.main.RESPONSE_INTERVAL.

    %% Sound parameters
    sample_freq_hz = 22050;
    tone_duration_s = 0.05;
    n_samples = sample_freq_hz * tone_duration_s;
    sound_data = (1:n_samples) / sample_freq_hz;

    correct_freq_hz = 900;
    incorrect_freq_hz = 300;
    error_freq_hz = 1500;

    correct_tone = sin(2*pi*correct_freq_hz*sound_data);
    incorrect_tone = sin(2*pi*incorrect_freq_hz*sound_data);
    error_tone = sin(2*pi*error_freq_hz*sound_data);

    % Feedback
    if(response == -1)
        Beeper(error_freq_hz);
        %sound(error_tone, sample_freq_hz);
    elseif(SessionSettings.bTargetPresent(trial_number, level_number) == response)
        Beeper(correct_freq_hz);
        %sound(correct_tone, sample_freq_hz);
    else
        Beeper(incorrect_freq_hz);
        %sound(incorrect_tone, sample_freq_hz);
    end

end
