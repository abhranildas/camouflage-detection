function set_up_experiment_texture_exponent(exp_type, subjectStr)
% SET_UP_EXPERIMENT_TEXTURE_EXPONENT  Set up the texture-exponent variant of the experiment.
%   experiment.set_up_experiment_texture_exponent(exp_type, subjectStr)
%
%   Variant of experiment.set_up_experiment in which the level is the 1/f
%   exponent of the texture itself, applied to target and background alike, so
%   the levels run from a fine-grained to a coarse-grained image. There is no
%   edge-power file; each stimulus's edge power is measured after it is made.
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
%   radius, 60 pixels per degree, and ten texture exponents evenly spaced over
%   [0.8, 2], all dimensionless.
%
%   This chain is the one that renamed nLevels to nBlocks and seeds to
%   stimuliSeed downstream, which every reader of the resulting settings file
%   still expects under the old names (B2.6). lib.circular_mask, called below,
%   does not exist anywhere in the tree (B2.9), so this variant cannot run as
%   committed.
%
%   The global bdry_ribbon set below is never read; the generator recomputes
%   the same ribbon locally (S3.13). It keeps its name because a global is
%   shared across files, not file-local.
%
%   This is one of five near-duplicate set_up_experiment variants; S3.3 collapses
%   them into one function taking a level-variable specification.
%
%   See also experiment.SET_UP_EXPERIMENT, experiment.SESSION_SETTINGS_TEXTURE_EXPONENT,
%   experiment.SUBJECT_EXPERIMENT_FILE.

    %% CAMOUFLAGE
    luminance = 0.5;
    contrast = 0.15;
    bg_size = 256; % in px
    target_radius = 64; % in px
    texture_exponents = linspace(.8, 2, 10);
    monitor_distance = 60; % in PPD

    % for checking clipping in boundary ribbon region
    kernel_size = [1 3];

    texture_params.type = 'pink_noise';

    global bdry_ribbon;
    [~, ~, ~, bdry_ribbon] = lib.circular_mask(bg_size, target_radius, 'center', kernel_size);

    %% Session files
    ExpSettings = experiment.session_settings_texture_exponent(exp_type, texture_params, ...
        texture_exponents, luminance, contrast, bg_size, target_radius, monitor_distance);
    folderOut = ['exp_files/' exp_type];
    mkdir(folderOut);
    filePathOut = [folderOut '/exp_settings.mat'];
    save(filePathOut, 'ExpSettings');

    %% Subject experiment files
    %subjectStr = ['ad'; 'cw'; 'es'; 'wg'];
    nSubjects = size(subjectStr, 1);

    for iSubject = 1:nSubjects
        SubjectExpFile = experiment.subject_experiment_file(ExpSettings);
        folderOut = ['exp_files/' exp_type '/subject_out'];
        mkdir(folderOut);
        filePathOut = [folderOut '/' subjectStr(iSubject, :) '.mat'];
        save(filePathOut, 'SubjectExpFile');
    end
end
