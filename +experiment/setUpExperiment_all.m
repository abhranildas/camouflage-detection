function setUpExperiment_all(subjectStr)
% SETUPEXPERIMENT_ALL  Set up the all-textures variant of the camouflage experiment.
%   experiment.setUpExperiment_all(subjectStr)
%
%   Variant of experiment.setUpExperiment in which the level is not an edge-
%   power band but a texture: every texture in exp_files/all/texture_list.mat
%   contributes the same number of trials, which are then shuffled into the
%   usual trial/level/session layout. Nothing else about the experiment
%   changes. It takes no exp_type, because the experiment name is 'all'.
%
%   Inputs
%     subjectStr - nSubjects x 2 char array of subject initials, one row per
%                  subject, each becoming a subject_out/<initials>.mat file.
%
%   Output
%     none (side effects: creates exp_files/all/exp_settings.mat and
%     exp_files/all/subject_out/<initials>.mat for each subject).
%
%   Fixed here rather than passed in: luminance 0.5 and contrast 0.15
%   (normalised / dimensionless), a 256-pixel stimulus with a 64-pixel target
%   radius, and 60 pixels per degree.
%
%   This is one of five near-duplicate setUpExperiment variants; S3.3 collapses
%   them into one function taking a level-variable specification.
%
%   See also experiment.SETUPEXPERIMENT, experiment.SESSIONSETTINGS_ALL,
%   experiment.SUBJECTEXPERIMENTFILE.

    % Portilla-Simoncelli texture
    addpath(genpath('por_sim_tx_synth'))

    luminance = 0.5;
    contrast = 0.15;
    bg_size = 256; % in px
    target_radius = 64; % in px
%     nLevels=10;
    ppd = 60; % in PPD

    %% Session files
    ExpSettings = experiment.sessionSettings_all(luminance, contrast, bg_size, ...
        target_radius, ppd);
    folderOut = 'exp_files/all';
    mkdir(folderOut);
    filePathOut = [folderOut '/exp_settings.mat'];
    save(filePathOut, 'ExpSettings');

    %% Subject experiment files
    %subjectStr = ['ad'; 'cw'; 'es'; 'wg'];
    nSubjects = size(subjectStr, 1);

    for iSubject = 1:nSubjects
        SubjectExpFile = experiment.subjectExperimentFile(ExpSettings);
        folderOut = 'exp_files/all/subject_out';
        mkdir(folderOut);
        filePathOut = [folderOut '/' subjectStr(iSubject, :) '.mat'];
        save(filePathOut, 'SubjectExpFile');
    end
end
