function ok = smoke_test()
% SMOKE_TEST  Does this repo still run at all, from a clean state?
%   ok = smoke_test()
%   smoke_test          % prints a summary and errors if anything failed
%
%   Complements tools/golden_harness.m rather than repeating it. The golden
%   harness answers "did the numbers move?" and needs tools/golden_ref.mat to
%   answer anything at all. This answers "does the code still resolve, parse
%   and run?", needs no reference file, and is the check that would have
%   caught the argument-shift, dead-reference and never-called-path bugs
%   recorded as B2.1-B2.6 and B2.9 in docs/repo-cleanup.md.
%
%   Four checks, run in order (plan item S3.5):
%     1  Seed -> edge power. One fixed seed through lib.stimulus and lib.edge:
%        finite, right-shaped, self-consistent, reproducible on a re-run, and
%        actually different under a different seed.
%     2  Round trips. lib.create_pink_noise_square -> lib.whiten recovers the
%        white noise it started from; lib.stimulus's mask outputs match an
%        independent lib.target_mask call with the same arguments.
%     3  Minimal-argument call sweep. A curated set of side-effect-free
%        functions called with trivial arguments, asserting only that they
%        run and return something finite of the documented shape. No plotting,
%        no file writes, no rng('shuffle').
%     4  Package-resolution sweep. Every in-scope file resolves under its
%        package-qualified name and is not shadowed, and every
%        package-qualified reference written in in-scope source resolves to
%        something.
%
%   Checks 3 and 4 each carry a list of things that are known to be broken,
%   every entry citing its bug id in section 0.4 of the plan, and both apply
%   the same two-way rule: something broken that is not on the list fails the
%   check, and something on the list that has started working also fails it,
%   with a message saying to tick the bug and drop the entry. Both directions
%   fail on purpose -- the lists are only useful if they cannot silently
%   drift, in either direction.
%
%   Inputs
%     none.
%   Output
%     ok - true if every check passed. With no output argument requested, a
%          failure raises an error instead, so that
%          matlab -batch "addpath('tools'); smoke_test" exits nonzero.
%
%   Writes nothing to disk and opens no figures. Runtime is about a minute,
%   nearly all of it the parallel pool that lib.autocorr's parfor starts.
%
%   See also GOLDEN_HARNESS, CHECK_STAGE1, CANON.

    repo_root = fileparts(fileparts(mfilename('fullpath')));
    setup();
    cfg = config();

    state = struct('n_pass', 0, 'n_fail', 0, 'n_xfail', 0, 'n_skip', 0, 'failures', {{}});

    fprintf('\n=== smoke_test: %s ===\n', repo_root);

    has_stats = ~isempty(which('normcdf')) && ~isempty(which('knnsearch'));
    has_ipt = ~isempty(which('stdfilt')) && ~isempty(which('bwboundaries'));
    has_core = has_stats && has_ipt;

    state = check_seed_to_edge_power(state, cfg, has_core);
    state = check_round_trips(state, cfg, has_core);
    state = check_minimal_arg_calls(state, cfg, has_core);
    state = check_package_resolution(state, repo_root);

    fprintf('\n--- summary ---\n');
    fprintf('  passed  %d\n', state.n_pass);
    fprintf('  failed  %d\n', state.n_fail);
    fprintf('  xfail   %d  (broken as a recorded bug says it should be)\n', state.n_xfail);
    fprintf('  skipped %d\n', state.n_skip);
    for i_fail = 1:numel(state.failures)
        fprintf('  FAIL: %s\n', state.failures{i_fail});
    end
    ok = state.n_fail == 0;
    if ok
        fprintf('smoke_test: PASS\n\n');
    else
        fprintf('smoke_test: FAIL\n\n');
    end

    if nargout == 0 && ~ok
        clear ok
        error('smoke_test:failed', 'smoke_test: %d check(s) failed.', state.n_fail);
    end
end

% =========================================================================
% 1. Seed -> edge power
% =========================================================================

