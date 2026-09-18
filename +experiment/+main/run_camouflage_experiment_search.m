function run_camouflage_experiment_search(subjectStr, expType)
% RUN_CAMOUFLAGE_EXPERIMENT_SEARCH  Launch the search/detect variant of the camouflage experiment.
%   experiment.main.run_camouflage_experiment_search(subjectStr, expType)
%
%   A separate, self-contained implementation from experiment.main.
%   RUN_CAMOUFLAGE_EXPERIMENT: instead of the shared vislab.psychframework
%   session->level->trial harness, it draws its own circular location cues
%   and scores either a single detect response or a multi-location search
%   click, resuming at the subject's first incomplete session. No EyeLink
%   support. Run `setup` first (adds vislab). Requires Psychtoolbox.
%
%   Inputs
%     subjectStr - subject identifier string.
%     expType    - 'detect' or 'search'; selects both the cueing behaviour
%                  (which location is marked) and the scoring rule (click
%                  side vs. click location).
%
%   Output
%     none (side effect: runs the experiment, saves SubjectExpFile after
%     each session to exp_files/search/<expType>/subject_out/<subjectStr>.mat).
%
%   See also experiment.main.RUN_CAMOUFLAGE_EXPERIMENT.

    %% load experiment settings and subject results file
    load(['exp_files/search/' expType '/exp_settings.mat'], 'ExpSettings', 'Stimulus');
    load(['exp_files/search/' expType '/subject_out/' subjectStr '.mat'], 'SubjectExpFile');

    %% resume experiment
    currentSession = find(SubjectExpFile.expCompleted == 0, 1);

    if isempty(currentSession)
        error('Congratulations! This experiment has been completed.');
    end

    %% functions
    gammaCorrection = @(x, bit, gamma) (x./(2^bit-1)).^(1/gamma)*(2^bit-1);

    %% Psychtoolbox initialization
    rng('default');
    rng('shuffle');
    Screen('Preference', 'SkipSyncTests', 1);
    sca;
    PsychDefaultSetup(2);
    screenNumber = max(Screen('Screens'));
    bgMeanGamma = gammaCorrection(Stimulus.bgMean, ExpSettings.monitorBit, ...
        ExpSettings.monitorGamma);
    [win, winRect] = Screen('OpenWindow', screenNumber, bgMeanGamma);
    ExpSettings.monitorPx = winRect(3:4);
    % ExpSettings.blank=0.5;

    toneH = 600;
    toneL = toneH/3;

    %% Luminance sheet
    luminanceSheet = ones(ExpSettings.monitorPx(2), ExpSettings.monitorPx(1)) * Stimulus.bgMean;
    luminanceSheetGc = gammaCorrection(luminanceSheet, ExpSettings.monitorBit, ...
        ExpSettings.monitorGamma);
    blankTex = Screen('MakeTexture', win, luminanceSheetGc);
    stimulus = luminanceSheetGc;

    %% Stimulus mask

    stimStart = floor((size(luminanceSheet, 2) - Stimulus.stimulus_sz)/2) + 1;
    stimEnd = stimStart + Stimulus.stimulus_sz - 1;

    shiftedSpotCenters = Stimulus.spotCenters;
    shiftedSpotCenters(:, 1) = shiftedSpotCenters(:, 1) + ...
        (ExpSettings.monitorPx(2)-Stimulus.stimulus_sz)/2;
    shiftedSpotCenters(:, 2) = shiftedSpotCenters(:, 2) + ...
        (ExpSettings.monitorPx(1)-Stimulus.stimulus_sz)/2;

    [displayY, displayX] = meshgrid(1:ExpSettings.monitorPx(1), 1:ExpSettings.monitorPx(2));
    % displayMask = false(ExpSettings.monitorPx(2), ExpSettings.monitorPx(1));
    % for iLocation = 1:Stimulus.nLocations
    %     displayMask(sqrt((displayX-shiftedSpotCenters(iLocation,1)).^2+(displayY-shiftedSpotCenters(iLocation,2)).^2)...
    %         <= Stimulus.spotLength/2)= true;
    % end

    %% Main
    ShowCursor('CrossHair');
    for iSession = currentSession:ExpSettings.nSessions
        disp(['Current session: ', num2str(iSession)]);

        %% Create circular cues and fixation dot
        circularCue = zeros(ExpSettings.monitorPx(2), ExpSettings.monitorPx(1));
        for iLocation = 1:Stimulus.nLocations
            centerRing = round(sqrt((displayX-shiftedSpotCenters(iLocation, 1)).^2 ...
                +(displayY-shiftedSpotCenters(iLocation, 2)).^2)) ...
                == floor(Stimulus.spotLength/2);
            innerRing = round(sqrt((displayX-shiftedSpotCenters(iLocation, 1)).^2 ...
                +(displayY-shiftedSpotCenters(iLocation, 2)).^2)) ...
                == floor(Stimulus.spotLength/2) - 1;
            outerRing = round(sqrt((displayX-shiftedSpotCenters(iLocation, 1)).^2 ...
                +(displayY-shiftedSpotCenters(iLocation, 2)).^2)) ...
                == floor(Stimulus.spotLength/2) + 1;
            if strcmpi(expType, 'detect')
                if iLocation == iSession
                    circularCue(centerRing | innerRing | outerRing) = -Stimulus.bgMean*0.2;
                else
                    circularCue(centerRing | innerRing | outerRing) = Stimulus.bgMean*0.2;
                end
            elseif strcmpi(expType, 'search')
                circularCue(centerRing | innerRing | outerRing) = Stimulus.bgMean*0.2;
            end
        end

        fixDotRadius = 3;                      % radius in px (adjust to taste)
        fixDotValue = Stimulus.bgMean * 0.6;    % contrast level

        % logical mask for a filled circle around the middle of the screen
        fixMask = (displayX - ExpSettings.monitorPx(2)/2).^2 + ...
            (displayY - ExpSettings.monitorPx(1)/2).^2 <= fixDotRadius^2;

        circularCue(fixMask) = fixDotValue;    % write the dot into the image

        circleCues = luminanceSheet + circularCue;
        circleCues = round(gammaCorrection(circleCues, ExpSettings.monitorBit, ...
            ExpSettings.monitorGamma));

        cueTex = Screen('MakeTexture', win, circleCues);

        nCorrect = 0;
        tic
        if SubjectExpFile.expCompleted(iSession) == 0

            %% show starting screen
            sampleStimulus = luminanceSheet + circularCue;
            sampleStimulusGc = gammaCorrection(sampleStimulus, ExpSettings.monitorBit, ...
                ExpSettings.monitorGamma);
            tex = Screen('MakeTexture', win, sampleStimulusGc);
            Screen('DrawTexture', win, tex);

            DrawFormattedText(win, sprintf('Session %d. Click to start.', iSession), ...
                'center', Stimulus.ppd);

            Screen('Flip', win);
            GetClicks(screenNumber, 0); % wait for click before starting session

            for iTrial = 1:ExpSettings.nTrials

                %% get stimulus
                stimulus(:, stimStart:stimEnd) = Stimulus.stimuli(:, :, iTrial, iSession);

                %% wait for click before starting trial
                % GetClicks(screenNumber, 0);

                %% show blank screen
                HideCursor;
                Screen('DrawTexture', win, blankTex);
                trialStart = GetSecs();
                Screen('Flip', win);

                %% show the stimulus
                % trialStart = GetSecs();
                tex = Screen('MakeTexture', win, stimulus);
                Screen('DrawTexture', win, tex);
                Screen('Flip', win, trialStart + ExpSettings.blank);

                %% show circular cues
                Screen('DrawTexture', win, cueTex);
                Screen('Flip', win, trialStart + ExpSettings.blank + ExpSettings.stim_on);
                ShowCursor;

                %% get response
                responseStart = GetSecs();
                [clicks, clickX, clickY, whichButton, clickSecs] = GetClicks(screenNumber, 0);
                if clicks == 1
                    SubjectExpFile.reactionTime(iTrial, iSession) = clickSecs - responseStart;
                    if whichButton == 1
                        if strcmpi(expType, 'detect')
                            SubjectExpFile.response(iTrial, iSession) = 1;
                        elseif strcmpi(expType, 'search')
                            validClick = 0;
                            for iLocation = 1:Stimulus.nLocations
                                if sqrt((clickX-shiftedSpotCenters(iLocation, 2)).^2 ...
                                        +(clickY-shiftedSpotCenters(iLocation, 1)).^2) ...
                                        < Stimulus.spotLength/2
                                    validClick = 1;
                                    SubjectExpFile.response(iTrial, iSession) = iLocation;
                                    break;
                                end
                            end

                            if validClick == 0
                                warning('Your left click did not land in a target location.')
                                SubjectExpFile.response(iTrial, iSession) = 0;
                            end
                        end

                    else
                        SubjectExpFile.response(iTrial, iSession) = 0;
                    end
                else
                    warning('You did not make a decision in the trial.');
                    SubjectExpFile.response(iTrial, iSession) = 0;
                end

                %% auditory feedback

                if(Stimulus.tLocation(iTrial, iSession) == ...
                        SubjectExpFile.response(iTrial, iSession))
                    Beeper(toneH, 1.5, .1);
                    nCorrect = nCorrect + 1;
                else
                    Beeper(toneL, 1.5, .1);
                end
            end
        end

        %% save results
        SubjectExpFile.expCompleted(iSession) = 1;
        folderOut = ['exp_files/search/' expType '/subject_out'];
        fpOut = [folderOut '/' subjectStr '.mat'];
        save(fpOut, 'SubjectExpFile');

        fprintf('\n*****Progress summary*****\n');
        disp(['Accuracy: ', num2str(100*nCorrect/ExpSettings.nTrials) '%']);
        disp(['Session finishing: ', num2str(iSession), '/', num2str(ExpSettings.nSessions)]);
        toc

    end
    Screen('Close', win);

end
