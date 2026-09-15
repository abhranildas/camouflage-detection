function [stimuli, textures, seeds, bTargetPresent, pClipped] = ...
    generate_camouflage_stimuli_all(texture_list, nTex, nTrials_eachtx, nTrials, nLevels, ...
    nSessions, bg_size, target_radius, luminance, contrast, bTargetPresent)
% GENERATE_CAMOUFLAGE_STIMULI_ALL  Synthesise stimuli for the all-textures variant.
%   [stimuli, textures, seeds, bTargetPresent, pClipped] = ...
%       experiment.generate_camouflage_stimuli_all(texture_list, nTex, nTrials_eachtx, ...
%       nTrials, nLevels, nSessions, bg_size, target_radius, luminance, contrast, ...
%       bTargetPresent)
%
%   Variant of experiment.generate_camouflage_stimuli with no edge-power
%   targeting: it makes nTrials_eachtx stimuli from every texture in the list,
%   exactly half of them target-present, then shuffles the whole pool into the
%   trial x level x session layout the rest of the experiment expects. Seeds
%   are drawn by lib.stimulus rather than chosen here, so nothing selects for
%   a particular edge power.
%
%   Inputs
%     texture_list   - struct array of textures, one element per texture,
%                      passed straight to lib.stimulus.
%     nTex           - number of textures, count.
%     nTrials_eachtx - stimuli generated per texture, count.
%     nTrials        - trials per level per session in the output layout, count.
%     nLevels        - levels per session in the output layout, count.
%     nSessions      - sessions, count.
%     bg_size        - stimulus side, in pixels.
%     target_radius  - target radius, in pixels.
%     luminance      - mean luminance, normalised, in [0, 1].
%     contrast       - RMS contrast, dimensionless fraction.
%
%   Output
%     stimuli        - bg_size x bg_size x nTrials x nLevels x nSessions array
%                      in normalised luminance units.
%     textures       - nTrials x nLevels x nSessions struct array recording
%                      which texture each stimulus came from.
%     seeds          - nTrials x nLevels x nSessions RNG seeds.
%     bTargetPresent - nTrials x nLevels x nSessions logical, shuffled from
%                      the exactly-balanced per-texture assignment. It is also
%                      declared as the eleventh input, but that input is dead:
%                      the only caller passes ten arguments, and the first
%                      thing this function does with the name is overwrite it.
%     pClipped       - nTrials x nLevels x nSessions fraction of each
%                      stimulus's boundary-ribbon pixels outside [0, 1].
%
%   The textures output is preallocated with four fields, but texture_list on
%   disk now carries eight, four acc_* fields having been appended by later
%   analysis, so the per-trial assignment errors (B2.8).
%
%   nTrials_eachtx must be even, and nTex*nTrials_eachtx must equal
%   nTrials*nLevels*nSessions; neither is checked.
%
%   See also experiment.SESSIONSETTINGS_ALL, experiment.GENERATE_CAMOUFLAGE_STIMULI,
%   lib.STIMULUS.

    [~, ~, ~, mask_strip] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);
    stimuli_flat = zeros(bg_size, bg_size, nTrials_eachtx, nTex);
    seeds = nan(nTrials_eachtx, nTex);
    pClipped = zeros(nTrials_eachtx, nTex);

    % create target present array (exactly equal targets and blanks)
    bTargetPresent = [true(nTrials_eachtx/2, nTex); false(nTrials_eachtx/2, nTex)];

    % generate stimuli images
    for iTex = 1:nTex
        texture = texture_list(iTex);
        for iTrial = 1:nTrials_eachtx
            fprintf('Texture %d trial %d\n', [iTex iTrial])
            if bTargetPresent(iTrial, iTex) % if this is a with-target stimulus
                [stim, ~, seed] = lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                    'target_radius', target_radius, 'ml_b', luminance, 'cont_b', contrast, ...
                    'ml_t', luminance, 'cont_t', contrast);
            else % if this is a without-target stimulus
                [stim, ~, seed] = lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                    'ml_b', luminance, 'cont_b', contrast, 'ml_t', luminance, ...
                    'cont_t', contrast);
            end
            seeds(iTrial, iTex) = seed;
            stimuli_flat(:, :, iTrial, iTex) = stim;
            pClipped(iTrial, iTex) = lib.compute_pClipped(stim(mask_strip));
        end
    end

    % reshape the trials to the usual experiment array
    trial_idx = reshape(randperm(numel(seeds)), [nTrials nLevels nSessions]);
    seeds = seeds(trial_idx);
    pClipped = pClipped(trial_idx);
    bTargetPresent = bTargetPresent(trial_idx);
    stimuli = nan(bg_size, bg_size, nTrials, nLevels, nSessions);
    textures = struct('type', {}, 'img', {}, 'scale', {}, 'exponent', {});

    for iTrial = 1:nTrials
        for iLevel = 1:nLevels
            for iSession = 1:nSessions
                [stim_iTrial, stim_iTex] = ind2sub([nTrials_eachtx nTex], ...
                    trial_idx(iTrial, iLevel, iSession));
                stimuli(:, :, iTrial, iLevel, iSession) = ...
                    stimuli_flat(:, :, stim_iTrial, stim_iTex);
                textures(iTrial, iLevel, iSession) = texture_list(stim_iTex);
            end
        end
    end
end
