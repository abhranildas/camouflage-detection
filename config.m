function cfg = config()
% CONFIG  Central configuration for the camouflage-detection project.
%   cfg = config()  returns a struct of data paths and shared physical/optical
%   constants. Pass it to code that needs paths or parameters instead of relying
%   on hardcoded absolute paths or the ambient MATLAB path.
%
%   EDIT cfg.paths.data_root below if the shared global_data store is not a
%   sibling of this repo.
%
%   (Mirrors the config.m convention in the sibling texture-learning /
%   texture-segmentation repos so the three projects share one layout.)

    repo_root = fileparts(mfilename('fullpath'));

    % --- data locations ---
    cfg.paths.repo_root      = repo_root;
    cfg.paths.data_root      = fullfile(repo_root, '..', 'global_data');   % shared lab data store
    cfg.paths.natural_images = fullfile(cfg.paths.data_root, 'CPS natural images');
    cfg.paths.textures       = fullfile(cfg.paths.data_root, 'textures');
    cfg.paths.images         = fullfile(cfg.paths.data_root, 'images');      % source images for texture synthesis
    cfg.paths.edge_powers    = fullfile(cfg.paths.data_root, 'edge_powers');  % deployed per-texture edge-power bins
    cfg.paths.exp_files      = fullfile(repo_root, 'exp_files');             % per-experiment settings + subject output
    cfg.paths.data           = fullfile(repo_root, 'data');                 % analysis artifacts
    cfg.paths.por_sim        = fullfile(repo_root, 'por_sim_tx_synth');     % vendored Portilla-Simoncelli synthesis

    % --- eye optics (Watson OTF); shared lab constants ---
    cfg.optics.ppd            = 60;      % pixels per degree
    cfg.optics.pupil_diameter = 4;       % mm
    cfg.optics.wavelength     = 550;     % nm  (note: some legacy scripts passed 555 -- see CLEANUP.md)

    % --- luminance/contrast normalization ---
    cfg.norm.target_mean     = 128;
    cfg.norm.target_contrast = 0.25;

    % --- reproducibility ---
    cfg.seed = 0;
end