function state = check_seed_to_edge_power(state, cfg, has_core)
% One fixed seed all the way to an edge power, twice, plus a second seed.
    fprintf('\n[1] seed -> edge power\n');
    if ~has_core
        state = skip(state, 'seed->edge-power', 'needs Statistics and Image Processing toolboxes');
        return;
    end

    bg_size = 128;
    target_radius = 32;
    seed = 35096;

    rng(cfg.seed);
    stim_a = lib.stimulus('seed', seed, 'bg_size', bg_size, ...
        'target_radius', target_radius, 'ml_b', 0.5, 'cont_b', 0.15);

    % A different ambient rng state before the call must not matter:
    % lib.stimulus resets the stream itself from its seed argument.
    rng(cfg.seed + 1);
    stim_b = lib.stimulus('seed', seed, 'bg_size', bg_size, ...
        'target_radius', target_radius, 'ml_b', 0.5, 'cont_b', 0.15);

    rng(cfg.seed);
    stim_other = lib.stimulus('seed', seed + 1, 'bg_size', bg_size, ...
        'target_radius', target_radius, 'ml_b', 0.5, 'cont_b', 0.15);

    state = expect(state, 'stimulus shape', isequal(size(stim_a), [bg_size, bg_size]));
    state = expect(state, 'stimulus finite', all(isfinite(stim_a(:))));
    state = expect(state, 'stimulus reproducible from its seed', isequal(stim_a, stim_b));
    state = expect(state, 'stimulus depends on its seed', ~isequal(stim_a, stim_other));

    [edge_vector, edge_power, edge_field, theta_grid] = lib.edge(stim_a, 'mask', target_radius);
    [~, edge_power_again] = lib.edge(stim_a, 'mask', target_radius);

    state = expect(state, 'edge_vector shape', isequal(size(edge_vector), [1, 1e3]));
    state = expect(state, 'edge_vector finite', all(isfinite(edge_vector)));
    state = expect(state, 'edge_field shape', isequal(size(edge_field), [bg_size, bg_size]));
    state = expect(state, 'theta_grid spans (-pi, pi]', ...
        abs(theta_grid(end) - pi) < 1e-12 && theta_grid(1) > -pi);
    state = expect(state, 'edge_power is a finite positive scalar', ...
        isscalar(edge_power) && isfinite(edge_power) && edge_power > 0);
    % The header states edge_power is mean(edge_vector.^2). Outputs 3 and 4 of
    % this function already stopped meaning what a caller thought they meant
    % once (B1.5), so the documented relation between 1 and 2 is worth pinning.
    state = expect(state, 'edge_power == mean(edge_vector.^2)', ...
        rel_diff(edge_power, mean(edge_vector.^2)) < 1e-12);
    state = expect(state, 'edge power reproducible', isequal(edge_power, edge_power_again));

    fprintf('     edge power at seed %d: %.6g\n', seed, edge_power);
end

% =========================================================================
% 2. Round trips
% =========================================================================

