function [stimuli, textures, seeds, b_target_present, p_clipped] = ...
    generate_camouflage_stimuli_all(texture_list, n_tex, n_trials_eachtx, n_trials, n_levels, ...
    n_sessions, bg_size, target_radius, luminance, contrast, b_target_present)
% GENERATE_CAMOUFLAGE_STIMULI_ALL  Synthesise stimuli for the all-textures variant.
%   [stimuli, textures, seeds, b_target_present, p_clipped] = ...
%       experiment.generate_camouflage_stimuli_all(texture_list, n_tex, n_trials_eachtx, ...
%       n_trials, n_levels, n_sessions, bg_size, target_radius, luminance, contrast, ...
%       b_target_present)
%
%   Variant of experiment.generate_camouflage_stimuli with no edge-power
%   targeting: it makes n_trials_eachtx stimuli from every texture in the list,
%   exactly half of them target-present, then shuffles the whole pool into the
%   trial x level x session layout the rest of the experiment expects. Seeds
%   are drawn by lib.stimulus rather than chosen here, so nothing selects for
%   a particular edge power.
%
%   Inputs
%     texture_list    - struct array of textures, one element per texture,
%                       passed straight to lib.stimulus.
%     n_tex           - number of textures, count.
%     n_trials_eachtx - stimuli generated per texture, count.
%     n_trials        - trials per level per session in the output layout, count.
%     n_levels        - levels per session in the output layout, count.
%     n_sessions      - sessions, count.
%     bg_size         - stimulus side, in pixels.
%     target_radius   - target radius, in pixels.
%     luminance       - mean luminance, normalised, in [0, 1].
%     contrast        - RMS contrast, dimensionless fraction.
%
%   Output
%     stimuli          - bg_size x bg_size x n_trials x n_levels x n_sessions array
%                        in normalised luminance units.
%     textures         - n_trials x n_levels x n_sessions struct array recording
%                        which texture each stimulus came from.
%     seeds            - n_trials x n_levels x n_sessions RNG seeds.
%     b_target_present - n_trials x n_levels x n_sessions logical, shuffled from
%                        the exactly-balanced per-texture assignment. It is also
%                        declared as the eleventh input, but that input is dead:
%                        the only caller passes ten arguments, and the first
%                        thing this function does with the name is overwrite it.
%     p_clipped        - n_trials x n_levels x n_sessions fraction of each
%                        stimulus's boundary-ribbon pixels outside [0, 1].
%
%   The textures output is preallocated with four fields, but texture_list on
%   disk now carries eight, four acc_* fields having been appended by later
%   analysis, so the per-trial assignment errors (B2.8).
%
%   n_trials_eachtx must be even, and n_tex*n_trials_eachtx must equal
%   n_trials*n_levels*n_sessions; neither is checked.
%
%   See also experiment.SESSION_SETTINGS, experiment.GENERATE_CAMOUFLAGE_STIMULI,
%   lib.STIMULUS.

    [~, ~, ~, mask_strip] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);
    stimuli_flat = zeros(bg_size, bg_size, n_trials_eachtx, n_tex);
    seeds = nan(n_trials_eachtx, n_tex);
    p_clipped = zeros(n_trials_eachtx, n_tex);

    % create target present array (exactly equal targets and blanks)
    b_target_present = [true(n_trials_eachtx/2, n_tex); false(n_trials_eachtx/2, n_tex)];

    % generate stimuli images
    for i_tex = 1:n_tex
        texture = texture_list(i_tex);
        for i_trial = 1:n_trials_eachtx
            fprintf('Texture %d trial %d\n', [i_tex i_trial])
            if b_target_present(i_trial, i_tex) % if this is a with-target stimulus
                [stim, ~, seed] = lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                    'target_radius', target_radius, 'ml_b', luminance, 'cont_b', contrast, ...
                    'ml_t', luminance, 'cont_t', contrast);
            else % if this is a without-target stimulus
                [stim, ~, seed] = lib.stimulus('texture', texture, 'bg_size', bg_size, ...
                    'ml_b', luminance, 'cont_b', contrast, 'ml_t', luminance, ...
                    'cont_t', contrast);
            end
            seeds(i_trial, i_tex) = seed;
            stimuli_flat(:, :, i_trial, i_tex) = stim;
            p_clipped(i_trial, i_tex) = lib.compute_p_clipped(stim(mask_strip));
        end
    end

    % reshape the trials to the usual experiment array
    trial_idx = reshape(randperm(numel(seeds)), [n_trials n_levels n_sessions]);
    seeds = seeds(trial_idx);
    p_clipped = p_clipped(trial_idx);
    b_target_present = b_target_present(trial_idx);
    stimuli = nan(bg_size, bg_size, n_trials, n_levels, n_sessions);
    textures = struct('type', {}, 'img', {}, 'scale', {}, 'exponent', {});

    for i_trial = 1:n_trials
        for i_level = 1:n_levels
            for i_session = 1:n_sessions
                [stim_i_trial, stim_i_tex] = ind2sub([n_trials_eachtx n_tex], ...
                    trial_idx(i_trial, i_level, i_session));
                stimuli(:, :, i_trial, i_level, i_session) = ...
                    stimuli_flat(:, :, stim_i_trial, stim_i_tex);
                textures(i_trial, i_level, i_session) = texture_list(stim_i_tex);
            end
        end
    end
end
