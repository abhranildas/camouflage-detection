function setup()
% SETUP  Put camouflage-detection and its dependencies on the MATLAB path.
%   Run once per MATLAB session before using the code:
%       >> setup
%
%   Adds to the path:
%     * this repo (its +experiment, +general, +stats, +tests, +tinker, +vis
%       packages and root helper scripts)
%     * vision-commons (the shared lab library) -- a git submodule inside this
%       repo, or a sibling folder next to it (the lab's local dev layout)
%     * the vendored Portilla-Simoncelli texture-synthesis toolbox (por_sim_tx_synth)
%     * the lab-root +lib, which camouflage-detection still depends on heavily
%       (lib.stimulus, lib.target_mask, lib.edge_measures*, lib.gabor2D, ...). This
%       is a TEMPORARY dependency: the camouflage-domain code in root +lib should be
%       moved into this repo and the generic DV/optics code adopted from
%       vision-commons (see CLEANUP.md); root +lib is retired once all consumers
%       migrate. This repo is added AFTER root +lib so it shadows it on any collision.
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

    % --- shared lab library (vision-commons): a sibling folder next to this repo.
    %     If not found, try to clone it automatically (needs git + network). ---
    commons = locate_folder(repo_root, 'vision-commons');
    if isempty(commons)
        commons = fetch_commons(repo_root);
    end
    if isempty(commons)
        warning('camouflage_detection:setup:noCommons', ...
            ['vision-commons not found and could not be fetched automatically. ', ...
             'Clone it next to this repo:  git clone https://github.com/abhranildas/vision-commons']);
    else
        addpath(commons);                                    % exposes vislib.*, nat_stat_bayes.*
    end

    % --- lab-root +lib (TEMPORARY legacy dependency; see header + CLEANUP.md) ---
    root_parent = fullfile(repo_root, '..');
    if isfolder(fullfile(root_parent, '+lib'))
        addpath(root_parent);                                % exposes root lib.*
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
end

function folder = fetch_commons(repo_root)
% Auto-fetch vision-commons as a sibling folder (../vision-commons) by cloning it
% with git. Needs git on the PATH and network access; returns '' if the clone fails
% (the caller then warns with manual instructions).
    folder = '';
    target = fullfile(repo_root, '..', 'vision-commons');
    url = 'https://github.com/abhranildas/vision-commons.git';
    fprintf('vision-commons not found; trying to clone it to %s ...\n', target);
    [status, out] = system(sprintf('git clone "%s" "%s"', url, target));
    if status == 0 && isfolder(fullfile(target, '+vislib'))
        folder = target;
        fprintf('Cloned vision-commons.\n');
    else
        fprintf(2, 'Could not auto-fetch vision-commons (git missing or offline?).\n%s\n', out);
    end
end

function folder = locate_folder(repo_root, name)
% Find vision-commons as a sibling folder next to the repo (or inside it, if present).
    candidates = {fullfile(repo_root, name), fullfile(repo_root, '..', name)};
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