function state = check_round_trips(state, cfg, has_core)
% Two properties that must hold between a producer and its inverse or its
% independent recomputation, checked without any stored reference.
    fprintf('\n[2] round trips\n');
    if ~has_core
        state = skip(state, 'round trips', 'needs Statistics and Image Processing toolboxes');
        return;
    end

    % --- pinken then whiten. lib.whiten divides by the same 1/f filter
    %     lib.create_pink_noise_square multiplied by, so at exponent 1 it is
    %     an exact inverse up to float error. ---
    rng(cfg.seed);
    [pink_noise, white_noise] = lib.create_pink_noise_square(64, 1);
    recovered = real(lib.whiten(pink_noise));
    state = expect(state, 'whiten inverts create_pink_noise_square', ...
        rel_diff(recovered, white_noise) < 1e-9);

    % --- lib.stimulus forwards its whole varargin to lib.target_mask
    %     (+lib/stimulus.m:251), so the mask outputs it returns must equal an
    %     independent call with the same arguments. This is the shape of the
    %     output-arity bugs B2.4 records: a caller destructuring one slot off
    %     would show up here as a mismatch rather than as silence. ---
    bg_size = 128;
    target_radius = 32;
    rng(cfg.seed);
    [~, ~, ~, mask, mask_edge, mask_normal, mask_strip] = lib.stimulus( ...
        'seed', 35096, 'bg_size', bg_size, 'target_radius', target_radius);
    [mask_ref, mask_edge_ref, mask_normal_ref, mask_strip_ref] = lib.target_mask( ...
        'seed', 35096, 'bg_size', bg_size, 'target_radius', target_radius);

    state = expect(state, 'stimulus mask == target_mask mask', isequal(mask, mask_ref));
    state = expect(state, 'stimulus mask_edge == target_mask mask_edge', ...
        isequal(mask_edge, mask_edge_ref));
    state = expect(state, 'stimulus mask_normal == target_mask mask_normal', ...
        isequal(mask_normal, mask_normal_ref));
    state = expect(state, 'stimulus mask_strip == target_mask mask_strip', ...
        isequal(mask_strip, mask_strip_ref));
    state = expect(state, 'mask radius matches the requested radius', ...
        abs(sqrt(nnz(mask)/pi) - target_radius) < 1);
end

% =========================================================================
% 3. Minimal-argument call sweep
% =========================================================================

