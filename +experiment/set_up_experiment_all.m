function set_up_experiment_all(subject_str)
% SET_UP_EXPERIMENT_ALL  Set up the all-textures variant of the camouflage experiment.
%   experiment.set_up_experiment_all(subject_str)
%
%   Variant of experiment.set_up_experiment in which the level is not an edge-
%   power band but a texture: every texture in exp_files/all/texture_list.mat
%   contributes the same number of trials, which are then shuffled into the
%   usual trial/level/session layout. Nothing else about the experiment
%   changes. It takes no exp_type, because the experiment name is 'all'.
%
%   Inputs
%     subject_str - n_subjects x 2 char array of subject initials, one row per
%                   subject, each becoming a subject_out/<initials>.mat file.
%
%   Output
%     none (side effects: creates exp_files/all/exp_settings.mat and
%     exp_files/all/subject_out/<initials>.mat for each subject).
%
%   Fixed here rather than passed in: luminance 0.5 and contrast 0.15
%   (normalised / dimensionless), a 256-pixel stimulus with a 64-pixel target
%   radius, and 60 pixels per degree.
%
%   This is one of five near-duplicate set_up_experiment variants; S3.3 collapses
%   them into one function taking a level-variable specification.
%
%   See also experiment.SET_UP_EXPERIMENT, experiment.SESSION_SETTINGS_ALL,
%   experiment.SUBJECT_EXPERIMENT_FILE.

    % Portilla-Simoncelli texture
    addpath(genpath('por_sim_tx_synth'))

    luminance = 0.5;
    contrast = 0.15;
    bg_size = 256; % in px
    target_radius = 64; % in px
%     n_levels=10;
    ppd = 60; % in PPD

    %% Session files
    ExpSettings = experiment.session_settings_all(luminance, contrast, bg_size, ...
        target_radius, ppd);
    folder_out = 'exp_files/all';
    mkdir(folder_out);
    file_path_out = [folder_out '/exp_settings.mat'];
    save(file_path_out, 'ExpSettings');

    %% Subject experiment files
    %subject_str = ['ad'; 'cw'; 'es'; 'wg'];
    n_subjects = size(subject_str, 1);

    for i_subject = 1:n_subjects
        SubjectExpFile = experiment.subject_experiment_file(ExpSettings);
        folder_out = 'exp_files/all/subject_out';
        mkdir(folder_out);
        file_path_out = [folder_out '/' subject_str(i_subject, :) '.mat'];
        save(file_path_out, 'SubjectExpFile');
    end
end
