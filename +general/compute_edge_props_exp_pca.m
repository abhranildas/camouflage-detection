% COMPUTE_EDGE_PROPS_EXP_PCA  Edge features of every stimulus of an experiment,
%   in the PCA basis, combined across scales into one decision variable.
%
%   Script, not a function — run it cell by cell. It is the second step of the
%   live model chain: general.compute_nat_img_eff_coding_bins writes the
%   efficient-coding bins and the PCA rotation, this script applies them to a
%   whole experiment's stimuli, and general.fit_edge_model_with_exps then fits
%   the model to the subjects' data.
%
%   For each experiment in exp_paths it calls lib.edge_props_stim on every
%   stimulus, which returns the log-likelihood ratio of the gradient magnitude,
%   orientation and product histograms at each of five scales. The five
%   per-scale values of each feature are then combined into a single decision
%   variable per trial by classify_normals, fitted separately at each level, and
%   the three combined decision variables are saved next to the experiment.
%
%   Inputs (all read from disk, nothing is taken from the workspace)
%     vislab-common/data/nat_im_eff_coding.mat - the efficient-coding bin edges
%       grad_pca_m_bins, grad_pca_o_bins, grad_pca_p_bins (5 scales x 17 edges,
%       in gradient-magnitude units) and pca_coeffs (10 x 10 rotation).
%     exp_files/<exp_path>/exp_settings.mat - ExpSettings, whose .stimuli is
%       256 x 256 x 30 trials x 10 levels x 4 sessions greyscale in [0, 1] and
%       whose .bTargetPresent is the matching logical array.
%
%   Output
%     exp_files/<exp_path>/edge_props_pca.mat - the struct edge_props, with
%     fields grad_m, grad_o, grad_p (30 x 10 x 4 x 5 scales, per-scale LLRs,
%     dimensionless) and grad_m_comb, grad_o_comb, grad_p_comb (30 x 10 x 4,
%     the across-scale combined decision variables, dimensionless).
%
%   Known defects on this path, recorded and not fixed here. B1.2: the ndgrid
%   below builds the level index as 10:-1:1 while everything downstream indexes
%   levels forward, so the features may be stored against reversed levels —
%   confirm the intent before trusting any number this script produces. B2.2:
%   lib.edge_props_stim errors on camouflage stimuli as committed, so the
%   arrayfun call below cannot currently run. B3.15: that function computes the
%   PCA rotation and discards it, so pca_coeffs may have no effect even once
%   B2.2 is fixed. B3.11: the second cell reads edge_props_all_contours_b and
%   edge_props_all_contours_t, which nothing in the repo ever assigns.
%
%   Several variable names are fixed by things outside this file and were left
%   alone: grad_pca_m_bins, grad_pca_o_bins, grad_pca_p_bins and pca_coeffs come
%   in under those names from the load above; grad_m, grad_o, grad_p and the
%   per-scale grad_m_1 ... grad_p_16 are reached by eval() of strings built from
%   input_array_names and from the 'grad_m_' prefixes below, so renaming them
%   would break the script silently; and h is tested with exist('h', 'var').
%
%   See also lib.EDGE_PROPS_STIM, general.COMPUTE_NAT_IMG_EFF_CODING_BINS.

%% Compute edge contour properties of the stimuli of each experiment
% exp_paths={'natural/moth','natural/rock','natural/camo_large','natural/spots','natural/leaf','natural/leather','natural/camo','pink_noise',...
%     'natural/foliage','natural/soil','natural/grass','natural/paper','natural/bark_recast','texture_exponent/ecc_0'}; %
exp_paths = {'pink_noise'};
% filepaths={'all'};

% load the efficient-coding histogram bins of gradient magnitude, and pca
% coeffs, computed from natural images
load('vislab-common/data/nat_im_eff_coding.mat')

% dumb down the efficient bins to only use equispaced bins at each scale
n_bins = size(grad_pca_m_bins, 2) - 1;
for i_scale = 1:size(grad_pca_m_bins, 1)
    grad_pca_m_bins(i_scale, :) = [-inf, ...
        linspace(grad_pca_m_bins(i_scale, 2), grad_pca_m_bins(i_scale, end-1), n_bins-1), inf];
    grad_pca_o_bins(i_scale, :) = [-inf, ...
        linspace(grad_pca_o_bins(i_scale, 2), grad_pca_o_bins(i_scale, end-1), n_bins-1), inf];
    grad_pca_p_bins(i_scale, :) = [-inf, ...
        linspace(grad_pca_p_bins(i_scale, 2), grad_pca_p_bins(i_scale, end-1), n_bins-1), inf];
end

[trial_grid, level_grid, session_grid] = ndgrid(1:30, 10:-1:1, 1:4);
n_scales = 5;
nLevels = 10;