function state = check_minimal_arg_calls(state, cfg, has_core)
% A curated subset of functions that are safe to call with trivial arguments:
% pure, cheap, no plotting, no file reads or writes, no rng('shuffle'). The
% assertion is deliberately weak -- it runs, and returns something finite of
% the documented shape -- because the point is to catch a signature that no
% longer accepts what its own header says it does.
%
% The last column is the id of the bug that makes an entry fail today. An
% entry with an id is expected to error, and counts as passed when it does;
% if it stops erroring, that is a failure telling you to tick the bug.
    fprintf('\n[3] minimal-argument call sweep\n');

    rng(cfg.seed);

    [x_grid, y_grid] = meshgrid(linspace(-1, 1, 33));
    gabor_params = struct('std', 0.1, 'sf', 4, 'ori', 0, 'phase', 0, 'pixperdeg', 60);
    dog_params = struct('stdCenter', 0.05, 'stdSurround', 0.1, 'pixperdeg', 60);
    % targetKey, not target_key: the field name belongs to the experiment
    % settings struct, which is zone-3 frozen (plan section 3.1.1).
    settings = struct('targetKey', {{'gabor', 'haar'}});
    obs_x = (1:20)';
    obs_y = 2*obs_x + 1;

    % {name, thunk, expected size ([] = unchecked), kind, known bug ('' = none)}
    cases = {
        'lib.deg2rad', @() lib.deg2rad(180), ...
            [1 1], 'numeric', ''
        'lib.monitor_deg_to_pix', @() lib.monitor_deg_to_pix(cat(3, 1, 1), [1920 1080], 60), ...
            [], 'numeric', ''
        'lib.create_averaging_filter', @() lib.create_averaging_filter([1 3]), ...
            [7 7], 'numeric', ''
        'lib.steerable_filter', @() lib.steerable_filter([1 3]), ...
            [], 'numeric', ''
        'lib.laplacian_of_gaussian_filter', @() lib.laplacian_of_gaussian_filter(1, 3), ...
            [], 'numeric', ''
        'lib.difference_of_gaussians_filter', @() lib.difference_of_gaussians_filter(1, 2, 3), ...
            [], 'numeric', ''
        'lib.cos_window_2d', @() lib.cos_window_2d(32), ...
            [32 32], 'numeric', ''
        'lib.cosd_radial', @() lib.cosd_radial(x_grid, y_grid, 2, 1, 0), ...
            [33 33], 'numeric', ''
        'lib.gabor_2d', @() lib.gabor_2d(gabor_params), ...
            [], 'numeric', ''
        'lib.haar_2d', @() lib.haar_2d(), ...
            [], 'numeric', ''
        'lib.spot_2d', @() lib.spot_2d(), ...
            [], 'numeric', ''
        'lib.difference_of_gaussians_2d', @() lib.difference_of_gaussians_2d(dog_params), ...
            [], 'numeric', ''
        'lib.radial_avg', @() lib.radial_avg(ones(33), 8), ...
            [1 8], 'numeric', ''
        'lib.fftconv2', @() lib.fftconv2(ones(16), ones(3)/9), ...
            [], 'numeric', ''
        'lib.maha_dist', @() lib.maha_dist([1 2], [0 0], eye(2)), ...
            [1 1], 'numeric', ''
        'lib.gauss_llr', @() lib.gauss_llr([1 2], [0 0], eye(2), [1 1], 2*eye(2)), ...
            [1 1], 'numeric', ''
        'lib.hyperexp_nll', @() lib.hyperexp_nll([0.5 1 2], [1 2]), ...
            [1 1], 'numeric', ''
        'lib.create_pink_noise_line', @() lib.create_pink_noise_line(64, 1), ...
            [], 'numeric', ''
        'lib.pairwise_stats', @() lib.pairwise_stats(obs_x, obs_y), ...
            [1 7], 'numeric', ''
        'lib.combine_pairwise_stats', ...
            @() lib.combine_pairwise_stats([10 10], [1 2], [2 4], [3 9], [2 5], [5 18], [1 1]), ...
            [1 1], 'numeric', ''
        'lib.mismatch_template', @() lib.mismatch_template(64, 16, 3, 0, pi/2), ...
            [], 'numeric', 'B2.9'
        'lib.sample_patch_coordinates', ...
            @() lib.sample_patch_coordinates([256 256], [32 32], 64, 4), ...
            [4 2], 'numeric', ''
        'lib.target_index_from_string', @() lib.target_index_from_string(settings, 'haar'), ...
            [1 1], 'numeric', ''
        'lib.edge_response', @() lib.edge_response([10 20], [0.1 0.2], 0.05, 1), ...
            [1 1], 'numeric', ''
        'lib.crop_image', @() lib.crop_image(reshape(1:4096, 64, 64), [32 32], 16), ...
            [16 16], 'numeric', ''
        'lib.embed_image_in_center', @() lib.embed_image_in_center(zeros(64), ones(8)), ...
            [64 64], 'numeric', 'B3.24'
        'lib.trace_contours', @() lib.trace_contours(disc_perimeter(32, 10)), ...
            [], 'any', ''
        'vislab.lib.watson_otf', @() vislab.lib.watson_otf(linspace(1, 30, 10), 4, 550), ...
            [], 'numeric', ''
        'lib.csf_fitted', @() lib.csf_fitted(linspace(0.5, 30, 10)), ...
            [1 10], 'numeric', ''
        'lib.edge_fit_cost', @() lib.edge_fit_cost(2, {[1 2 3], [0.5 1 1.5]}), ...
            [1 1], 'numeric', ''
        'experiment.gamma_correct', @() experiment.gamma_correct(linspace(0, 1, 16), 2.089, 8), ...
            [1 16], 'numeric', ''
        'experiment.generate_target_present_matrix', ...
            @() experiment.generate_target_present_matrix(10, 3, 2), ...
            [10 3 2], 'numeric', ''
        'experiment.analysis.psychometric_fun', ...
            @() experiment.analysis.psychometric_fun([0.1 0.2 0.3], 0, 0.3, 1.2, 0.1), ...
            [1 3], 'numeric', ''
        };

    % Entries that need a toolbox the core chain needs too.
    needs_core = {'lib.trace_contours', 'lib.crop_image', 'lib.sample_patch_coordinates', ...
        'lib.mismatch_template'};

    for i_case = 1:size(cases, 1)
        name = cases{i_case, 1};
        thunk = cases{i_case, 2};
        expected_size = cases{i_case, 3};
        kind = cases{i_case, 4};
        known_bug = cases{i_case, 5};
        if ~has_core && any(strcmp(name, needs_core))
            state = skip(state, name, 'needs Statistics and Image Processing toolboxes');
            continue;
        end
        errored = false;
        err_message = '';
        try
            value = thunk();
        catch err
            errored = true;
            err_message = err.message;
        end
        if ~isempty(known_bug)
            if errored
                state = xfail(state, name, known_bug, err_message);
            else
                state = fail(state, sprintf(['%s now runs -- %s looks fixed; tick it in ', ...
                    'docs/repo-cleanup.md and clear its id here'], name, known_bug));
            end
            continue;
        end
        if errored
            state = fail(state, sprintf('%s errored: %s', name, err_message));
            continue;
        end
        if isempty(value)
            state = fail(state, sprintf('%s returned empty', name));
            continue;
        end
        if ~is_all_finite(value, kind)
            state = fail(state, sprintf('%s returned a non-finite value', name));
            continue;
        end
        if ~isempty(expected_size) && ~isequal(size(value), expected_size)
            state = fail(state, sprintf('%s returned size %s, expected %s', name, ...
                mat2str(size(value)), mat2str(expected_size)));
            continue;
        end
        state = pass(state, name);
    end
