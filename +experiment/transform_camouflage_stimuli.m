function [stimuli, seeds, stim_edge_powers, p_clipped, b_target_present] = ...
    transform_camouflage_stimuli(exp_name_str, luminance, contrast)
% TRANSFORM_CAMOUFLAGE_STIMULI  Rescale an existing experiment's stimuli.
%   [stimuli, seeds, stim_edge_powers, p_clipped, b_target_present] = ...
%       experiment.transform_camouflage_stimuli(exp_name_str, luminance, contrast)
%
%   Reuses a finished experiment's stimulus set at a different display mean
%   luminance and RMS contrast, instead of synthesising fresh stimuli. Each
%   image is scaled about its own mean and shifted, which preserves every
%   seed, target location and edge power while changing only the two display
%   quantities. Clipping is recomputed afterwards, because the new mean and
%   contrast can push pixels outside the displayable range.
%
%   Inputs
%     exp_name_str - name of the source experiment, matching its exp_files/
%                    subdirectory.
%     luminance    - new mean luminance, normalised, in [0, 1].
%     contrast     - new RMS contrast, dimensionless fraction.
%
%   Output
%     stimuli          - the source stimuli rescaled, in normalised luminance.
%     seeds            - the source seeds, passed through unchanged.
%     stim_edge_powers - the source edge powers, passed through unchanged. Note
%                        these describe the untransformed stimuli.
%     p_clipped        - fraction of each transformed stimulus's pixels outside
%                        [0, 1], recomputed here.
%     b_target_present - the source target-present flags, unchanged.
%
%   This function reads ExpSettings.nBlocks and ExpSettings.stimuliSeed, which
%   only experiment.session_settings's 'texture_exponent' variant emits; every
%   other variant writes .nLevels and .seeds. So the transform path of the
%   'edge_power' variant, which is the only one that calls this function,
%   errors on any settings file the 'texture_exponent' variant did not produce
%   (B2.18, same root cause as B2.6).
%
%   See also experiment.SESSION_SETTINGS, experiment.GENERATE_CAMOUFLAGE_STIMULI.

    load(['exp_files/' exp_name_str '/exp_settings.mat']);
    luminance_old = ExpSettings.luminance;
    contrast_old = ExpSettings.contrast;
    stimuli = ExpSettings.stimuli;

    % scale and shift stimuli to have new ml and cont:
    stimuli = stimuli*luminance*contrast/(luminance_old*contrast_old);
    stimuli = stimuli + luminance*(1 - contrast/contrast_old);

    % report clipping of transformed stimuli:
    n_trials = ExpSettings.nTrials;
    n_blocks = ExpSettings.nBlocks;
    n_sessions = ExpSettings.nSessions;
    p_clipped = zeros(n_trials, n_blocks, n_sessions);
    for i_session = 1:n_sessions
        for i_block = 1:n_blocks
            for i_trial = 1:n_trials
                stimulus = stimuli(:, :, i_trial, i_block, i_session);
                p_clipped(i_trial, i_block, i_session) = lib.compute_p_clipped(stimulus);
            end
        end
    end

    seeds = ExpSettings.stimuliSeed;
    stim_edge_powers = ExpSettings.edgePowers;
    b_target_present = ExpSettings.bTargetPresent;
end
