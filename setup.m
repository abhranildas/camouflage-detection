function setup()
% SETUP  Put camouflage-detection and its dependencies on the MATLAB path.
%   SETUP()
%
%   Run once per MATLAB session before using any of this code:
%       >> setup
%
%   Adds to the path:
%     * this repo -- its +lib, +experiment, +general, +stats, +tests, +tinker
%       and +vis packages, plus the root helper scripts. +lib holds the
%       camouflage-domain helpers (lib.stimulus, lib.target_mask,
%       lib.edge_measures*, lib.gabor_2d, ...), extracted from the old shared
%       lab-root +lib so this repo is self-contained, mirroring
%       texture-segmentation's own +lib.
%     * vislab, the shared lab library -- the +vislab package inside the
%       sibling vislab-common repo (the lab's local dev layout). Generic
%       optics live there now: lib.otf_filter was repointed to
%       vislab.lib.otf_filter. If vislab-common is missing, this tries to
%       clone it; if that fails it warns rather than erroring.
%     * the vendored Portilla-Simoncelli texture-synthesis toolbox
%       (por_sim_tx_synth).
%
%   Also verifies, and self-heals the path for, the required MATLAB add-on
%   toolboxes. These are installed through the Add-On Explorer / File
%   Exchange, never bundled or fetched as source:
%     * Integrate and Classify Normal Distributions (classify_normals,
%       quad2fun) -- https://github.com/abhranildas/IntClassNorm
%     * Generalized chi-square distribution (gx2*, used by the above)
%       -- https://github.com/abhranildas/gx2
%
%   Finally, warns if the ~23 GB shared data store (vislab-common/data) is
%   not next to this repo; it is obtained manually, not by this function.
%
%   Inputs
%     none.
%
%   Output
%     none (side effect: adds folders to the MATLAB path for this session).
%
%   Mirrors setup.m in the sibling texture-learning / texture-segmentation
%   repos.
%
%   See also config, addpath, genpath.

    repo_root = fileparts(mfilename('fullpath'));

    % --- shared lab library (vislab): a sibling folder next to this repo.
    %     If not found, try to clone it automatically (needs git + network). ---
    vislab_dir = locate_folder(repo_root, '+vislab');
    if isempty(vislab_dir)
        vislab_dir = fetch_vislab_common(repo_root);
    end
    if isempty(vislab_dir)
        warning('camouflage_detection:setup:noCommons', ...
            ['vislab-common not found and could not be fetched automatically. ', ...
            'Clone it next to this repo:  git clone https://github.com/abhranildas/vislab-common']);
    else
        % Add the parent folder, so +vislab is seen as a package. This is what
        % exposes vislab.lib.* and vislab.nat_stat_bayes.*.
        addpath(fileparts(vislab_dir));
    end

    % --- vendored Portilla-Simoncelli texture synthesis ---
    por_sim = fullfile(repo_root, 'por_sim_tx_synth');
    if isfolder(por_sim)
        addpath(genpath(por_sim));
    end

    % --- this repo (added last => highest priority on any collision) ---
    addpath(repo_root);

    % --- installed add-on toolboxes (self-heal headless path) ---
    ensure_addon_on_path('gx2cdf', 'Generalized chi-square distribution*', ...
        'Generalized chi-square distribution (gx2)', 'https://github.com/abhranildas/gx2');
    ensure_addon_on_path('classify_normals', 'Integrate and Classify Normal Distributions*', ...
        'Integrate and Classify Normal Distributions', ...
        'https://github.com/abhranildas/IntClassNorm');

    % --- shared data store: vislab-common/data (~23 GB, obtained manually) ---
    if ~isfolder(fullfile(repo_root, '..', 'vislab-common', 'data'))
        warning('camouflage_detection:setup:noData', ...
            ['vislab-common/data not found next to this repo. It is the large (~23 GB) shared data store ', ...
            '(natural images + textures); obtain it separately and place it in vislab-common/data ', ...
            '(see README). Code that reads it will fail until then.']);
    end
end

function folder = fetch_vislab_common(repo_root)
% Clone the shared library as a sibling of this repo (../vislab-common); the
% +vislab package lives inside it.
%
%   Inputs
%     repo_root - this repo's root directory.
%
%   Output
%     folder - path to the cloned +vislab package folder, or '' if the clone
%              failed (no git on the PATH, or no network); the caller warns.
    folder = '';
    repo_dir = fullfile(repo_root, '..', 'vislab-common');
    url = 'https://github.com/abhranildas/vislab-common.git';
    fprintf('vislab-common not found; trying to clone it to %s ...\n', repo_dir);
    [status, cmd_output] = system(sprintf('git clone "%s" "%s"', url, repo_dir));
    vislab_package = fullfile(repo_dir, '+vislab');
    if status == 0 && isfolder(fullfile(vislab_package, '+lib'))
        folder = vislab_package;
        fprintf('Cloned vislab-common.\n');
    else
        fprintf(2, 'Could not auto-fetch vislab-common (git missing or offline?).\n%s\n', ...
            cmd_output);
    end
end

function folder = locate_folder(repo_root, name)
% Find a folder across the layouts this repo has been used in: inside the
% sibling vislab-common repo (canonical), else as a sibling of, or inside,
% this repo (older dev layouts).
%
%   Inputs
%     repo_root - this repo's root directory.
%     name      - folder name to look for, e.g. '+vislab'.
%
%   Output
%     folder - path to the first candidate that exists, or '' if none does.
    candidates = {fullfile(repo_root, '..', 'vislab-common', name), ...
        fullfile(repo_root, name), ...
        fullfile(repo_root, '..', name)};
    folder = '';
    for i_folder = 1:numel(candidates)
        if isfolder(candidates{i_folder})
            folder = candidates{i_folder};
            return;
        end
    end
end

function ensure_addon_on_path(probe_function, folder_pattern, toolbox_name, url)
% Ensure an installed add-on toolbox's functions are on the path.
%   If probe_function already resolves, do nothing. Otherwise find the
%   installed add-on folder matching folder_pattern under the add-ons install
%   directory and add it -- this uses the installed add-on, never any
%   lab-local source. Warn with install guidance only if it still cannot be
%   found, i.e. it is not installed at all.
%
%   Inputs
%     probe_function - name of a function the toolbox provides, used to test
%                      whether the toolbox already resolves.
%     folder_pattern - wildcard pattern matching the toolbox's install folder.
%     toolbox_name   - display name, used in the warning text.
%     url            - where to get the toolbox, used in the warning text.
%
%   Output
%     none (side effect: may add folders to the MATLAB path).
    if exist(probe_function, 'file') ~= 0
        return;
    end
    toolbox_root = addons_toolboxes_dir();
    if ~isempty(toolbox_root)
        hits = dir(fullfile(toolbox_root, folder_pattern));
        for i_folder = 1:numel(hits)
            if hits(i_folder).isdir
                addpath(genpath(fullfile(toolbox_root, hits(i_folder).name)));
            end
        end
    end
    if exist(probe_function, 'file') == 0
        warning('camouflage_detection:setup:missingToolbox', ...
            ['Required MATLAB toolbox "%s" not found (cannot find %s). Install it via the ', ...
            'MATLAB Add-On Explorer / File Exchange: %s'], toolbox_name, probe_function, url);
    end
end

function toolboxes_dir = addons_toolboxes_dir()
% Best-effort path to the "<...>/MATLAB Add-Ons/Toolboxes" install directory,
% without hardcoding a username. Try the add-ons install-folder setting first,
% then fall back to the parent folder of an already-resolvable add-on function.
%
%   Inputs
%     none.
%
%   Output
%     toolboxes_dir - the install directory, or '' if it cannot be found.
    toolboxes_dir = '';
    try
        install_root = settings().matlab.addons.InstallationFolder.ActiveValue;
        candidate = fullfile(install_root, 'Toolboxes');
        if isfolder(candidate)
            toolboxes_dir = candidate;
            return;
        end
        if isfolder(install_root)
            toolboxes_dir = install_root;
            return;
        end
    catch
        % settings tree not available in this release -- use the fallback below
    end
    for probe_name = {'gx2cdf', 'gx2pdf', 'gx2inv'}
        which_path = which(probe_name{1});
        if ~isempty(which_path)
            toolboxes_dir = fileparts(fileparts(which_path));
            return;
        end
    end
end
