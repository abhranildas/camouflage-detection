function el = configure_eyetracker(SessionSettings)
% CONFIGURE_EYETRACKER  Initialize and configure the EyeLink eye tracker.
%   el = experiment.main.configure_eyetracker(SessionSettings)
%
%   Initializes the EyeLink connection, opens an EDF file for this session,
%   and sets the tracker's calibration type, saccade thresholds, and file/
%   link data contents. If not in dummy mode, also runs tracker setup and
%   starts recording briefly before returning.
%
%   Inputs
%     SessionSettings - session settings struct; uses .window, .bgPixValGamma,
%                       .currentSession.
%
%   Output
%     el - EyeLink handle struct (from EyelinkInitDefaults), with
%          .dummyconnected set from the EyeLink connection status.
%
% v1.0 R. Calen Walshe (calen.walshe@utexas.edu)
%
%   See also experiment.main.RUN_CAMOUFLAGE_EXPERIMENT.

    [status, dummy] = EyelinkInit();
    el = EyelinkInitDefaults(SessionSettings.window);
    el.backgroundcolour = SessionSettings.bgPixValGamma;

    el.dummyconnected = dummy;

    if dummy == 0
        % make sure that we get gaze data from the Eyelink
        Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

        Eyelink('Command', 'set_idle_mode');
        Eyelink('Command', 'clear_screen 0');
        EyelinkDoTrackerSetup(el, 'd');
        Eyelink('Command', 'set_idle_mode');
        Eyelink('StartRecording');

        % record a few samples before we actually start displaying
        WaitSecs(0.1);
    end

    Screen('FillRect', SessionSettings.window, SessionSettings.bgPixValGamma);
    Screen('Flip', SessionSettings.window);

    sessionNumber = SessionSettings.currentSession;
    edfFile = [num2str(sessionNumber) '.edf'];

    edfOpenStatus = Eyelink('Openfile', edfFile);
    if edfOpenStatus ~= 0
        fprintf('Cannot create EDF file');
        cleanup;
        Eyelink('Shutdown');
        return;
    end

    % Set up tracker configuration
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, 1919, 1199);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, 1919, 1199);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    % set parser (conservative saccade thresholds)
    Eyelink('command', 'saccade_velocity_threshold = 35');
    Eyelink('command', 'saccade_acceleration_threshold = 9500');
    % set EDF file contents
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');

end
