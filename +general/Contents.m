% +general  (package namespace: general.*)
% Analysis and exploration scripts for the camouflage-detection edge
% model: the live model-fitting chain, per-experiment edge-property
% extraction, edge-power sampling, and one-off plots and demos.
%
% Call functions/scripts as general.<name>. Requires the repo root on the
% MATLAB path (see setup.m). Most files here are scripts, not functions —
% run cell by cell, not called with arguments.
%
% Live model chain (cleaned in tranche 0.1.7; run in this order)
%   general.compute_nat_img_eff_coding_bins - efficient-coding gradient
%     histogram bins and PCA rotation, from natural images
%   general.compute_edge_props_exp_pca      - applies the bins/rotation to
%     one experiment's stimuli, per trial
%   general.fit_edge_model_with_exps        - fits the edge-counting model
%     to subjects' data
%   general.compute_nll_edge_model          - the model's negative log
%     likelihood (the only function in this package; everything else is a
%     script)
%
% Edge-property extraction (near-identical siblings; see docs/repo-cleanup.md
% section 4.1.3 for the shared eval()-driven naming and bare-load frozen
% names they carry)
%   general.compute_edge_props_exp      - forward level order, PCA bins
%   general.compute_edge_props_exp_eq   - forward level order, plain bins
%   general.compute_edge_props_exp_full - reversed level order (B1.2), plain
%     bins, cross-scale sum instead of classify_normals
%   general.compute_edge_props_exp_raw  - reversed level order (B1.2), plain
%     bins re-spaced equispaced per scale
%   general.compute_edge_props_pink_noise - per-pixel edge-property pooling
%     for pink-noise stimuli (not per-experiment)
%
% Edge-power sampling and fitting
%   general.compute_edge_powers_camo        - camo texture, ideal observer
%   general.compute_edge_powers_camo_large  - large camo texture, ideal observer
%   general.compute_edge_powers_pink_noise  - pink-noise texture, ideal observer
%   general.pick_edge_power_bins            - interactive bin-edge picking
%   general.fit_csf                         - Watson ATF fit to human CSF data
%   general.fit_hyperexp_dist               - two-rate hyperexponential fit
%
% Analysis and plotting
%   general.analyze_search_expts            - detection/search hit rate and d'
%   general.analyze_shape_expts             - accuracy vs. boundary shape exponent
%   general.analyze_shuffled_expt           - blocked vs. unblocked pink-noise design
%   general.compute_avg_acc_for_texture     - pooled accuracy from psychometric fits
%   general.compute_edge_group_measures     - contour-group edge measures (B1.5)
%   general.compute_noise_colour            - 1/f^alpha spectral exponent and
%     correlation length of a synthesised texture
%   general.compute_texture_autocorrelation - autocorrelation and correlation
%     length of named textures
%   general.plot_contour_props              - contour-property distributions,
%     target vs. blank vs. texture
%   general.plot_shape_exponent_exps        - unfinished stub (loads data,
%     computes nothing)
%   general.shuffle_unshuffle_expt          - shuffle/unshuffle trial order
%   general.compare_edge_energy_defs        - compares edge-energy definitions
%     (calls a function, analysis.compute_dPrime_pCorrect, that does not
%     exist anywhere in this repo; errors if run)
%   general.check_camo_texture              - display stimuli for each texture
%     in texture_list
%   general.cam_ability_vs_samples          - sample-size convergence of edge
%     energy statistics
%   general.flip_hard_easy                  - reverse an experiment's level order
%   general.video_demo                      - rank random target placements by
%     edge energy (lib.stimulus calls are broken here; positional arguments
%     against a name-value-only signature, errors if run)
%   general.RandBoundary                    - synthesise a random 1/f^p
%     boundary shape (unrelated demo, not part of the model chain)
%
% Out of scope (pre-existing, user-renamed `_`-prefixed deprecated
% versions; not touched by the Stage 1 cleanup pass)
%   general._changepower, general._combine_edge_strength_and_spectrum,
%   general._compute_edge_measures_ideal, general._compute_edge_powers_bark,
%   general._compute_edge_powers_spots, general._compute_edge_strengths_multiscale,
%   general._compute_edges, general._fit_edge_model,
%   general._fit_edge_model_naive_scaling, general._fit_edge_model_old
