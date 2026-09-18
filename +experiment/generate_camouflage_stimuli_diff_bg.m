function [stimuli, seeds, edgePowers, pClipped] = ...
    generate_camouflage_stimuli_diff_bg(target_exponent, bg_exponents, nTrials, nSessions, ...
    bg_size, target_radius, luminance, contrast, bTargetPresent)
% GENERATE_CAMOUFLAGE_STIMULI_DIFF_BG  Synthesise stimuli for the different-background variant.
%   [stimuli, seeds, edgePowers, pClipped] = ...
%       experiment.generate_camouflage_stimuli_diff_bg(target_exponent, bg_exponents, ...
%       nTrials, nSessions, bg_size, target_radius, luminance, contrast, bTargetPresent)
%
%   Variant of experiment.generate_camouflage_stimuli in which the level sets
%   the background's 1/f exponent while the target keeps its own fixed one, so
%   the difficulty is controlled by how alike the two textures are rather than
%   by selecting seeds of a given edge power. Seeds are drawn by lib.stimulus,
%   and the edge power of each finished stimulus is measured afterwards.
%
%   Inputs
%     target_exponent - target texture's 1/f exponent, dimensionless.
%     bg_exponents    - background 1/f exponent per level, dimensionless; its
%                       length is the number of levels.
%     nTrials         - trials per level per session, count.
%     nSessions       - sessions, count.
%     bg_size         - stimulus side, in pixels. Not passed on to
%                       lib.stimulus, which therefore uses its own default.
%     target_radius   - target radius, in pixels.
%     luminance       - mean luminance, normalised, in [0, 1].
%     contrast        - RMS contrast, dimensionless fraction.
%     bTargetPresent  - nTrials x nLevels x nSessions logical, which trials
%                       contain a target.
%
%   Output
%     stimuli    - bg_size x bg_size x nTrials x nLevels x nSessions array in
%                  normalised luminance units.
%     seeds      - nTrials x nLevels x nSessions RNG seeds. Currently the
%                  background image, not the seed — see below.
%     edgePowers - nTrials x nLevels x nSessions dimensionless edge power,
%                  measured from each stimulus. Blank trials are left NaN.
%     pClipped   - nTrials x nLevels x nSessions fraction of each stimulus's
%                  boundary-ribbon pixels outside [0, 1].
%
%   Both lib.stimulus calls destructure its outputs one position short: the
%   signature is [stim, stim_bg, seed, ...], so what is caught as seed here is
%   really the background image (B2.4). The correct form, [stim, ~, seed], is
%   used in the _all variant.
%
%   This variant was run, and it is the one affected by the two recorded
%   target/background confusions inside lib.stimulus, B1.4 and B2.13.
%
%   The parfor writes only sliced outputs, so worker order cannot change any
%   result.
%
%   See also experiment.SESSION_SETTINGS_DIFF_BG, experiment.GENERATE_CAMOUFLAGE_STIMULI,
%   lib.STIMULUS, lib.EDGE_VECTOR_IDEAL.

    texture_target.type = 'pink_noise';
    texture_target.exponent = target_exponent;

    [~, ~, ~, mask_strip] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);
    nLevels = length(bg_exponents);
    stimuli = zeros(bg_size, bg_size, nTrials, nLevels, nSessions);
    seeds = nan(nTrials, nLevels, nSessions);
    edgePowers = nan(nTrials, nLevels, nSessions);
    pClipped = zeros(nTrials, nLevels, nSessions);

    % generate stimuli images
    for iLevel = 1:nLevels
        texture_bg.type = 'pink_noise';
        texture_bg.exponent = bg_exponents(iLevel);
        for iSession = 1:nSessions
            parfor iTrial = 1:nTrials
                fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
                if bTargetPresent(iTrial, iLevel, iSession) % if this is a target stimulus
                    [stim, seed] = lib.stimulus('texture', texture_target, ...
                        'texture_bg', texture_bg, 'target_radius', target_radius, ...
                        'ml_b', luminance, 'cont_b', contrast);
                else % if this is a blank stimulus
                    [stim, seed] = lib.stimulus('texture', texture_bg, 'ml_b', luminance, ...
                        'cont_b', contrast);
                end
                seeds(iTrial, iLevel, iSession) = seed;
                stimuli(:, :, iTrial, iLevel, iSession) = stim;
                edge_vector = lib.edge_vector_ideal(stim, 'mask', target_radius);
                edgePowers(iTrial, iLevel, iSession) = lib.edge_measures_ideal(edge_vector);
                pClipped(iTrial, iLevel, iSession) = lib.compute_p_clipped(stim(mask_strip));
            end
        end
    end
end