for i_exp = 1:length(exp_paths)
    tic
    exp_path = exp_paths{i_exp}  % deliberate: progress display, read again below
    load(['exp_files/' exp_path '/exp_settings.mat']);

    edge_props = struct;

    % [grad_m_1,grad_m_2,grad_m_4,grad_m_8,grad_m_16,...
    %     grad_o_1,grad_o_2,grad_o_4,grad_o_8,grad_o_16,...
    %     grad_p_1,grad_p_2,grad_p_4,grad_p_8,grad_p_16,...
    %     edge_props.npix_llr,...
    %     edge_props.ncon_llr,...
    %     edge_props.len_llr,...
    %     edge_props.pos_llr,...
    %     edge_props.pos_sum,...
    %     edge_props.or_llr,...
    %     edge_props.or_sum,...
    %     edge_props.curv_llr,...
    %     edge_props.curv_sum,...
    %     ep_1,ep_2,ep_4,ep_8,ep_16]=...

    [grad_m_1, grad_m_2, grad_m_4, grad_m_8, grad_m_16, ...
        grad_o_1, grad_o_2, grad_o_4, grad_o_8, grad_o_16, ...
        grad_p_1, grad_p_2, grad_p_4, grad_p_8, grad_p_16] = ...
        arrayfun(@(i_trial, i_level, i_session) ...
        lib.edge_props_stim(ExpSettings.stimuli(:, :, i_trial, i_level, i_session), ...
        'pca_coeffs', pca_coeffs, 'grad_mag_bins', grad_pca_m_bins, ...
        'grad_or_bins', grad_pca_o_bins, 'grad_prod_bins', grad_pca_p_bins), ...
        trial_grid, level_grid, session_grid);

    % store edge power and gradient histograms across scales into single arrays
    grad_m = nan([30 10 4 n_scales]);
    grad_o = nan([30 10 4 n_scales]);
    grad_p = nan([30 10 4 n_scales]);
    % ep=nan([30 10 4 n_scales]);
    for i_scale = 1:n_scales
        grad_m(:, :, :, i_scale) = eval(['grad_m_' num2str(2^(i_scale-1))]);
        grad_o(:, :, :, i_scale) = eval(['grad_o_' num2str(2^(i_scale-1))]);
        grad_p(:, :, :, i_scale) = eval(['grad_p_' num2str(2^(i_scale-1))]);
        % ep(:,:,:,i_scale)=eval(['ep_' num2str(2^(i_scale-1))]);
    end

    % edge_props.ep=ep;
    edge_props.grad_m = grad_m;
    edge_props.grad_o = grad_o;
    edge_props.grad_p = grad_p;

    % merge gradient histograms and edge powers across scales into combined decision variables
    % input_array_names={'grad_m','grad_o','grad_p','ep'};
    input_array_names = {'grad_m', 'grad_o', 'grad_p'};

    for i_input = 1:numel(input_array_names)
        input_array = eval(input_array_names{i_input});

        combined_dv = nan([30 10 4]);
        combined_dv_this_level = nan([30 1 4]);
        for i_level = 1:nLevels
            targets_this_level = ExpSettings.bTargetPresent(:, i_level, :);
            feature_vectors_target = nan(nnz(targets_this_level), n_scales);
            feature_vectors_blank = nan(nnz(~targets_this_level), n_scales);
            for i_scale = 1:n_scales
                feature_this_level = input_array(:, i_level, :, i_scale);
                feature_vectors_target(:, i_scale) = feature_this_level(targets_this_level);
                feature_vectors_blank(:, i_scale) = feature_this_level(~targets_this_level);
            end

            results = classify_normals(feature_vectors_target, feature_vectors_blank, ...
                'input_type', 'samp', 'samp_opt', false, 'plotmode', 0, 'precision', 'basic');
            combined_dv_this_level(targets_this_level) = results.samp_dv{1};
            combined_dv_this_level(~targets_this_level) = results.samp_dv{2};
            combined_dv(:, i_level, :) = combined_dv_this_level;
        end
        edge_props.([input_array_names{i_input} '_comb']) = combined_dv;

        % edge_props.([input_array_names{i_input} '_comb'])=sum(this_input_array,4);
    end

    % save edge properties
    save(['exp_files/' exp_path '/edge_props_pca.mat'], 'edge_props');
    toc
end

%% plot statistics of a feature
colors = colororder;
field_names = fieldnames(edge_props_all_contours_b);

feature_name = field_names{3}  % deliberate: printed for interactive inspection, read again below
figure; hold on
% xlim([0 4])
set(gca, 'yscale', 'log')
histogram([edge_props_all_contours_b.(feature_name)], 'normalization', 'pdf', 'edgecolor', 'none')
for i_level = 1:10
    if exist('h', 'var')
        delete(h)
    end
    h = histogram([edge_props_all_contours_t{i_level}.(feature_name)], ...
        'normalization', 'pdf', 'facecolor', colors(2, :), 'edgecolor', 'none');
    pause
end
