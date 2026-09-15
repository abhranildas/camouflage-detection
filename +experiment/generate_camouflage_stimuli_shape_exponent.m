function [stimuli, seeds, edgePowers, pClipped] = ...
    generate_camouflage_stimuli_shape_exponent(shape_exponents, texture, nTrials, nSessions, ...
    bg_size, target_radius, luminance, contrast, bTargetPresent)
% GENERATE_CAMOUFLAGE_STIMULI_SHAPE_EXPONENT  Synthesise stimuli for the shape-roughness variant.
%   [stimuli, seeds, edgePowers, pClipped] = ...
%       experiment.generate_camouflage_stimuli_shape_exponent(shape_exponents, texture, ...
%       nTrials, nSessions, bg_size, target_radius, luminance, contrast, bTargetPresent)
%
%   Variant of experiment.generate_camouflage_stimuli in which the level sets
%   the 1/f exponent of the target boundary's shape rather than selecting
%   seeds of a given edge power. Seeds are drawn by lib.stimulus, and edge
%   power is measured afterwards with lib.edge over the mask that lib.stimulus
%   returns, so target and measurement use the same boundary.
%
%   Inputs
%     shape_exponents - target-boundary 1/f exponent per level, dimensionless;
%                       its length is the number of levels.
%     texture         - texture struct for lib.stimulus (.type, .exponent).
%     nTrials         - trials per level per session, count.
%     nSessions       - sessions, count.
%     bg_size         - stimulus side, in pixels.
%     target_radius   - target radius, in pixels.
%     luminance       - mean luminance, normalised, in [0, 1].
%     contrast        - RMS contrast, dimensionless fraction.
%     bTargetPresent  - nTrials x nLevels x nSessions logical, which trials
%                       contain a target.
%
%   Output
%     stimuli    - bg_size x bg_size x nTrials x nLevels x nSessions array in
%                  normalised luminance units.
%     seeds      - nTrials x nLevels x nSessions single-precision RNG seeds.
%     edgePowers - nTrials x nLevels x nSessions edge power from lib.edge.
%                  Blank trials are left NaN.
%     pClipped   - nTrials x nLevels x nSessions fraction of each target
%                  stimulus's boundary-ribbon pixels outside [0, 1]. Blank
%                  trials are left at 0, since the ribbon is only available on
%                  the target branch.
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
%   See also experiment.SESSIONSETTINGS_SHAPE_EXPONENT,
%   experiment.GENERATE_CAMOUFLAGE_STIMULI, lib.STIMULUS, lib.EDGE.

% texture.type='pink_noise';
%     n_edge=1e4; kernel_sd=1;

%     [~,~,~,bdry_ribbon]=lib.circular_mask(bg_size,target_radius,'center');
    nLevels = length(shape_exponents);
    stimuli = zeros(bg_size, bg_size, nTrials, nLevels, nSessions);
    seeds = nan(nTrials, nLevels, nSessions, 'single');
    edgePowers = nan(nTrials, nLevels, nSessions);
    pClipped = zeros(nTrials, nLevels, nSessions);

    % generate stimuli images
    parfor iLevel = 1:nLevels
        shape_exponent = shape_exponents(iLevel);
        for iSession = 1:nSessions
            for iTrial = 1:nTrials
                fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
                if bTargetPresent(iTrial, iLevel, iSession) % if this is a target stimulus%
                    %                     [stim,seed]=lib.stimulus('texture',texture,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
                    [stim, seed, mask, mask_edge, mask_normal, mask_strip] = ...
                        lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                        'target_shape', shape_exponent, 'target_radius', target_radius, ...
                        'ml_b', luminance, 'cont_b', contrast);
                    [~, target_edge_power] = lib.edge(stim, 'mask', mask, ...
                        'mask_edge', mask_edge, 'mask_normal', mask_normal, ...
                        'kernel_size', [1 3]);
                    %                 edge=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
                    edgePowers(iTrial, iLevel, iSession) = target_edge_power;
                    pClipped(iTrial, iLevel, iSession) = lib.compute_pClipped(stim(mask_strip));
                else % if this is a blank stimulus
                    [stim, seed] = lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                        'ml_b', luminance, 'cont_b', contrast);
                end
                seeds(iTrial, iLevel, iSession) = seed;
                stimuli(:, :, iTrial, iLevel, iSession) = stim;
            end
        end
    end
end
