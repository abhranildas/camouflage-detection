function set_up_experiment(variant, exp_type, subject_str)
% SET_UP_EXPERIMENT  Create and save an experiment's settings, stimuli and subject files.
%   experiment.set_up_experiment(variant, exp_type, subject_str)
%
%   The entry point for setting up a camouflage detection experiment. Fixes the
%   display and target geometry, builds whatever describes the chosen variant's
%   levels, calls experiment.session_settings to synthesise the whole stimulus
%   set, and writes one settings file plus one empty result file per subject.
%
%   The five variants differ only in what a level is. Everything after the
%   switch — the settings file, the subject loop — is shared, and the switch
%   itself only assembles the arguments experiment.session_settings needs.
%
%   Inputs
%     variant     - which quantity the experiment varies across levels:
%                   'edge_power'       the target's edge power, in bands read
%                                      from the experiment's edge-power file.
%                                      The original experiment.
%                   'all'              the texture itself, drawn from a texture
%                                      list; every texture gets the same number
%                                      of trials and the pool is then shuffled.
%                   'diff_bg'          the background's 1/f exponent, with the
%                                      target's held fixed, so the levels run
%                                      from a background statistically identical
%                                      to the target to one clearly different.
%                   'shape_exponent'   the 1/f exponent of the target boundary's
%                                      shape, so the outline runs rough to
%                                      smooth while its texture stays fixed.
%                   'texture_exponent' the texture's 1/f exponent, applied to
%                                      target and background alike, so the
%                                      levels run fine-grained to coarse.
%     exp_type    - experiment name, and the exp_files/ subdirectory written to.
%                   For 'edge_power' it also selects the edge-power file and,
%                   unless it is 'pink_noise', the source image whose
%                   Portilla-Simoncelli statistics the texture is built from.
%     subject_str - n_subjects x 2 char array of subject initials, one row per
%                   subject, each becoming a subject_out/<initials>.mat file.
%
%   Output
%     none (side effects: creates exp_files/<exp_type>/exp_settings.mat and
%     exp_files/<exp_type>/subject_out/<initials>.mat for each subject).
%
%   Fixed here rather than passed in: luminance 0.5 and contrast 0.15
%   (normalised / dimensionless) for every variant, and the geometry — a
%   256-pixel stimulus with a 64-pixel target radius at 60 pixels per degree,
%   except 'shape_exponent', which doubles all three. Pixels per degree is
%   stored in a field named monitor_distance, which is a misnomer (B3.8).
%
%   Every path this function reads or writes comes from config(): the
%   edge-power file from cfg.paths.edge_powers, the Portilla-Simoncelli source
%   texture from cfg.paths.textures, the settings and subject files from
%   cfg.paths.exp_files (S2.2, which resolved B2.1 — all three used to be
%   cwd-relative literals, and the edge-power one named a directory that has
%   never existed).
%
%   Only 'diff_bg' has actually been run.
%   'texture_exponent' calls lib.circular_mask, which does not exist (B2.9), and
%   'shape_exponent' asks for a boundary roughness that never reaches the
%   stimulus, because lib.create_pink_noise_line ignores the exponent it is
%   handed (B1.3).
%
%   The global bdry_ribbon set below is never read; the generators recompute the
%   same ribbon locally (S1.13). It keeps its name because a global is shared
%   across files, not file-local.
%
%   texture_params.Niter is a struct field written to disk, so it keeps its name
%   even though the local feeding it was expanded to n_synthesis_iter.
%
%   'shape_exponent' is the one variant whose settings file is saved with
%   '-v7.3', because a 512-pixel stimulus set exceeds the 2 GB limit of the
%   default MAT-file format.
%
%   See also experiment.SESSION_SETTINGS, experiment.SUBJECT_EXPERIMENT_FILE,
%   lib.STIMULUS.

    arguments
        variant (1, :) char {mustBeMember(variant, {'edge_power', 'all', 'diff_bg', ...
            'shape_exponent', 'texture_exponent'})}
        exp_type char
        subject_str char
    end

    cfg = config();

    %% CAMOUFLAGE
    luminance = 0.5;
    contrast = 0.15;

    % for checking clipping in boundary ribbon region
    global bdry_ribbon;

    % Extra arguments experiment.session_settings needs for this variant, and
    % the MAT-file version the settings file is saved with.
    level_args = {};
    mat_version = {};

    switch variant
        case 'edge_power'
            bg_size = 256; % in px
            target_radius = 64; % in px
