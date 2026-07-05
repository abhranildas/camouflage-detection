function setup()
% SETUP  Put camouflage-detection and its dependencies on the MATLAB path.
%   Run once per MATLAB session before using the code:
%       >> setup
%
%   Adds to the path:
%     * this repo (its +lib, +experiment, +general, +stats, +tests, +tinker, +vis
%       packages and root helper scripts). +lib holds the camouflage-domain helpers
%       (lib.stimulus, lib.target_mask, lib.edge_measures*, lib.gabor2D, ...),
%       extracted from the old shared lab-root +lib so this repo is self-contained
%       (mirrors texture-segmentation's own +lib).
%     * vislab (the shared lab library) -- the +vislab package inside the sibling
%       vislab-common repo (the lab's local dev layout). Generic optics live there
%       now: lib.otf_filter was repointed to vislab.lib.otf_filter.
%     * the vendored Portilla-Simoncelli texture-synthesis toolbox (por_sim_tx_synth)
%
%   Also VERIFIES/self-heals the required MATLAB add-on toolboxes (installed via
%   the Add-On Explorer / File Exchange -- NOT bundled or fetched as source):
%     * Integrate and Classify Normal Distributions  (classify_normals, quad2fun)
%         https://github.com/abhranildas/IntClassNorm
%     * Generalized chi-square distribution  (gx2*, used by the above)
%         https://github.com/abhranildas/gx2
%
%   (Mirrors setup.m in the sibling texture-learning / texture-segmentation repos.)

    repo_root = fileparts(mfilename('fullpath'));

    % --- shared lab library (vislab): a sibling folder next to this repo.
    %     If not found, try to clone it automatically (needs git + network). ---
    commons = locate_folder(repo_root, '+vislab');
    if isempty(commons)
        commons = fetch_commons(repo_root);
    end
    if isempty(commons)
        warning('camouflage_detection:setup:noCommons', ...
            ['vislab-common not found and could not be fetched automatically. ', ...
             'Clone it next to this repo:  git clone https://github.com/abhranildas/vislab-common']);
    else
        addpath(fileparts(commons));                                    % exposes vislab.lib.*, vislab.nat_stat_bayes.*
    end

    % --- vendored Portilla-Simoncelli texture synthesis ---
    por_sim = fullfile(repo_root, 'por_sim_tx_synth');
    if isfolder(por_sim)
        addpath(genpath(por_sim));
    end

    % --- this repo (added last => highest priority on any collision) ---
    addpath(repo_root);                                      % experiment/general/stats/tests/tinker/vis + root scripts

    % --- installed add-on toolboxes (self-heal headless path) ---
    ensure_addon_on_path('gx2cdf', 'Generalized chi-square distribution*', ...
        'Generalized chi-square distribution (gx2)', 'https://github.com/abhranildas/gx2');
    ensure_addon_on_path('classify_normals', 'Integrate and Classify Normal Distributions*', ...
        'Integrate and Classify Normal Distributions', 'https://github.com/abhranildas/IntClassNorm');

    % --- shared data store: vislab-common/data (~23 GB, obtained manually) ---
    if ~isfolder(fullfile(repo_root, '..', 'vislab-common', 'data'))
        warning('camouflage_detection:setup:noData', ...
            ['vislab-common/data not found next to this repo. It is the large (~23 GB) shared data store ', ...
             '(natural images + textures); obtain it separately and place it in vislab-common/data ', ...
             '(see README). Code that reads it will fail until then.']);
    end
end

function folder = fetch_commons(repo_root)
% Auto-fetch the shared library by cloning the vislab-common repo as a sibling
% (../vislab-common); the +vislab package lives inside it. Needs git on the PATH
% and network access; returns '' if the clone fails (caller then warns).
    folder = '';
    repo_dir = fullfile(repo_root, '..', 'vislab-common');
    url = 'https://github.com/abhranildas/vislab-common.git';
    fprintf('vislab-common not found; trying to clone it to %s ...\n', repo_dir);
    [status, out] = system(sprintf('git clone "%s" "%s"', url, repo_dir));
    target = fullfile(repo_dir, '+vislab');
    if status == 0 && isfolder(fullfile(target, '+lib'))
        folder = target;
        fprintf('Cloned vislab-common.\n');
    else
        fprintf(2, 'Could not auto-fetch vislab-common (git missing or offline?).\n%s\n', out);
    end
end

function folder = locate_folder(repo_root, name)
% Find the +vislab package: inside the sibling vislab-common repo (canonical),
% else as a sibling of / inside this repo (older dev layouts).
    candidates = {fullfile(repo_root, '..', 'vislab-common', name), ...
                  fullfile(repo_root, name), ...
                  fullfile(repo_root, '..', name)};
    folder = '';
    for i = 1:numel(candidates)
        if isfolder(candidates{i})
            folder = candidates{i};
            return;
        end
    end
end

function ensure_addon_on_path(probe_function, folder_pattern, toolbox_name, url)
% Ensure an INSTALLED add-on toolbox's functions are on the path.
%   If PROBE_FUNCTION already resolves, do nothing. Otherwise find the installed
%   add-on folder (matching FOLDER_PATTERN under the add-ons install directory)
%   and add it -- this uses the installed add-on, never any lab-local source.
%   Warn with install guidance only if it still cannot be found (not installed).
    if exist(probe_function, 'file') ~= 0
        return;
    end
    tb_dir = addons_toolboxes_dir();
    if ~isempty(tb_dir)
        hits = dir(fullfile(tb_dir, folder_pattern));
        for i = 1:numel(hits)
            if hits(i).isdir
                addpath(genpath(fullfile(tb_dir, hits(i).name)));
            end
        end
    end
    if exist(probe_function, 'file') == 0
        warning('camouflage_detection:setup:missingToolbox', ...
            ['Required MATLAB toolbox "%s" not found (cannot find %s). Install it via the ', ...
             'MATLAB Add-On Explorer / File Exchange: %s'], toolbox_name, probe_function, url);
    end
end

function d = addons_toolboxes_dir()
% Best-effort path to the "<...>/MATLAB Add-Ons/Toolboxes" install directory,
% without hardcoding a username. Try the add-ons install-folder setting first,
% then fall back to the parent folder of an already-resolvable add-on function.
    d = '';
    try
        root = settings().matlab.addons.InstallationFolder.ActiveValue;
        cand = fullfile(root, 'Toolboxes');
        if isfolder(cand), d = cand; return; end
        if isfolder(root),  d = root;  return; end
    catch
        % settings tree not available in this release -- use the fallback below
    end
    for probe = {'gx2cdf', 'gx2pdf', 'gx2inv'}
        w = which(probe{1});
        if ~isempty(w)
            d = fileparts(fileparts(w));
            return;
        end
    end
end
