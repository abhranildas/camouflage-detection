function golden = golden_harness(mode, golden_file)
% GOLDEN_HARNESS  Capture or replay golden outputs for Stage-2 readability checks.
%   golden = golden_harness('capture', golden_file)
%   golden = golden_harness('replay', golden_file)
%
%   Calls this repo's callable entry points directly -- never through
%   edge_power_demo.m or any other top-level driver -- under an explicit
%   rng(cfg.seed), and either saves their reduced outputs to GOLDEN_FILE
%   ('capture') or reloads GOLDEN_FILE and asserts isequal against a fresh
%   run ('replay').
%
%   Entry points, by tranche (docs/repo-cleanup.md sections 2 and 4.1.2):
%     tranche 1  lib.stimulus, lib.edge, lib.edge_vector_ideal,
%                lib.edge_measures_ideal, lib.steerable_grad,
%                lib.steerable_filter, lib.local_sd, lib.target_mask,
%                lib.compute_p_clipped
%     tranche 3  lib.create_pink_noise_square, lib.whiten, lib.autocorr,
%                lib.csf_fitted
%     tranche 5  experiment.analysis.psychometricFun,
%                experiment.analysis.computeNegLogLikelihood,
%                experiment.analysis.fitPsychometric
%
%   Not covered, by decision recorded in plan sections 2 and 4.2: every file
%   in +general/, +tinker/, +vis/, +tests/, +experiment/+main/, the
%   +experiment/ top level, and the non-psychometric half of
%   +experiment/+analysis/. Those are top-level scripts with no callable
%   entry point, are Psychtoolbox/display bound, write into exp_files/, or
%   need loaded session .mat files. Restructuring any of them into callable
%   functions is itself Stage 3 (S3.7), so their Stage-2 edits are verified
%   by pattern check only.
%
% Inputs
%   mode         'capture' or 'replay', char
%   golden_file  path to a .mat file to write to / read from, char
% Output
%   golden  struct of reduced entry-point outputs (as captured or as freshly
%           computed, depending on mode). Each field is the 1x5 row returned
%           by the local CHK below.
%
% See also CANON, CHECK_STAGE1

setup();
cfg = config();

has_stats = exist('normcdf', 'file') ~= 0 && exist('knnsearch', 'file') ~= 0;
has_ipt = exist('stdfilt', 'file') ~= 0 && exist('bwboundaries', 'file') ~= 0;

golden = struct();

% -------------------------------------------------------------------------
% Toolbox-free entry points
% -------------------------------------------------------------------------

rng(cfg.seed);
steer_filter = lib.steerable_filter([1, 3]);
golden.steerable_filter = chk(steer_filter);

rng(cfg.seed);
golden.csf_fitted = chk(lib.csf_fitted(linspace(0.5, 30, 20)));

% Synthetic clipped input, so this entry point is pinned at a non-zero value.
% On a real stimulus it returns 0, which would make the fingerprint degenerate.
% The >1% branch warns; that warning in the harness log is expected.
golden.compute_pClipped_clipped = chk(lib.compute_p_clipped([-0.5, 0.2, 1.5, 0.7]));

% -------------------------------------------------------------------------
% Statistics and Machine Learning Toolbox (normrnd, knnsearch, normcdf,
% binopdf) and Image Processing Toolbox (stdfilt, bwboundaries)
% -------------------------------------------------------------------------

