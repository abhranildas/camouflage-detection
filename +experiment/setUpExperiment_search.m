function setUpExperiment_search(exp_type, subjectStr)
% SETUPEXPERIMENT_SEARCH  Set up the visual-search / peripheral-detection experiment.
%   experiment.setUpExperiment_search(exp_type, subjectStr)
%
%   A different paradigm from the other setUpExperiment files, not a variant
%   of them: a large 1/f-noise field carrying a ring of candidate target
%   locations, with a camouflaged target at one of them or at none. In
%   'search' the target may be at any location and the subject reports which;
%   in 'detect' it is always at the location that session cues, and the
%   subject reports present or absent. There are no levels and no edge-power
%   bands, so it builds the ExpSettings and Stimulus structs itself instead of
%   calling experiment.sessionSettings.
%
%   Inputs
%     exp_type   - 'detect' or 'search'.
%     subjectStr - subject initials, a single string, becoming one
%                  subject_out/<initials>.mat file.
%
%   Output
%     none (side effects: creates exp_files/search/<exp_type>/exp_settings.mat
%     and exp_files/search/<exp_type>/subject_out/<initials>.mat).
%
%   Fixed here rather than passed in: a 1200-pixel field at 60 pixels per
%   degree, spot centres laid out along 6 directions at 240-pixel spacing, a
%   64-pixel target radius, mean luminance 0.5 and RMS contrast 0.15
%   (normalised / dimensionless), a pink-noise texture of exponent 1.3, and an
%   8-bit display of gamma 2.059. Interval durations are in seconds here,
%   unlike the milliseconds of experiment.sessionSettings.
%
%   In 'detect', the session number doubles as the cued location index, so
%   nSessions is tied to the number of spot locations.
%
%   The unsuppressed [iSession iTrial target_loc] line prints generation
%   progress to the console; it is deliberate, not a missing semicolon.
%
%   lib.gammaCorrect does not exist anywhere in the tree (B2.9), so this
%   function cannot run as committed; experiment.gammaCorrect is the surviving
%   copy of the same computation (S3.14).
%
%   S3.3 collapses the five near-duplicate experiment variants, but explicitly
%   leaves this file alone: it is a genuinely different paradigm.
%
%   See also experiment.main.RUNCAMOUFLAGEEXPERIMENT_SEARCH, lib.STIMULUS,
%   lib.FIND_SPOT_CENTERS.

    %% experiment settings
    ExpSettings.monitorBit = 8;
    ExpSettings.monitorGamma = 2.059;
    ExpSettings.nTrials = 120;
    ExpSettings.cue_on = .75;
    ExpSettings.blank = .25;
    ExpSettings.stim_on = .25;
    ExpSettings.responseWait = 1.5;

% if strcmpi(exp_type,'detect')
    ExpSettings.nSessions = 19;
% elseif strcmpi(exp_type,'search')
    % ExpSettings.nSessions = 4;
% end

    %% generate stimulus parameters
    Stimulus.ppd = 60;
    Stimulus.stimulus_sz = 1200;
    Stimulus.nDirections = 6;
    Stimulus.spotLength = 208;
    Stimulus.spotResize = 2;
    Stimulus.spotDistance = 240;
    Stimulus.spotCenters = [Stimulus.stimulus_sz/2, Stimulus.stimulus_sz/2];
    Stimulus.spotCenters = lib.find_spot_centers(Stimulus.spotCenters, Stimulus.spotCenters,...
        Stimulus.spotLength, Stimulus.spotDistance, Stimulus.stimulus_sz, Stimulus.nDirections);
    Stimulus.nLocations = size(Stimulus.spotCenters, 1);

    texture = struct;
    texture.type = 'pink_noise';
    texture.exponent = 1.3;
    Stimulus.texture = texture;

    Stimulus.target_radius = 64;
    Stimulus.ml = 0.5;
    Stimulus.cont = 0.15;
    Stimulus.clipTolerance = 0.001;
    Stimulus.bgMean = 2^(ExpSettings.monitorBit - 1);
    Stimulus.bgContrast = 0.2;

    Stimulus.seeds = nan(ExpSettings.nTrials, ExpSettings.nSessions);
    Stimulus.stimuli = nan(Stimulus.stimulus_sz, Stimulus.stimulus_sz, ...
        ExpSettings.nTrials, ExpSettings.nSessions);

    Stimulus.tLocation = nan(ExpSettings.nTrials, ExpSettings.nSessions);
    for iSession = 1:ExpSettings.nSessions
        for iTrial = 1:ExpSettings.nTrials
            % generate target location
            if rand < 0.5
                target_loc_index = 0;
            else
                if strcmpi(exp_type, 'detect')
                    target_loc_index = 1;
                elseif strcmpi(exp_type, 'search')
                    target_loc_index = randi(Stimulus.nLocations);
                end
            end
            Stimulus.tLocation(iTrial, iSession) = target_loc_index;
            [iSession iTrial target_loc_index]  % unsuppressed on purpose: progress report
            % create stimulus
            if target_loc_index % if there is a target
                if strcmpi(exp_type, 'detect')
                    target_loc_index = iSession;
                end
                target_coords = Stimulus.spotCenters(target_loc_index, :);
                [stim, ~, seed] = lib.stimulus('texture', texture, ...
                    'bg_size', Stimulus.stimulus_sz, 'target_radius', Stimulus.target_radius, ...
                    'target_loc', target_coords, 'ml_b', Stimulus.ml, 'cont_b', Stimulus.cont);
            else
                [stim, ~, seed] = lib.stimulus('texture', texture, ...
                    'bg_size', Stimulus.stimulus_sz, 'ml_b', Stimulus.ml, ...
                    'cont_b', Stimulus.cont);
            end
            stim = uint8(lib.gammaCorrect(stim, ExpSettings.monitorGamma, ...
                ExpSettings.monitorBit));
            Stimulus.stimuli(:, :, iTrial, iSession) = stim;
            Stimulus.seeds(iTrial, iSession) = seed;
        end
    end

    %% store experiment and stimulus
    folderOut = ['exp_files/search/' exp_type];
    mkdir(folderOut);
    filePathOut = [folderOut '/exp_settings.mat'];
    save(filePathOut, 'ExpSettings', 'Stimulus', '-v7.3');

    %% Subject result files
    SubjectExpFile.expCompleted = false(ExpSettings.nSessions, 1);
    if strcmpi(exp_type, 'detect')
        SubjectExpFile.response = false(ExpSettings.nTrials, ExpSettings.nSessions);
    elseif strcmpi(exp_type, 'search')
        SubjectExpFile.response = zeros(ExpSettings.nTrials, ExpSettings.nSessions);
    end
    SubjectExpFile.reactionTime = zeros(ExpSettings.nTrials, ExpSettings.nSessions);

    folderOut = ['exp_files/search/' exp_type '/subject_out'];
    mkdir(folderOut);
    filePathOut = [folderOut '/' subjectStr '.mat'];
    save(filePathOut, 'SubjectExpFile');
end
