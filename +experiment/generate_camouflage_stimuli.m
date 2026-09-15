function [stimuli, seeds, edgePowers, pClipped] = generate_camouflage_stimuli(texture, ...
    exp_type, edgePowerBlockEdges, nTrials, nSessions, bg_size, target_radius, luminance, ...
    contrast, bTargetPresent)
% GENERATE_CAMOUFLAGE_STIMULI  Synthesise one experiment's camouflage stimuli.
%   [stimuli, seeds, edgePowers, pClipped] = experiment.generate_camouflage_stimuli(...
%       texture, exp_type, edgePowerBlockEdges, nTrials, nSessions, bg_size, ...
%       target_radius, luminance, contrast, bTargetPresent)
%
%   A level is a band of target edge power, so choosing a level means choosing
%   a seed whose precomputed edge power falls in that band. Target-present
%   trials draw their seeds, without replacement, from the seeds whose edge
%   power lies inside the level's band; blank trials draw from all seeds. Each
%   seed is then handed to lib.stimulus, which reseeds the generator with it,
%   so a stimulus is fully determined by its seed plus these parameters.
%
%   Inputs
%     texture             - texture struct passed straight to lib.stimulus
%                           (.type, and .stats/.Niter for a Portilla-Simoncelli
%                           texture).
%     exp_type            - experiment name, selecting the edge-power file.
%     edgePowerBlockEdges - nLevels x 2 array of [lower, upper] edge-power
%                           limits per level, dimensionless edge power.
%     nTrials             - trials per level per session, count.
%     nSessions           - sessions, count.
%     bg_size             - stimulus side, in pixels.
%     target_radius       - target radius, in pixels.
%     luminance           - mean luminance, normalised, in [0, 1].
%     contrast            - RMS contrast, dimensionless fraction.
%     bTargetPresent      - nTrials x nLevels x nSessions logical, which
%                           trials contain a target.
%
%   Output
%     stimuli    - bg_size x bg_size x nTrials x nLevels x nSessions array in
%                  normalised luminance units.
%     seeds      - nTrials x nLevels x nSessions RNG seeds, also the row index
%                  into the edge-power table.
%     edgePowers - nTrials x nLevels x nSessions edge power of each stimulus,
%                  dimensionless. Column 2 of the table for a target trial,
%                  column 1 for a blank.
%     pClipped   - nTrials x nLevels x nSessions fraction of each stimulus's
%                  boundary-ribbon pixels outside the displayable range.
%
%   The edge-power file path does not exist anywhere on disk, so this function
%   cannot currently run; the real files are under the repo's own
%   data/edge_powers/ (B2.1, fixed structurally by S3.2).
%
%   The parfor writes only sliced outputs, so worker order cannot change any
%   result. seeds is read and written back unchanged inside the loop, which is
%   a leftover from when the seed was drawn there.
%
%   See also experiment.SESSIONSETTINGS, experiment.GENERATETARGETPRESENTMATRIX,
%   lib.STIMULUS, lib.COMPUTE_PCLIPPED.

    load(['vislab-common/data/edge_powers/', exp_type, '.mat'], 'edge_powers')
    [~, ~, ~, mask_strip] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);
    nLevels = size(edgePowerBlockEdges, 1);
    stimuli = zeros(bg_size, bg_size, nTrials, nLevels, nSessions);
    % seeds=zeros(nTrials,nLevels,nSessions);
    seeds = nan(nTrials*nSessions, nLevels);
    edgePowers = zeros(nTrials, nLevels, nSessions);
    pClipped = zeros(nTrials, nLevels, nSessions);

    % convert bTargetPresent to 1 page
    bTarget = permute(bTargetPresent, [1 3 2]);
    bTarget = reshape(bTarget, [], size(bTargetPresent, 2), 1);

    % sample all blank seeds
    seeds(~bTarget) = randsample(size(edge_powers, 1), sum(~bTarget(:)));

    % sample target seeds
    for iLevel = 1:nLevels
        seeds_available = find((edge_powers(:, 2) >= edgePowerBlockEdges(iLevel, 1)) & ...
            (edge_powers(:, 2) <= edgePowerBlockEdges(iLevel, 2)));
        seeds(bTarget(:, iLevel), iLevel) = randsample(seeds_available, nnz(bTarget(:, iLevel)));
    end

    % split seeds matrix into pages for separate sessions
    seeds = permute(seeds, [2 1]);
    seeds = reshape(seeds, [nLevels nTrials nSessions]);
    seeds = permute(seeds, [2 1 3]);

    % generate stimuli images
    for iLevel = 1:nLevels
        for iSession = 1:nSessions
            parfor iTrial = 1:nTrials
                fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
                if bTargetPresent(iTrial, iLevel, iSession) % if this is a with-target stimulus
                    % seed=randsample(seeds_available,1);
                    seed = seeds(iTrial, iLevel, iSession);
                    edgePowers(iTrial, iLevel, iSession) = edge_powers(seed, 2);
                    stim = lib.stimulus('texture', texture, 'seed', seed, 'bg_size', bg_size, ...
                        'target_radius', target_radius, 'ml_b', luminance, 'cont_b', contrast);
                else % if this is a without-target stimulus
                    %  seed=randi([1 size(edge_powers,1)]); % randomly pick from all seeds
                    seed = seeds(iTrial, iLevel, iSession);
                    edgePowers(iTrial, iLevel, iSession) = edge_powers(seed, 1);
                    stim = lib.stimulus('texture', texture, 'seed', seed, 'bg_size', bg_size, ...
                        'ml_b', luminance, 'cont_b', contrast);
                end
                seeds(iTrial, iLevel, iSession) = seed;
                stimuli(:, :, iTrial, iLevel, iSession) = stim;
                pClipped(iTrial, iLevel, iSession) = lib.compute_pClipped(stim(mask_strip));
            end
        end
        %else
        %fprintf('Cannot choose %d from %d available stimuli in level %d\n',[nTrials,length(seeds_energies_available),iLevel]);
        %break
        %end
    end
end
