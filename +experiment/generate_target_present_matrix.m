function b_present = generate_target_present_matrix(n_trials, n_levels, n_blocks, p_target, ...
    b_independent)
% GENERATE_TARGET_PRESENT_MATRIX  Draw which trials of an experiment contain a target.
%   b_present = experiment.generate_target_present_matrix(n_trials, n_levels, n_blocks)
%   b_present = experiment.generate_target_present_matrix(n_trials, n_levels, n_blocks, ...
%       p_target, b_independent)
%
%   Two sampling rules. Independent: each trial is target-present with
%   probability p_target, so the count per level varies. Not independent:
%   exactly round(n_trials*p_target) trials per level are target-present, and
%   their positions within the level are shuffled.
%
%   Inputs
%     n_trials      - trials per level, count.
%     n_levels      - levels (edge-power blocks) per session, count.
%     n_blocks      - sessions, count. Named blocks here and sessions in the
%                     callers; both index the same third dimension.
%     p_target      - probability that a trial is target-present,
%                     dimensionless, in [0, 1]. Default 0.5.
%     b_independent - true to draw each trial independently, false to fix the
%                     per-level count exactly. Default true.
%
%   Output
%     b_present - n_trials x n_levels x n_blocks array of 0/1 doubles (not
%                 logical; every caller wraps the result in logical()).
%
%   See also experiment.SESSION_SETTINGS, experiment.GENERATE_CAMOUFLAGE_STIMULI.

    %% Check input
    if(nargin < 4)
        p_target = 0.5;
    end

    if(nargin < 5)
        b_independent = 1;
    end

    %% Create the matrix in the format n_trials x n_levels x n_blocks
    if(b_independent) % Probability of target present is p_target on each trial
        b_present = binornd(1, p_target, [n_trials, n_levels, n_blocks]);
    else % Number of target present trials is n_levels * p_target
        b_present = zeros(n_trials, n_levels, n_blocks);
        n_target_present = round(n_trials*p_target);
        b_present(1:n_target_present, :, :) = 1;

        %% Shuffle each column of the matrix
        for i_level = 1:n_levels
            for i_block = 1:n_blocks
                b_present(:, i_level, i_block) = b_present(randperm(n_trials), i_level, i_block);
            end
        end
    end
end
