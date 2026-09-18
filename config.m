function cfg = config()
% CONFIG  Data paths and shared physical constants for the camouflage project.
%   cfg = CONFIG()
%
%   One place to look up a path or a physical constant. Pass the returned
%   struct to code that needs one, instead of hardcoding an absolute path or
%   relying on whatever happens to be on the ambient MATLAB path.
%
%   Edit cfg.paths.data_root below if the shared data store
%   (vislab-common/data) does not sit next to this repo.
%
%   Inputs
%     none.
%
%   Output
%     cfg - struct with these fields:
%           paths.repo_root      - this repo's root directory.
%           paths.data_root      - shared lab data store (~23 GB), a sibling
%                                  of this repo. All paths below hang off it.
%           paths.natural_images - CPS calibrated natural image database.
%           paths.textures       - synthesized texture database.
%           paths.images         - source images for texture synthesis.
%           paths.edge_powers    - deployed per-texture edge-power bins.
%           paths.exp_files      - per-experiment settings and subject output.
%           paths.data           - analysis artifacts written by this repo.
%           paths.por_sim        - vendored Portilla-Simoncelli synthesis code.
%           optics.ppd            - sampling density, pixels per degree.
%           optics.pupil_diameter - pupil diameter, mm.
%           optics.wavelength     - light wavelength, nm.
%           norm.target_mean      - target mean grey level, image units
%                                   (128 assumes an 8-bit 0-255 range).
%           norm.target_contrast  - target RMS contrast, dimensionless.
%           seed                  - integer seed for rng().
%
%   Mirrors the config.m convention in the sibling texture-learning /
%   texture-segmentation repos, so the three projects share one layout.
%
%   See also setup, rng.

    repo_root = fileparts(mfilename('fullpath'));

    % --- data locations ---
    cfg.paths.repo_root = repo_root;
    cfg.paths.data_root = fullfile(repo_root, '..', 'vislab-common', 'data');
    cfg.paths.natural_images = fullfile(cfg.paths.data_root, 'CPS natural images');
    cfg.paths.textures = fullfile(cfg.paths.data_root, 'textures');
    cfg.paths.images = fullfile(cfg.paths.data_root, 'images');
    cfg.paths.edge_powers = fullfile(cfg.paths.data_root, 'edge_powers');
    cfg.paths.exp_files = fullfile(repo_root, 'exp_files');
    cfg.paths.data = fullfile(repo_root, 'data');
    cfg.paths.por_sim = fullfile(repo_root, 'por_sim_tx_synth');

    % --- eye optics (Watson OTF); shared lab constants ---
    cfg.optics.ppd = 60;
    cfg.optics.pupil_diameter = 4;
    % Some legacy scripts pass 555 nm instead -- see CLEANUP.md.
    cfg.optics.wavelength = 550;

    % --- luminance/contrast normalization ---
    cfg.norm.target_mean = 128;
    cfg.norm.target_contrast = 0.25;

    % --- reproducibility ---
    cfg.seed = 0;
end