end

% =========================================================================
% 4. Package-resolution sweep
% =========================================================================

function state = check_package_resolution(state, repo_root)
% (a) every in-scope file resolves under its own package-qualified name, to
%     itself, without being shadowed; and
% (b) every package-qualified reference written in in-scope source resolves
%     to something -- the check that finds a call to a function that was
%     renamed, never existed, or lives in a package that is not on the path.
    fprintf('\n[4] package-resolution sweep\n');

    [files, names, unreachable] = in_scope_files(repo_root);
    fprintf('     %d in-scope files with a callable name\n', numel(names));

    n_resolution_fail = 0;
    for i_file = 1:numel(names)
        resolved = which(names{i_file});
        if isempty(resolved)
            state = fail(state, sprintf('%s does not resolve', names{i_file}));
            n_resolution_fail = n_resolution_fail + 1;
            continue;
        end
        if ~same_file(resolved, files{i_file})
            state = fail(state, sprintf('%s resolves to %s, not %s', ...
                names{i_file}, resolved, files{i_file}));
            n_resolution_fail = n_resolution_fail + 1;
            continue;
        end
        all_hits = which(names{i_file}, '-all');
        if iscell(all_hits) && numel(all_hits) > 1
            % Ours still wins, so this is a hazard rather than a break.
            fprintf('     NOTE: %s is shadowed by %d other file(s)\n', ...
                names{i_file}, numel(all_hits) - 1);
        end
    end
    if n_resolution_fail == 0
        state = pass(state, sprintf('all %d in-scope names resolve to their own file', ...
            numel(names)));
    end

    for i_dir = 1:numel(unreachable)
        fprintf('     NOTE: %s is a non-package subfolder of a package, so its files\n', ...
            unreachable{i_dir});
        fprintf('           are not on the path under any qualified name\n');
    end

    % --- (b) references written in the source ---
    % Known not to resolve, each with the bug that records it. An unlisted
    % dead reference fails; a listed one that has come back to life also
    % fails, so that fixing the bug forces this list to be updated.
    known_dead = {
        'analysis.computeThresholdInBin',                   'B2.9'
        'analysis.compute_dPrime_pCorrect',                 'B2.9'
        'analysis.compute_template_response_sigma',         'B2.9'
        'experiment.analysis.computeThreshold_new_edge',    'B2.9'
        'experiment.show_image',                            'B2.9'
        'lib.circular_mask',                                'B2.9'
        'lib.compute_dPrime_pCorrect',                      'B2.9'
        'lib.edge_vector',                                  'B2.9'
        'lib.new_edge',                                     'B2.9'
        'lib.pink_noise_2d',                                'B2.9'
        'lib.whiten_pink_noise_square',                     'B2.9'
        'nm.analysis.fitPsychometric',                      'B2.9'
        'stats.computeSceneSimilarityAmplitude',            'B2.9'
        'tinker.filter',                                    'B2.9'
        };

    refs = package_references(files);
    fprintf('     %d distinct package-qualified references in in-scope source\n', numel(refs));

    dead = {};
    for i_ref = 1:numel(refs)
        if isempty(which(refs{i_ref}))
            dead{end+1} = refs{i_ref}; %#ok<AGROW>
        end
    end

    unexpected = setdiff(dead, known_dead(:, 1));
    % Only a listed reference that is still written somewhere can be said to
    % have come back to life; one that has vanished from the source entirely
    % is a different thing, and gets a note rather than a failure.
    revived = intersect(setdiff(known_dead(:, 1), dead), refs);
    unreferenced = setdiff(known_dead(:, 1), refs);

    for i_ref = 1:numel(unexpected)
        state = fail(state, sprintf('reference %s resolves to nothing, and is not a known bug', ...
            unexpected{i_ref}));
    end
    for i_ref = 1:numel(revived)
        row = strcmp(known_dead(:, 1), revived{i_ref});
        state = fail(state, sprintf(['reference %s now resolves -- %s looks fixed; tick it in ', ...
            'docs/repo-cleanup.md and drop it from known_dead here'], ...
            revived{i_ref}, known_dead{row, 2}));
    end
    for i_ref = 1:numel(unreferenced)
        fprintf('     NOTE: %s is listed as known-dead but is no longer written anywhere\n', ...
            unreferenced{i_ref});
        fprintf('           this scan can see -- either the call site is gone, or the scan\n');
        fprintf('           missed it\n');
    end
    if isempty(unexpected) && isempty(revived)
        state = pass(state, sprintf(['every package-qualified reference resolves, except the ', ...
            '%d known dead ones'], size(known_dead, 1) - numel(unreferenced)));
    end
