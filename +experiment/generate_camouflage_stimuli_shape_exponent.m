function [stimuli, seeds, stim_edge_powers, p_clipped] = ...
    generate_camouflage_stimuli_shape_exponent(shape_exponents, texture, n_trials, n_sessions, ...
    bg_size, target_radius, luminance, contrast, b_target_present)
% GENERATE_CAMOUFLAGE_STIMULI_SHAPE_EXPONENT  Synthesise stimuli for the shape-roughness variant.
%   [stimuli, seeds, stim_edge_powers, p_clipped] = ...
%       experiment.generate_camouflage_stimuli_shape_exponent(shape_exponents, texture, ...
%       n_trials, n_sessions, bg_size, target_radius, luminance, contrast, b_target_present)
%
%   Variant of experiment.generate_camouflage_stimuli in which the level sets
%   the 1/f exponent of the target boundary's shape rather than selecting
%   seeds of a given edge power. Seeds are drawn by lib.stimulus, and edge
%   power is measured afterwards with lib.edge over the mask that lib.stimulus
%   returns, so target and measurement use the same boundary.
%
%   Inputs
%     shape_exponents  - target-boundary 1/f exponent per level, dimensionless;
%                        its length is the number of levels.
%     texture          - texture struct for lib.stimulus (.type, .exponent).
%     n_trials         - trials per level per session, count.
%     n_sessions       - sessions, count.
%     bg_size          - stimulus side, in pixels.
%     target_radius    - target radius, in pixels.
%     luminance        - mean luminance, normalised, in [0, 1].
%     contrast         - RMS contrast, dimensionless fraction.
%     b_target_present - n_trials x n_levels x n_sessions logical, which trials
%                        contain a target.
%
%   Output
%     stimuli          - bg_size x bg_size x n_trials x n_levels x n_sessions array in
%                        normalised luminance units.
%     seeds            - n_trials x n_levels x n_sessions single-precision RNG seeds.
%     stim_edge_powers - n_trials x n_levels x n_sessions edge power from lib.edge.
%                        Blank trials are left NaN.
%     p_clipped        - n_trials x n_levels x n_sessions fraction of each target
%                        stimulus's boundary-ribbon pixels outside [0, 1]. Blank
%                        trials are left at 0, since the ribbon is only available on
%                        the target branch.
%
%   Three recorded defects meet in this function. The target branch
%   destructures lib.stimulus's outputs one position short — the signature is
%   [stim, stim_bg, seed, mask, ...] — so every output is shifted by one and
%   stim_bg, a whole image, is assigned into one element of seeds (B2.4). The
%   shape manipulation itself does not reach the stimulus, because
%   lib.create_pink_noise_line ignores the exponent it is handed (B1.3). And
%   the edge power measured here is lib.edge's, which is not the normalisation
%   the deployed edge-power files and the paper use (B1.1, decided by S3.4).
%
%   The parfor is over levels rather than trials and writes only sliced
%   outputs, so worker order cannot change any result.
%
%   See also experiment.SESSION_SETTINGS_SHAPE_EXPONENT,
%   experiment.GENERATE_CAMOUFLAGE_STIMULI, lib.STIMULUS, lib.EDGE.

% texture.type='pink_noise';
%     n_edge=1e4; kernel_sd=1;

%     [~,~,~,bdry_ribbon]=lib.circular_mask(bg_size,target_radius,'center');
    n_levels = length(shape_exponents);
    stimuli = zeros(bg_size, bg_size, n_trials, n_levels, n_sessions);
    seeds = nan(n_trials, n_levels, n_sessions, 'single');
    stim_edge_powers = nan(n_trials, n_levels, n_sessions);
    p_clipped = zeros(n_trials, n_levels, n_sessions);

    % generate stimuli images
    parfor i_level = 1:n_levels
        shape_exponent = shape_exponents(i_level);
        for i_session = 1:n_sessions
            for i_trial = 1:n_trials
                fprintf('Level %d Session %d Trial %d\n', [i_level i_session i_trial])
                if b_target_present(i_trial, i_level, i_session) % if this is a target stimulus%
                    %                     [stim,seed]=lib.stimulus('texture',texture,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
                    [stim, seed, mask, mask_edge, mask_normal, mask_strip] = ...
                        lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                        'target_shape', shape_exponent, 'target_radius', target_radius, ...
                        'ml_b', luminance, 'cont_b', contrast);
                    [~, target_edge_power] = lib.edge(stim, 'mask', mask, ...
                        'mask_edge', mask_edge, 'mask_normal', mask_normal, ...
                        'kernel_size', [1 3]);
                    %                 edge=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
                    stim_edge_powers(i_trial, i_level, i_session) = target_edge_power;
                    p_clipped(i_trial, i_level, i_session) = ...
                        lib.compute_p_clipped(stim(mask_strip));
                else % if this is a blank stimulus
                    [stim, seed] = lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                        'ml_b', luminance, 'cont_b', contrast);
                end
                seeds(i_trial, i_level, i_session) = seed;
                stimuli(:, :, i_trial, i_level, i_session) = stim;
            end
        end
    end
end
