function setUpExperiment_diff_bg(exp_type, subjectStr)
% SETUPEXPERIMENT_DIFF_BG  Set up the different-background variant of the experiment.
%   experiment.setUpExperiment_diff_bg(exp_type, subjectStr)
%
%   Variant of experiment.setUpExperiment in which the level is the
%   background's 1/f exponent while the target's stays fixed, so the levels
%   run from a background statistically identical to the target to one clearly
%   different from it. There is no edge-power file; the edge power of each
%   stimulus is measured after the fact.
%
%   Inputs
%     exp_type   - experiment name, also the exp_files/ subdirectory.
%     subjectStr - nSubjects x 2 char array of subject initials, one row per
%                  subject, each becoming a subject_out/<initials>.mat file.
%
%   Output
%     none (side effects: creates exp_files/<exp_type>/exp_settings.mat and
%     exp_files/<exp_type>/subject_out/<initials>.mat for each subject).
%
%   Fixed here rather than passed in: luminance 0.5 and contrast 0.15
%   (normalised / dimensionless), a 256-pixel stimulus with a 64-pixel target
%   radius, 60 pixels per degree, a target 1/f exponent of 0.5, and ten
%   background exponents evenly spaced over [0, 1]. All exponents are
%   dimensionless.
%
%   This variant was run, and it is the one affected by the two recorded
%   target/background confusions in lib.stimulus, B1.4 and B2.13 — both are
%   silent or harmless when target and background textures match, which is why
%   they surface here and nowhere else.
%
%   The global bdry_ribbon set below is never read; the generator recomputes
%   the same ribbon locally (S3.13). It keeps its name because a global is
%   shared across files, not file-local.
%
%   This is one of five near-duplicate setUpExperiment variants; S3.3 collapses
%   them into one function taking a level-variable specification.
%
%   See also experiment.SETUPEXPERIMENT, experiment.SESSIONSETTINGS_DIFF_BG,
%   experiment.SUBJECTEXPERIMENTFILE.

    %% CAMOUFLAGE
    luminance = 0.5;
    contrast = 0.15;
    bg_size = 256; % in px
    target_radius = 64;
    target_exponent = .5;
    bg_exponents = linspace(0, 1, 10);
    monitor_distance = 60; % in PPD

    global bdry_ribbon;
    [~, ~, ~, bdry_ribbon] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);

    %% Session files
    ExpSettings = experiment.sessionSettings_diff_bg(exp_type, target_exponent, ...
        bg_exponents, luminance, contrast, bg_size, target_radius, monitor_distance);
    folderOut = ['exp_files/' exp_type];
    mkdir(folderOut);
    filePathOut = [folderOut '/exp_settings.mat'];
    save(filePathOut, 'ExpSettings');

    %% Subject experiment files
    %subjectStr = ['ad'; 'cw'; 'es'; 'wg'];
    nSubjects = size(subjectStr, 1);

    for iSubject = 1:nSubjects
        SubjectExpFile = experiment.subjectExperimentFile(ExpSettings);
        folderOut = ['exp_files/' exp_type '/subject_out'];
        mkdir(folderOut);
        filePathOut = [folderOut '/' subjectStr(iSubject, :) '.mat'];
        save(filePathOut, 'SubjectExpFile');
    end
end