end

function [files, names, unreachable] = in_scope_files(repo_root)
% Every in-scope .m file with a callable, package-qualified name, under the
% plan's scope convention: no por_sim_tx_synth/, no `_`-prefixed dead file,
% no all-dead +stats/, no Contents.m (documentation, not a function).
    packages = {'+lib', '+general', '+experiment', '+vis', '+tests', '+tinker'};
    root_files = {'config.m', 'setup.m', 'edge_power_demo.m', 'scratch.m', 'test_erlang.m'};

    files = {};
    names = {};
    unreachable = {};
    for i_pkg = 1:numel(packages)
        [files, names, unreachable] = walk_package( ...
            fullfile(repo_root, packages{i_pkg}), packages{i_pkg}(2:end), ...
            files, names, unreachable);
    end
    for i_file = 1:numel(root_files)
        full_path = fullfile(repo_root, root_files{i_file});
        if isfile(full_path)
            files{end+1} = full_path; %#ok<AGROW>
            names{end+1} = root_files{i_file}(1:end-2); %#ok<AGROW>
        end
    end
end

function [files, names, unreachable] = walk_package(folder, prefix, files, names, unreachable)
    entries = dir(folder);
    for i_entry = 1:numel(entries)
        entry = entries(i_entry);
        if strcmp(entry.name, '.') || strcmp(entry.name, '..')
            continue;
        end
        if entry.isdir
            if entry.name(1) == '+'
                [files, names, unreachable] = walk_package( ...
                    fullfile(folder, entry.name), [prefix, '.', entry.name(2:end)], ...
                    files, names, unreachable);
            elseif entry.name(1) ~= '@'
                unreachable{end+1} = fullfile(folder, entry.name); %#ok<AGROW>
            end
            continue;
        end
        if numel(entry.name) < 3 || ~strcmp(entry.name(end-1:end), '.m')
            continue;
        end
        if entry.name(1) == '_' || strcmp(entry.name, 'Contents.m')
            continue;
        end
        files{end+1} = fullfile(folder, entry.name); %#ok<AGROW>
        names{end+1} = [prefix, '.', entry.name(1:end-2)]; %#ok<AGROW>
    end
