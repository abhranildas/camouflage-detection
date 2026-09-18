function run_camouflage_experiment_search(subject_str, exp_type)
% RUN_CAMOUFLAGE_EXPERIMENT_SEARCH  Launch the search/detect variant of the camouflage experiment.
%   experiment.main.run_camouflage_experiment_search(subject_str, exp_type)
%
%   A separate, self-contained implementation from experiment.main.
%   RUN_CAMOUFLAGE_EXPERIMENT: instead of the shared vislab.psychframework
%   session->level->trial harness, it draws its own circular location cues
%   and scores either a single detect response or a multi-location search
%   click, resuming at the subject's first incomplete session. No EyeLink
%   support. Run `setup` first (adds vislab). Requires Psychtoolbox.
%
%   Inputs
%     subject_str - subject identifier string.
%     exp_type    - 'detect' or 'search'; selects both the cueing behaviour
%                   (which location is marked) and the scoring rule (click
%                   side vs. click location).
%
%   Output
%     none (side effect: runs the experiment, saves SubjectExpFile after
%     each session to exp_files/search/<exp_type>/subject_out/<subject_str>.mat).
%
%   See also experiment.main.RUN_CAMOUFLAGE_EXPERIMENT.

    %% load experiment settings and subject results file
    load(['exp_files/search/' exp_type '/exp_settings.mat'], 'ExpSettings', 'Stimulus');
    load(['exp_files/search/' exp_type '/subject_out/' subject_str '.mat'], 'SubjectExpFile');

    %% resume experiment
    current_session = find(SubjectExpFile.expCompleted == 0, 1);

    if isempty(current_session)
        error('Congratulations! This experiment has been completed.');
    end

    %% functions
    gamma_correction = @(x, bit, gamma) (x./(2^bit-1)).^(1/gamma)*(2^bit-1);

    %% Psychtoolbox initialization
    rng('default');
    rng('shuffle');
    Screen('Preference', 'SkipSyncTests', 1);
    sca;
    PsychDefaultSetup(2);
    screen_number = max(Screen('Screens'));
    bg_mean_gamma = gamma_correction(Stimulus.bgMean, ExpSettings.monitorBit, ...
        ExpSettings.monitorGamma);
    [win, win_rect] = Screen('OpenWindow', screen_number, bg_mean_gamma);
    ExpSettings.monitorPx = win_rect(3:4);
    % ExpSettings.blank=0.5;

    tone_high = 600;
    tone_low = tone_high/3;

    %% Luminance sheet
    luminance_sheet = ones(ExpSettings.monitorPx(2), ExpSettings.monitorPx(1)) * Stimulus.bgMean;
    luminance_sheet_gc = gamma_correction(luminance_sheet, ExpSettings.monitorBit, ...
        ExpSettings.monitorGamma);
    blank_tex = Screen('MakeTexture', win, luminance_sheet_gc);
    stimulus = luminance_sheet_gc;

    %% Stimulus mask

    stim_start = floor((size(luminance_sheet, 2) - Stimulus.stimulus_sz)/2) + 1;
    stim_end = stim_start + Stimulus.stimulus_sz - 1;

    shifted_spot_centers = Stimulus.spotCenters;
    shifted_spot_centers(:, 1) = shifted_spot_centers(:, 1) + ...
        (ExpSettings.monitorPx(2)-Stimulus.stimulus_sz)/2;
    shifted_spot_centers(:, 2) = shifted_spot_centers(:, 2) + ...
        (ExpSettings.monitorPx(1)-Stimulus.stimulus_sz)/2;

    [display_y, display_x] = meshgrid(1:ExpSettings.monitorPx(1), 1:ExpSettings.monitorPx(2));
    % display_mask = false(ExpSettings.monitorPx(2), ExpSettings.monitorPx(1));
    % for i_location = 1:Stimulus.nLocations
    %     display_mask(sqrt((display_x-shifted_spot_centers(i_location,1)).^2+(display_y-shifted_spot_centers(i_location,2)).^2)...
    %         <= Stimulus.spotLength/2)= true;
    % end

    %% Main
    ShowCursor('CrossHair');
    for i_session = current_session:ExpSettings.nSessions
        disp(['Current session: ', num2str(i_session)]);

        %% Create circular cues and fixation dot
        circular_cue = zeros(ExpSettings.monitorPx(2), ExpSettings.monitorPx(1));
        for i_location = 1:Stimulus.nLocations
            center_ring = round(sqrt((display_x-shifted_spot_centers(i_location, 1)).^2 ...
                +(display_y-shifted_spot_centers(i_location, 2)).^2)) ...
                == floor(Stimulus.spotLength/2);
            inner_ring = round(sqrt((display_x-shifted_spot_centers(i_location, 1)).^2 ...
                +(display_y-shifted_spot_centers(i_location, 2)).^2)) ...
                == floor(Stimulus.spotLength/2) - 1;
            outer_ring = round(sqrt((display_x-shifted_spot_centers(i_location, 1)).^2 ...
                +(display_y-shifted_spot_centers(i_location, 2)).^2)) ...
                == floor(Stimulus.spotLength/2) + 1;
            if strcmpi(exp_type, 'detect')
                if i_location == i_session
                    circular_cue(center_ring | inner_ring | outer_ring) = -Stimulus.bgMean*0.2;
                else
                    circular_cue(center_ring | inner_ring | outer_ring) = Stimulus.bgMean*0.2;
                end
            elseif strcmpi(exp_type, 'search')
                circular_cue(center_ring | inner_ring | outer_ring) = Stimulus.bgMean*0.2;
            end
        end

        fix_dot_radius = 3;                      % radius in px (adjust to taste)
        fix_dot_value = Stimulus.bgMean * 0.6;    % contrast level

        % logical mask for a filled circle around the middle of the screen
        fix_mask = (display_x - ExpSettings.monitorPx(2)/2).^2 + ...
            (display_y - ExpSettings.monitorPx(1)/2).^2 <= fix_dot_radius^2;

        circular_cue(fix_mask) = fix_dot_value;    % write the dot into the image

        circle_cues = luminance_sheet + circular_cue;
        circle_cues = round(gamma_correction(circle_cues, ExpSettings.monitorBit, ...
            ExpSettings.monitorGamma));

        cue_tex = Screen('MakeTexture', win, circle_cues);

        n_correct = 0;
        tic
        if SubjectExpFile.expCompleted(i_session) == 0

            %% show starting screen
            sample_stimulus = luminance_sheet + circular_cue;
            sample_stimulus_gc = gamma_correction(sample_stimulus, ExpSettings.monitorBit, ...
                ExpSettings.monitorGamma);
            tex = Screen('MakeTexture', win, sample_stimulus_gc);
            Screen('DrawTexture', win, tex);

            DrawFormattedText(win, sprintf('Session %d. Click to start.', i_session), ...
                'center', Stimulus.ppd);

            Screen('Flip', win);
            GetClicks(screen_number, 0); % wait for click before starting session

            for i_trial = 1:ExpSettings.nTrials

                %% get stimulus
                stimulus(:, stim_start:stim_end) = Stimulus.stimuli(:, :, i_trial, i_session);

                %% wait for click before starting trial
                % GetClicks(screen_number, 0);

                %% show blank screen
                HideCursor;
                Screen('DrawTexture', win, blank_tex);
                trial_start = GetSecs();
                Screen('Flip', win);

                %% show the stimulus
                % trial_start = GetSecs();
                tex = Screen('MakeTexture', win, stimulus);
                Screen('DrawTexture', win, tex);
                Screen('Flip', win, trial_start + ExpSettings.blank);

                %% show circular cues
                Screen('DrawTexture', win, cue_tex);
                Screen('Flip', win, trial_start + ExpSettings.blank + ExpSettings.stim_on);
                ShowCursor;

                %% get response
                response_start = GetSecs();
                [clicks, click_x, click_y, which_button, click_secs] = GetClicks(screen_number, 0);
                if clicks == 1
                    SubjectExpFile.reactionTime(i_trial, i_session) = click_secs - response_start;
                    if which_button == 1
                        if strcmpi(exp_type, 'detect')
                            SubjectExpFile.response(i_trial, i_session) = 1;
                        elseif strcmpi(exp_type, 'search')
                            valid_click = 0;
                            for i_location = 1:Stimulus.nLocations
                                if sqrt((click_x-shifted_spot_centers(i_location, 2)).^2 ...
                                        +(click_y-shifted_spot_centers(i_location, 1)).^2) ...
                                        < Stimulus.spotLength/2
                                    valid_click = 1;
                                    SubjectExpFile.response(i_trial, i_session) = i_location;
                                    break;
                                end
                            end

                            if valid_click == 0
                                warning('Your left click did not land in a target location.')
                                SubjectExpFile.response(i_trial, i_session) = 0;
                            end
                        end

                    else
                        SubjectExpFile.response(i_trial, i_session) = 0;
                    end
                else
                    warning('You did not make a decision in the trial.');
                    SubjectExpFile.response(i_trial, i_session) = 0;
                end

                %% auditory feedback

                if(Stimulus.tLocation(i_trial, i_session) == ...
                        SubjectExpFile.response(i_trial, i_session))
                    Beeper(tone_high, 1.5, .1);
                    n_correct = n_correct + 1;
                else
                    Beeper(tone_low, 1.5, .1);
                end
            end
        end

        %% save results
        SubjectExpFile.expCompleted(i_session) = 1;
        folder_out = ['exp_files/search/' exp_type '/subject_out'];
        file_path_out = [folder_out '/' subject_str '.mat'];
        save(file_path_out, 'SubjectExpFile');

        fprintf('\n*****Progress summary*****\n');
        disp(['Accuracy: ', num2str(100*n_correct/ExpSettings.nTrials) '%']);
        disp(['Session finishing: ', num2str(i_session), '/', num2str(ExpSettings.nSessions)]);
        toc

    end
    Screen('Close', win);

end