%     n_levels=10;
            monitor_distance = 60; % in PPD
            % transform ml & cont of stimuli of existing experiment, or leave blank
            transform_exp_name = '';

            if strcmp(exp_type, 'pink_noise')
                %         seed_energy_file='seed_energy_pn_gradbynorm';
                texture_params.type = 'pink_noise';
            else
                %         seed_energy_file='edge_strengths_bark';
                % for bark texture with portilla simoncelli:
                addpath(genpath(cfg.paths.por_sim))
                source_image_path = fullfile(cfg.paths.textures, [exp_type, '.png']);
                source_image = double(im2gray(imread(source_image_path)));

                n_scales = 4; % Number of scales
                n_orientations = 4; % Number of orientations
                neighborhood_size = 9;  % Spatial neighborhood, in coefficients per side
                n_synthesis_iter = 25;  % Number of iterations of synthesis loop

                texture_params = struct;
                texture_params.type = 'por_sim';
                texture_params.stats = textureAnalysis(source_image, n_scales, n_orientations, ...
                    neighborhood_size);
                texture_params.Niter = n_synthesis_iter;
            end

            % load edge power file
            load(fullfile(cfg.paths.edge_powers, [exp_type, '.mat']), 'edgePowerBlockEdges');

            % find the widest span around the mean edge power,
            % such that 10 equal-width bins each have >=80 samples (to be safe; exp. needs
            % ~60 target samples in each bin).
%     dist_mean=mean(edge_powers(:,2));
%     dist_span=(max(edge_powers(:,2))-min(edge_powers(:,2)))/2;
%     while true
%         h=histcounts(edge_powers(:,2),linspace(dist_mean-dist_span,dist_mean+dist_span,n_levels+1));
%         if min(h)>80
%             break
%         else
%             dist_span=.9*dist_span;
%         end
%     end

%     edgePowerBlockEdges=linspace(dist_mean-dist_span,dist_mean+dist_span,n_levels+1);
%     edgePowerBlockEdges = linspace(min(edge_powers(:,2)),max(edge_powers(:,2)),n_levels+1);

            [~, ~, ~, bdry_ribbon] = lib.target_mask('bg_size', bg_size, ...
                'target_radius', target_radius);

            level_args = {'texture_params', texture_params, 'levels', edgePowerBlockEdges, ...
                'transform_exp_name', transform_exp_name};

        case 'all'
            % Portilla-Simoncelli texture
            addpath(genpath(cfg.paths.por_sim))

            bg_size = 256; % in px
            target_radius = 64; % in px
            monitor_distance = 60; % in PPD

        case 'diff_bg'
            bg_size = 256; % in px
            target_radius = 64; % in px
            monitor_distance = 60; % in PPD
            texture_params.type = 'pink_noise';
            target_exponent = .5;
            bg_exponents = linspace(0, 1, 10);

            [~, ~, ~, bdry_ribbon] = lib.target_mask('bg_size', bg_size, ...
                'target_radius', target_radius);

            level_args = {'texture_params', texture_params, 'levels', bg_exponents, ...
                'target_exponent', target_exponent};

        case 'shape_exponent'
            bg_size = 512; % in px
            target_radius = 128; % in px
            monitor_distance = 120; % in PPD
            texture_params.type = 'pink_noise';
            texture_params.exponent = 1.1;
            shape_exponents = .8249;

            level_args = {'texture_params', texture_params, 'levels', shape_exponents};
            mat_version = {'-v7.3'};

        case 'texture_exponent'
            bg_size = 256; % in px
            target_radius = 64; % in px
            monitor_distance = 60; % in PPD
            kernel_size = [1 3];
            texture_params.type = 'pink_noise';
            texture_exponents = linspace(.8, 2, 10);

            [~, ~, ~, bdry_ribbon] = lib.circular_mask(bg_size, target_radius, 'center', ...
                kernel_size);

            level_args = {'texture_params', texture_params, 'levels', texture_exponents};
    end

    %% Session files
    %for i_condition = 1:n_conditions
    ExpSettings = experiment.session_settings(variant, exp_type, luminance, contrast, ...
        bg_size, target_radius, monitor_distance, level_args{:});
%     if strcmp(exp_type,'pink_noise')
%         folder_out= ['exp_files/' exp_type '_L' num2str(luminance) '_C' num2str(contrast)];
%     else
    folder_out = fullfile(cfg.paths.exp_files, exp_type);
%     end
    mkdir(folder_out);
    file_path_out = fullfile(folder_out, 'exp_settings.mat');
    save(file_path_out, 'ExpSettings', mat_version{:});
    %end

    %% Subject experiment files
    %subject_str = ['ad'; 'cw'; 'es'; 'wg'];
    n_subjects = size(subject_str, 1);

    for i_subject = 1:n_subjects
        SubjectExpFile = experiment.subject_experiment_file(ExpSettings);
        %             folder_out= ['exp_files/' exp_type '_L' num2str(luminance) '_C' num2str(contrast) '/subject_out'];
        folder_out = fullfile(cfg.paths.exp_files, exp_type, 'subject_out');
        mkdir(folder_out);
        file_path_out = fullfile(folder_out, [subject_str(i_subject, :) '.mat']);
        save(file_path_out, 'SubjectExpFile');
    end
end
