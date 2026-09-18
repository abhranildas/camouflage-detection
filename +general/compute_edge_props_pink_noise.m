% compute_edge_props_pink_noise  Score edge-density and other edge-property
%     statistics of 1000 pink-noise-texture target/blank stimulus pairs.
%
%     compute_edge_props_pink_noise
%
% Script, not a function — run it cell by cell. Filters each stimulus with
% `vislab.lib.otf_filter`, detects edge pixels, restricts them to the
% target-boundary strip, and pools `lib.edge_props_stim`'s per-pixel
% output across all samples.
%
% Inputs: none from disk; all parameters (below) are literals.
% Output: `edge_props_t`/`edge_props_b` (pooled per-pixel edge-property
%     structs) and `edge_density_t`/`edge_density_b` (n_samples x 1,
%     dimensionless edge density) in the workspace, plus one figure
%     comparing their `pos_al` distributions. Nothing is saved to disk.
%
% See also lib.edge_props_stim, lib.detect_edge_pixels, vislab.lib.otf_filter.

%% Compute edge contour features of pink noise stimuli
clearvars
texture.type = 'pink_noise';
target_radius = 64;
luminance = 0.5;
contrast = 0.15;
ppd = 60;
[~, ~, ~, mask_strip] = lib.target_mask('kernel_size', [1 2]);
n_samples = 1e3;
edge_density_b = nan(n_samples, 1);
edge_density_t = nan(n_samples, 1);

for seed = 1:n_samples
    seed  % deliberate: progress display, read again below
    [stim_t, stim_b] = lib.stimulus('seed', seed, 'texture', texture, 'ml_b', luminance, ...
        'cont_b', contrast, 'target_radius', target_radius);

    % target edge properties
    stim_otf = vislab.lib.otf_filter(stim_t, ppd, 4, 555);
    edge_pixels = lib.detect_edge_pixels(stim_otf);
    boundary_edge_pixels = single(edge_pixels&mask_strip)';
    % nan the non-boundary region to compute densities correctly
    boundary_edge_pixels(~mask_strip) = nan;
    [edge_props, mean_edge_props] = lib.edge_props_stim(stim_otf, 'edge_pixels', ...
        boundary_edge_pixels);
    edge_density_t(seed) = mean_edge_props.dens;
    if ~exist('edge_props_t', 'var')
        edge_props_t = edge_props;
    else
        edge_props_t = [edge_props_t edge_props];
    end

    % blank edge properties
    stim_otf = vislab.lib.otf_filter(stim_b, ppd, 4, 555);
    edge_pixels = lib.detect_edge_pixels(stim_otf);
    boundary_edge_pixels = single(edge_pixels&mask_strip)';
    % nan the non-boundary region to compute densities correctly
    boundary_edge_pixels(~mask_strip) = nan;
    [edge_props, mean_edge_props] = lib.edge_props_stim(stim_otf, 'edge_pixels', ...
        boundary_edge_pixels);
    edge_density_b(seed) = mean_edge_props.dens;
    if ~exist('edge_props_b', 'var')
        edge_props_b = edge_props;
    else
        edge_props_b = [edge_props_b edge_props];
    end

end

%% plot statistics of a feature
figure; hold on
histogram(log([edge_props_b.pos_al]), 'normalization', 'pdf', 'edgecolor', 'none')
histogram(log([edge_props_t.pos_al]), 'normalization', 'pdf', 'edgecolor', 'none')
