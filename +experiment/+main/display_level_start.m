function display_level_start(SessionSettings, block_number)
% DISPLAY_LEVEL_START  Show the target-only preview screen at the start of a level.
%   experiment.main.display_level_start(SessionSettings, block_number)
%
%   Presents the target outline, at a random trial's fixation/stimulus
%   position for this level, with an instruction message, and waits for a
%   key press before returning.
%
%   Inputs
%     SessionSettings - session settings struct; uses .nTrials, .fixPosPix,
%                       .stimPosPix, .window, .fixationTarget,
%                       .pixelsPerDeg, .targetSamples.
%     block_number     - level (block) index into SessionSettings.fixPosPix /
%                       .stimPosPix / .targetSamples.
%
%   Output
%     none (side effect: draws to screen, blocks on a key press).
%
%   See also experiment.main.RUN_CAMOUFLAGE_EXPERIMENT.

    % Display the fixation and stimulus position from a random trial in the
    % block
    rand_trial = randsample(SessionSettings.nTrials, 1);
    fix_pos_pix_xy = SessionSettings.fixPosPix(rand_trial, block_number, :);
    stim_pos_pix_xy = SessionSettings.stimPosPix(rand_trial, block_number, :);

    w = SessionSettings.window;

    %% Set up
    fix_target = SessionSettings.fixationTarget;
    fix_pos_xy = fix_pos_pix_xy;
    fixation_interval_s = SessionSettings.fixationIntervalS;

    fix_texture = Screen('Maketexture', SessionSettings.window, fix_target);
    fix_rect = SetRect(0, 0, size(fix_target, 2), size(fix_target, 1));
    fix_destination = floor(CenterRectOnPointd(fix_rect, fix_pos_pix_xy(1), fix_pos_pix_xy(2)));

    %% Draw fix_target followed by blank if foveal experiment

    Screen('TextSize', w, 25);
    DrawFormattedText(w, sprintf('Level %d\n\n This is the outline for the target that you will be required to detect.\n\n Press any key when ready.', block_number), ...
        'center', SessionSettings.pixelsPerDeg);

    target = SessionSettings.targetSamples(:, :, block_number);
    target_texture = Screen('MakeTexture', SessionSettings.window, target);

    target_rect = SetRect(0, 0, size(target, 2), size(target, 1));
    target_destination = floor(CenterRectOnPointd(target_rect, stim_pos_pix_xy(1), ...
        stim_pos_pix_xy(2)));

    % if SessionSettings.bFovea % If foveal experiment, then draw stimulus after fixation cross.
    %     Screen('DrawTexture', SessionSettings.window, fix_texture, [], fix_destination);
    %     Screen('DrawTexture', SessionSettings.window, target_texture, [], target_destination);
    % else
    Screen('DrawTexture', SessionSettings.window, target_texture, [], target_destination);
    Screen('DrawTexture', SessionSettings.window, fix_texture, [], fix_destination);
    % end
    Screen('Flip', SessionSettings.window);

    %WaitSecs(10); %Adapt to background luminance

    KbWait();

    WaitSecs(1);

end
