function set_up_experiment_diff_bg(exp_type, subject_str)
% SET_UP_EXPERIMENT_DIFF_BG  Set up the different-background variant of the experiment.
%   experiment.set_up_experiment_diff_bg(exp_type, subject_str)
%
%   Variant of experiment.set_up_experiment in which the level is the
%   background's 1/f exponent while the target's stays fixed, so the levels
%   run from a background statistically identical to the target to one clearly
%   different from it. There is no edge-power file; the edge power of each
%   stimulus is measured after the fact.
%
%   Inputs
%     exp_type    - experiment name, also the exp_files/ subdirectory.
%     subject_str - n_subjects x 2 char array of subject initials, one row per
%                   subject, each becoming a subject_out/<initials>.mat file.
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
%   This is one of five near-duplicate set_up_experiment variants; S3.3 collapses
%   them into one function taking a level-variable specification.
%
%   See also experiment.SET_UP_EXPERIMENT, experiment.SESSION_SETTINGS_DIFF_BG,
%   experiment.SUBJECT_EXPERIMENT_FILE.

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
    ExpSettings = experiment.session_settings_diff_bg(exp_type, target_exponent, ...
        bg_exponents, luminance, contrast, bg_size, target_radius, monitor_distance);
    folder_out = ['exp_files/' exp_type];
    mkdir(folder_out);
    file_path_out = [folder_out '/exp_settings.mat'];
    save(file_path_out, 'ExpSettings');

    %% Subject experiment files
    %subject_str = ['ad'; 'cw'; 'es'; 'wg'];
    n_subjects = size(subject_str, 1);

    for i_subject = 1:n_subjects
        SubjectExpFile = experiment.subject_experiment_file(ExpSettings);
        folder_out = ['exp_files/' exp_type '/subject_out'];
        mkdir(folder_out);
        file_path_out = [folder_out '/' subject_str(i_subject, :) '.mat'];
        save(file_path_out, 'SubjectExpFile');
    end
end
