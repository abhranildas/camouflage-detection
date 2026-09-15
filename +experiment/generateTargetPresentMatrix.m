function bPresent = generateTargetPresentMatrix(nTrials, nLevels, nBlocks, pTarget, bIndependent)
% GENERATETARGETPRESENTMATRIX  Draw which trials of an experiment contain a target.
%   bPresent = experiment.generateTargetPresentMatrix(nTrials, nLevels, nBlocks)
%   bPresent = experiment.generateTargetPresentMatrix(nTrials, nLevels, nBlocks, ...
%       pTarget, bIndependent)
%
%   Two sampling rules. Independent: each trial is target-present with
%   probability pTarget, so the count per level varies. Not independent:
%   exactly round(nTrials*pTarget) trials per level are target-present, and
%   their positions within the level are shuffled.
%
%   Inputs
%     nTrials      - trials per level, count.
%     nLevels      - levels (edge-power blocks) per session, count.
%     nBlocks      - sessions, count. Named blocks here and sessions in the
%                    callers; both index the same third dimension.
%     pTarget      - probability that a trial is target-present,
%                    dimensionless, in [0, 1]. Default 0.5.
%     bIndependent - true to draw each trial independently, false to fix the
%                    per-level count exactly. Default true.
%
%   Output
%     bPresent - nTrials x nLevels x nBlocks array of 0/1 doubles (not
%                logical; every caller wraps the result in logical()).
%
%   See also experiment.SESSIONSETTINGS, experiment.GENERATE_CAMOUFLAGE_STIMULI.

    %% Check input
    if(nargin < 4)
        pTarget = 0.5;
    end

    if(nargin < 5)
        bIndependent = 1;
    end

    %% Create the matrix in the format nTrials x nLevels x nBlocks
    if(bIndependent) % Probability of target present is pTarget on each trial
        bPresent = binornd(1, pTarget, [nTrials, nLevels, nBlocks]);
    else % Number of target present trials is nLevels * pTarget
        bPresent = zeros(nTrials, nLevels, nBlocks);
        nTargetPresent = round(nTrials*pTarget);
        bPresent(1:nTargetPresent, :, :) = 1;

        %% Shuffle each column of the matrix
        for iLevel = 1:nLevels
            for iBlock = 1:nBlocks
                bPresent(:, iLevel, iBlock) = bPresent(randperm(nTrials), iLevel, iBlock);
            end
        end
    end
end