if has_stats && has_ipt
    % --- pink noise. create_pink_noise_square calls normrnd and does NOT
    %     self-seed, so seed here. ---
    rng(cfg.seed);
    [pink_square, white_noise] = lib.create_pink_noise_square(64, 1);
    golden.create_pink_noise_square = chk(pink_square);
    golden.create_pink_noise_square_wn = chk(white_noise);
    golden.whiten = chk(real(lib.whiten(pink_square)));

    % --- target masks. The circular branch is deterministic; the
    %     filtered-noise branch calls normrnd without self-seeding. ---
    rng(cfg.seed);
    [mask_circ, mask_edge_circ, normal_circ] = lib.target_mask( ...
        'bg_size', 128, 'target_radius', 32);
    golden.target_mask_circular = chk(mask_circ);
    golden.target_mask_circular_edge = chk(mask_edge_circ);
    golden.target_mask_circular_normal = chk(normal_circ);

    rng(cfg.seed);
    golden.target_mask_shape2 = chk(lib.target_mask( ...
        'bg_size', 128, 'target_radius', 32, 'target_shape', 2));

    % --- stimulus. Self-seeds with rng('default'); rng(seed) at
    %     +lib/stimulus.m:82-83, so the seed here is belt and braces. ---
    rng(cfg.seed);
    [stim, stim_b] = lib.stimulus('seed', 35096, 'bg_size', 128, ...
        'target_radius', 32, 'ml_b', 0.5, 'cont_b', 0.15);
    golden.stimulus = chk(stim);
    golden.stimulus_blank = chk(stim_b);

    % --- gradients and local contrast ---
    rng(cfg.seed);
    golden.steerable_grad = chk(lib.steerable_grad(stim, 'kernel_size', [1, 3]));
    golden.local_sd = chk(lib.local_sd(stim, [1, 3]));

    % --- the two live edge definitions (see B1.1: they disagree, which is a
    %     Stage-4 item; the harness pins both as they stand today) ---
    rng(cfg.seed);
    [edge_vector, edge_power, edge_field, theta_grid] = lib.edge(stim, 'mask', 32);
    golden.edge_vector = chk(edge_vector);
    golden.edge_power = chk(edge_power);
    golden.edge_field = chk(edge_field);
    golden.edge_theta_grid = chk(theta_grid);

    rng(cfg.seed);
    edge_ideal = lib.edge_vector_ideal(stim, 'mask', 32);
    golden.edge_vector_ideal = chk(edge_ideal);
    [power_ideal, amp_spec, power_spec, phase_spec] = lib.edge_measures_ideal(edge_ideal);
    golden.edge_measures_ideal_power = chk(power_ideal);
    golden.edge_measures_ideal_as = chk(amp_spec);
    golden.edge_measures_ideal_ps = chk(power_spec);
    golden.edge_measures_ideal_phase = chk(phase_spec);

    golden.compute_pClipped = chk(lib.compute_p_clipped(stim));

    % --- 2-D autocorrelation. parfor over a sliced output; span kept small
    %     so the harness stays quick. ---
    rng(cfg.seed);
    golden.autocorr = chk(lib.autocorr(stim, 2));

    % --- psychometric fitting: deterministic, fminsearch ---
    target_means = [0.1, 0.2, 0.3, 0.4, 0.5];
    num_blanks = [30, 30, 30, 30, 30];
    num_targets = [30, 30, 30, 30, 30];
    num_hits = [12, 16, 20, 24, 27];
    num_cr = [18, 20, 22, 25, 28];

    [p_correct, p_hit, p_cr, d_prime] = experiment.analysis.psychometricFun( ...
        target_means, 0, 0.3, 1.2, 0.1);
    golden.psychometricFun_pc = chk(p_correct);
    golden.psychometricFun_ph = chk(p_hit);
    golden.psychometricFun_pcr = chk(p_cr);
    golden.psychometricFun_d = chk(d_prime);

    golden.computeNegLogLikelihood = chk(experiment.analysis.computeNegLogLikelihood( ...
        [0.3, 1.2, 0.1], target_means, num_blanks, num_targets, num_hits, num_cr));
    golden.computeNegLogLikelihood_out_of_range = chk( ...
        experiment.analysis.computeNegLogLikelihood([-1, 1.2, 0.1], target_means, ...
        num_blanks, num_targets, num_hits, num_cr));

    [fit_a, fit_b, fit_c] = experiment.analysis.fitPsychometric(0.3, 1.2, 0.1, ...
        target_means, num_blanks, num_targets, num_hits, num_cr);
    golden.fitPsychometric = chk([fit_a, fit_b, fit_c]);
else
    warning('golden_harness:noToolbox', ...
        ['Statistics and Machine Learning Toolbox and/or Image Processing ', ...
         'Toolbox not found -- the +lib core chain and the psychometric ', ...
         'entry points were skipped.']);
end

% -------------------------------------------------------------------------

if strcmp(mode, 'capture')
    save(golden_file, 'golden');
    fprintf('golden_harness: captured %d fields to %s\n', ...
        numel(fieldnames(golden)), golden_file);
elseif strcmp(mode, 'replay')
    ref = load(golden_file, 'golden');
    assert(isequal(ref.golden, golden), 'golden_harness:mismatch', ...
        'golden output changed -- this edit is not behaviour-preserving');
    fprintf('golden_harness: replay matched all %d fields\n', ...
        numel(fieldnames(golden)));
else
    error('golden_harness:mode', 'mode must be ''capture'' or ''replay''');
end
end

function c = chk(x)
% CHK  Reduce an output array to a small, order-sensitive fingerprint.
%   c = [sum, sum of squared magnitudes, index-weighted sum, NaN count,
%        element count], computed over the non-NaN elements in column order.
%
% NaN-aware because lib.steerable_grad pads with NaN, and a plain sum() would
% collapse every such output to NaN and then compare equal to any other NaN
% output. The squared and index-weighted terms are there because a plain sum
% is far too weak on image-shaped outputs: it is preserved by any operation
% that leaves the DC component alone, so lib.create_pink_noise_square, its
% own white noise, and lib.whiten all reduced to the same number under a
% sum-only fingerprint.
v = x(~isnan(x));
v = v(:);
weights = (1:numel(v)).';
c = [sum(v), sum(abs(v).^2), sum(weights .* v), nnz(isnan(x)), numel(x)];
end
