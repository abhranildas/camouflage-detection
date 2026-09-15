function [stimuli, seeds, edgePowers, pClipped, bTargetPresent] = ...
    transform_camouflage_stimuli(expNameStr, luminance, contrast)
% TRANSFORM_CAMOUFLAGE_STIMULI  Rescale an existing experiment's stimuli.
%   [stimuli, seeds, edgePowers, pClipped, bTargetPresent] = ...
%       experiment.transform_camouflage_stimuli(expNameStr, luminance, contrast)
%
%   Reuses a finished experiment's stimulus set at a different display mean
%   luminance and RMS contrast, instead of synthesising fresh stimuli. Each
%   image is scaled about its own mean and shifted, which preserves every
%   seed, target location and edge power while changing only the two display
%   quantities. Clipping is recomputed afterwards, because the new mean and
%   contrast can push pixels outside the displayable range.
%
%   Inputs
%     expNameStr - name of the source experiment, matching its exp_files/
%                  subdirectory.
%     luminance  - new mean luminance, normalised, in [0, 1].
%     contrast   - new RMS contrast, dimensionless fraction.
%
%   Output
%     stimuli        - the source stimuli rescaled, in normalised luminance.
%     seeds          - the source seeds, passed through unchanged.
%     edgePowers     - the source edge powers, passed through unchanged. Note
%                      these describe the untransformed stimuli.
%     pClipped       - fraction of each transformed stimulus's pixels outside
%                      [0, 1], recomputed here.
%     bTargetPresent - the source target-present flags, unchanged.
%
%   This function reads ExpSettings.nBlocks and ExpSettings.stimuliSeed, which
%   only experiment.sessionSettings_texture_exponent emits; every other
%   generator writes .nLevels and .seeds. So the transform path of the base
%   experiment.sessionSettings errors on any settings file it did not itself
%   produce (B2.18, same root cause as B2.6).
%
%   See also experiment.SESSIONSETTINGS, experiment.GENERATE_CAMOUFLAGE_STIMULI.

    load(['exp_files/' expNameStr '/exp_settings.mat']);
    luminance_old = ExpSettings.luminance;
    contrast_old = ExpSettings.contrast;
    stimuli = ExpSettings.stimuli;

    % scale and shift stimuli to have new ml and cont:
    stimuli = stimuli*luminance*contrast/(luminance_old*contrast_old);
    stimuli = stimuli + luminance*(1 - contrast/contrast_old);

    % report clipping of transformed stimuli:
    nTrials = ExpSettings.nTrials;
    nBlocks = ExpSettings.nBlocks;
    nSessions = ExpSettings.nSessions;
    pClipped = zeros(nTrials, nBlocks, nSessions);
    for iSession = 1:nSessions
        for iBlock = 1:nBlocks
            for iTrial = 1:nTrials
                stimulus = stimuli(:, :, iTrial, iBlock, iSession);
                pClipped(iTrial, iBlock, iSession) = lib.compute_pClipped(stimulus);
            end
        end
    end

    seeds = ExpSettings.stimuliSeed;
    edgePowers = ExpSettings.edgePowers;
    bTargetPresent = ExpSettings.bTargetPresent;
end
