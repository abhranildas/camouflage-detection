function [stimuli, seeds, edgePowers, pClipped] = ...
    generate_camouflage_stimuli_texture_exponent(texture_exponents, nTrials, nSessions, ...
    bg_size, target_radius, luminance, contrast, bTargetPresent)
% GENERATE_CAMOUFLAGE_STIMULI_TEXTURE_EXPONENT  Synthesise stimuli for the texture-exponent variant.
%   [stimuli, seeds, edgePowers, pClipped] = ...
%       experiment.generate_camouflage_stimuli_texture_exponent(texture_exponents, ...
%       nTrials, nSessions, bg_size, target_radius, luminance, contrast, bTargetPresent)
%
%   Variant of experiment.generate_camouflage_stimuli in which the level sets
%   the texture's 1/f exponent, for target and background alike, rather than
%   selecting seeds of a given edge power. Seeds are drawn by lib.stimulus,
%   and edge power is measured afterwards.
%
%   Inputs
%     texture_exponents - texture 1/f exponent per level, dimensionless; its
%                         length is the number of levels.
%     nTrials           - trials per level per session, count.
%     nSessions         - sessions, count.
%     bg_size           - stimulus side, in pixels. Used for the boundary
%                         ribbon and the output array, but not passed on to
%                         lib.stimulus, which therefore uses its own default.
%     target_radius     - target radius, in pixels.
%     luminance         - mean luminance, normalised, in [0, 1].
%     contrast          - RMS contrast, dimensionless fraction.
%     bTargetPresent    - nTrials x nLevels x nSessions logical, which trials
%                         contain a target.
%
%   Output
%     stimuli    - bg_size x bg_size x nTrials x nLevels x nSessions array in
%                  normalised luminance units.
%     seeds      - nTrials x nLevels x nSessions RNG seeds. Currently the
%                  background image, not the seed — see below.
%     edgePowers - nTrials x nLevels x nSessions dimensionless edge power.
%     pClipped   - nTrials x nLevels x nSessions fraction of each stimulus's
%                  boundary-ribbon pixels outside [0, 1].
%
%   This function cannot run as committed, for three separate reasons. Both
%   lib.stimulus calls destructure its outputs one position short, so what is
%   caught as seed is really the background image (B2.4). And two of the
%   functions it calls, lib.circular_mask and lib.edge_vector, do not exist
%   anywhere in the tree (B2.9) — lib.edge_vector was deleted when the edge
%   measures were reworked, and this caller was never updated.
%
%   A fourth defect is latent behind those: the per-level exponent is written
%   into texture.alpha, but lib.stimulus reads texture.exponent and defaults it
%   to 1 when absent, so every level would get the same texture whatever
%   texture_exponents says (B3.18). The _diff_bg variant passes .exponent
%   correctly.
%
%   The parfor writes only sliced outputs, so worker order cannot change any
%   result.
%
%   See also experiment.SESSION_SETTINGS_TEXTURE_EXPONENT,
%   experiment.GENERATE_CAMOUFLAGE_STIMULI, lib.STIMULUS.

    texture.type = 'pink_noise';
    n_edge = 1e4;  kernel_sigma = 1;

    [~, ~, ~, mask_strip] = lib.circular_mask(bg_size, target_radius, 'center');
    nLevels = length(texture_exponents);
    stimuli = zeros(bg_size, bg_size, nTrials, nLevels, nSessions);
    seeds = nan(nTrials, nLevels, nSessions);
    edgePowers = nan(nTrials, nLevels, nSessions);
    pClipped = zeros(nTrials, nLevels, nSessions);

    % generate stimuli images
    for iLevel = 1:nLevels
        texture.alpha = texture_exponents(iLevel);
        for iSession = 1:nSessions
            parfor iTrial = 1:nTrials
                fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
                if bTargetPresent(iTrial, iLevel, iSession) % if this is a target stimulus
                    [stim, seed] = lib.stimulus('texture', texture, ...
                        'target_radius', target_radius, 'ml_b', luminance, ...
                        'cont_b', contrast);
                else % if this is a blank stimulus
                    [stim, seed] = lib.stimulus('texture', texture, 'ml_b', luminance, ...
                        'cont_b', contrast);
                end
                seeds(iTrial, iLevel, iSession) = seed;
                stimuli(:, :, iTrial, iLevel, iSession) = stim;
                edge_vector = lib.edge_vector(stim, target_radius, n_edge, kernel_sigma);
                edgePowers(iTrial, iLevel, iSession) = lib.edge_measures(edge_vector);
                pClipped(iTrial, iLevel, iSession) = lib.compute_p_clipped(stim(mask_strip));
            end
        end
    end
end
