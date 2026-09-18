function set_up_experiment_shape_exponent(exp_type, subject_str)
% SET_UP_EXPERIMENT_SHAPE_EXPONENT  Set up the target-shape-roughness variant of the experiment.
%   experiment.set_up_experiment_shape_exponent(exp_type, subject_str)
%
%   Variant of experiment.set_up_experiment in which the level is the 1/f
%   exponent of the target boundary's shape, so the target's outline runs from
%   rough to smooth while its texture stays fixed. There is no edge-power
%   file; each stimulus's edge power is measured after it is made.
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
%   (normalised / dimensionless), a 512-pixel stimulus with a 128-pixel target
%   radius, 120 pixels per degree, a pink-noise texture of exponent 1.1, and a
%   single shape exponent of 0.8249 — so as written this "variant over shape
%   exponents" has one level.
%
%   The manipulation this variant exists for does not currently reach the
%   stimulus: lib.create_pink_noise_line ignores the exponent it is handed, so
%   every target boundary is generated at exponent 1 whatever is asked for
%   (B1.3). Whether the stimuli already on disk predate that regression is
%   unverified.
%
%   The settings file is saved with '-v7.3' here, unlike the other variants,
%   because a 512-pixel stimulus set exceeds the 2 GB limit of the default
%   MAT-file format.
%
%   This is one of five near-duplicate set_up_experiment variants; S3.3 collapses
%   them into one function taking a level-variable specification.
%
%   See also experiment.SET_UP_EXPERIMENT, experiment.SESSION_SETTINGS_SHAPE_EXPONENT,
%   experiment.SUBJECT_EXPERIMENT_FILE.

    %% CAMOUFLAGE
    luminance = 0.5;
    contrast = 0.15;
    bg_size = 512; % in px
    target_radius = 128; % in px
    shape_exponents = .8249;
    monitor_distance = 120; % in PPD

    % for checking clipping in boundary ribbon region
%     kernel_size=[1 3];

    texture.type = 'pink_noise';
    texture.exponent = 1.1;

%     global bdry_ribbon;
%     [~,~,~,bdry_ribbon]=lib.circular_mask(bg_size,target_radius,'center',kernel_size);

    %% Session files
    ExpSettings = experiment.session_settings_shape_exponent(exp_type, texture, ...
        shape_exponents, luminance, contrast, bg_size, target_radius, monitor_distance);
    folder_out = ['exp_files/' exp_type];
    mkdir(folder_out);
    file_path_out = [folder_out '/exp_settings.mat'];
    save(file_path_out, 'ExpSettings', '-v7.3');

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
