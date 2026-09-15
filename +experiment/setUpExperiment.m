function setUpExperiment(exp_type, subjectStr)
% SETUPEXPERIMENT  Create and save an experiment's settings, stimuli and subject files.
%   experiment.setUpExperiment(exp_type, subjectStr)
%
%   The entry point for setting up a camouflage detection experiment. Fixes
%   the display and target geometry, builds the texture description (pink
%   noise, or Portilla-Simoncelli statistics analysed from a source image),
%   loads the edge-power block edges that define the levels, calls
%   experiment.sessionSettings to synthesise the whole stimulus set, and
%   writes one settings file plus one empty result file per subject.
%
%   Inputs
%     exp_type   - experiment name. Selects the edge-power file, the source
%                  image for a textured experiment, and the exp_files/
%                  subdirectory written to. 'pink_noise' takes the synthetic
%                  branch; anything else is treated as a texture name.
%     subjectStr - nSubjects x 2 char array of subject initials, one row per
%                  subject, each becoming a subject_out/<initials>.mat file.
%
%   Output
%     none (side effects: creates exp_files/<exp_type>/exp_settings.mat and
%     exp_files/<exp_type>/subject_out/<initials>.mat for each subject).
%
%   Fixed here rather than passed in: luminance 0.5 and contrast 0.15
%   (normalised / dimensionless), a 256-pixel stimulus with a 64-pixel target
%   radius, and 60 pixels per degree. The last is stored in a field named
%   monitor_distance, which is a misnomer (B3.8).
%
%   The edge-power directory this loads from does not exist anywhere on disk,
%   so the live setup path cannot currently run; the files are under the
%   repo's own data/edge_powers/, and the source textures are elsewhere again
%   (B2.1, fixed structurally by S3.2).
%
%   The global bdry_ribbon set below is never read; experiment.
%   generate_camouflage_stimuli recomputes the same ribbon locally (S3.13). It
%   keeps its name because a global is shared across files, not file-local.
%
%   texture_params.Niter is a struct field written to disk, so it keeps its
%   name even though the local feeding it was expanded to n_synthesis_iter.
%
%   See also experiment.SESSIONSETTINGS, experiment.SUBJECTEXPERIMENTFILE,
%   lib.STIMULUS.

    %% CAMOUFLAGE
    luminance = 0.5;
    contrast = 0.15;
    bg_size = 256; % in px
    target_radius = 64; % in px
%     nLevels=10;
    monitor_distance = 60; % in PPD
    transformExpName = ''; % transform ml & cont of stimuli of existing experiment, or leave blank

    if strcmp(exp_type, 'pink_noise')
        %         seed_energy_file='seed_energy_pn_gradbynorm';
        texture_params.type = 'pink_noise';
    else
        %         seed_energy_file='edge_strengths_bark';
        % for bark texture with portilla simoncelli:
        addpath(genpath('por_sim_tx_synth'))
        source_image_path = ['vislab-common/data/images/', exp_type, '.png'];
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
    load(['vislab-common/data/edge_powers/', exp_type, '.mat'], 'edgePowerBlockEdges');

    % find the widest span around the mean edge power,
    % such that 10 equal-width bins each have >=80 samples (to be safe; exp. needs
    % ~60 target samples in each bin).
%     dist_mean=mean(edge_powers(:,2));
%     dist_span=(max(edge_powers(:,2))-min(edge_powers(:,2)))/2;
%     while true
%         h=histcounts(edge_powers(:,2),linspace(dist_mean-dist_span,dist_mean+dist_span,nLevels+1));
%         if min(h)>80
%             break
%         else
%             dist_span=.9*dist_span;
%         end
%     end

%     edgePowerBlockEdges=linspace(dist_mean-dist_span,dist_mean+dist_span,nLevels+1);
%     edgePowerBlockEdges = linspace(min(edge_powers(:,2)),max(edge_powers(:,2)),nLevels+1);

    % for checking clipping in boundary ribbon region
    global bdry_ribbon;
    [~, ~, ~, bdry_ribbon] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);

    %% Session files
    %for iCondition = 1:nConditions
    ExpSettings = experiment.sessionSettings(exp_type, texture_params, luminance, contrast, ...
        bg_size, target_radius, edgePowerBlockEdges, monitor_distance, transformExpName);
%     if strcmp(exp_type,'pink_noise')
%         folderOut= ['exp_files/' exp_type '_L' num2str(luminance) '_C' num2str(contrast)];
%     else
    folderOut = ['exp_files/' exp_type];
%     end
    mkdir(folderOut);
    filePathOut = [folderOut '/exp_settings.mat'];
    save(filePathOut, 'ExpSettings');
    %end

    %% Subject experiment files
    %subjectStr = ['ad'; 'cw'; 'es'; 'wg'];
    nSubjects = size(subjectStr, 1);

    for iSubject = 1:nSubjects
        SubjectExpFile = experiment.subjectExperimentFile(ExpSettings);
        %             folderOut= ['exp_files/' exp_type '_L' num2str(luminance) '_C' num2str(contrast) '/subject_out'];
        folderOut = ['exp_files/' exp_type '/subject_out'];
        mkdir(folderOut);
        filePathOut = [folderOut '/' subjectStr(iSubject, :) '.mat'];
        save(filePathOut, 'SubjectExpFile');
    end
end