end

function refs = package_references(files)
% Distinct package-qualified references appearing as calls or function handles
% in the given files. Whole-line comments are dropped first, so a `See also`
% line or a commented-out call is not mistaken for a live reference; a
% reference must then be followed by '(' or preceded by '@' to count.
    % The subpackage names analysis and main are in the list because writing
    % them unqualified is exactly the mistake B2.9 records: from inside +vis/,
    % analysis.foo would need a top-level +analysis, and there is none.
    prefixes = 'lib|general|experiment|vis|tests|tinker|stats|vislab|nm|analysis|main';
    pattern = ['(?<![\w.])(' prefixes ')(\.[A-Za-z]\w*)+'];
    refs = {};
    for i_file = 1:numel(files)
        lines = readlines(files{i_file});
        for i_line = 1:numel(lines)
            line = strtrim(lines(i_line));
            if strlength(line) == 0 || startsWith(line, '%')
                continue;
            end
            [starts, stops] = regexp(char(line), pattern, 'start', 'end');
            for i_hit = 1:numel(starts)
                token = extractBetween(line, starts(i_hit), stops(i_hit));
                after = char(extractAfter(line, stops(i_hit)));
                before = char(extractBetween(line, max(1, starts(i_hit)-1), ...
                    max(1, starts(i_hit)-1)));
                is_call = ~isempty(after) && after(1) == '(';
                is_handle = starts(i_hit) > 1 && before == '@';
                if is_call || is_handle
                    refs{end+1} = char(token); %#ok<AGROW>
                end
            end
        end
    end
    refs = unique(refs);
end

% =========================================================================
% helpers
% =========================================================================

function state = expect(state, label, condition)
    if condition
        state = pass(state, label);
    else
        state = fail(state, label);
    end
end

function state = pass(state, label)
    state.n_pass = state.n_pass + 1;
    fprintf('     ok   %s\n', label);
end

function state = fail(state, label)
    state.n_fail = state.n_fail + 1;
    state.failures{end+1} = label;
    fprintf('     FAIL %s\n', label);
end

function state = xfail(state, label, bug_id, message)
% An entry that is expected to fail, because a recorded bug says so.
    state.n_xfail = state.n_xfail + 1;
    fprintf('     xfail %s (%s: %s)\n', label, bug_id, one_line(message));
end

function state = skip(state, label, why)
    state.n_skip = state.n_skip + 1;
    fprintf('     skip %s (%s)\n', label, why);
end

function text = one_line(text)
    text = strtrim(regexprep(text, '\s+', ' '));
    if numel(text) > 70
        text = [text(1:67), '...'];
    end
end

function d = rel_diff(a, b)
% Largest elementwise difference, relative to the scale of b.
    scale = max(1e-12, max(abs(b(:))));
    d = max(abs(a(:) - b(:)))/scale;
end

function tf = is_all_finite(value, kind)
    if strcmp(kind, 'any') || iscell(value) || ischar(value) || islogical(value) ...
            || isstruct(value)
        tf = true;
        return;
    end
    tf = all(isfinite(value(:)));
end

function tf = same_file(a, b)
% Compare two paths as the filesystem would: case-insensitively on Windows,
% and after resolving '..' segments.
    a = char(java.io.File(a).getCanonicalPath());
    b = char(java.io.File(b).getCanonicalPath());
    if ispc
        tf = strcmpi(a, b);
    else
        tf = strcmp(a, b);
    end
end

function perimeter = disc_perimeter(image_size, radius)
% A ring of true pixels, as a cheap input for lib.trace_contours.
    [x_grid, y_grid] = meshgrid(1:image_size);
    center = image_size/2;
    distance = hypot(x_grid - center, y_grid - center);
    perimeter = abs(distance - radius) < 0.7;
end
