% compute_edge_group_measures  Compute per-trial contour-group edge measures
%     for every stimulus in an experiment and store them back onto
%     `ExpSettings`.
%
%     compute_edge_group_measures
%
% Script, no arguments. Expects `ExpSettings` (with `.nTrials`, `.nLevels`,
% `.nSessions`, `.stimuli`) already in the workspace.
%
% BUG (B1.5, re-confirmed on reading): `lib.edge` no longer returns
% contour-group outputs — its third and fourth outputs are now
% `target_edge_field` (a rows x cols field) and `theta_grid` (a 1 x n_edge
% angle grid), not the lengths/energies this script's `l_groups`/
% `e_groups` names still claim. No error is raised; this would silently
% store the wrong data if re-run. Names left as found — renaming them to
% their true content would erase the evidence. The `stim_n_groups`
% fragments below (a third, group-count output) are dead for the same
% reason: `lib.edge` dropped that output entirely upstream.
%
% NOTE: `parfor` here writes into `stim_l_groups{iTrial,iLevel,iSession}`/
% `stim_e_groups{...}`, sliced by the loop variable `iSession` — a safe
% sliced output, not a reduction, so worker order cannot affect the result.
%
% TODO (pre-existing, line 4 below): rename `stimuliSeed` to `seeds`
% somewhere upstream; left as found, not touched by this pass.
%
% Inputs: workspace `ExpSettings` struct, as above.
% Output: `ExpSettings.stim_l_groups`, `ExpSettings.stim_e_groups` (see the
%     bug note above for what they actually hold). Nothing saved to disk.
%
% See also lib.edge.

% compute edge group measures for the stimuli in an experiment

% load ExpSettings
% RENAME stimuliSeed to seeds

n_edge = 1e3;  % # of points in the edge vector

n_trials = ExpSettings.nTrials;
n_levels = ExpSettings.nLevels;
n_sessions = ExpSettings.nSessions;

% stim_n_groups=nan(n_trials,n_levels,n_sessions);
stim_l_groups = cell(n_trials, n_levels, n_sessions);
stim_e_groups = cell(n_trials, n_levels, n_sessions);

parfor i_session = 1:n_sessions
    for i_level = 1:n_levels
        for i_trial = 1:n_trials
            stim = ExpSettings.stimuli(:, :, i_trial, i_level, i_session);
            [~, ~, l_groups, e_groups] = lib.edge(stim);
%             stim_n_groups(iTrial,iLevel,iSession)=n_groups;
            stim_l_groups{i_trial, i_level, i_session} = l_groups;
            stim_e_groups{i_trial, i_level, i_session} = e_groups;
            [i_session i_level i_trial]
        end
    end
end

% ExpSettings.stim_n_groups=stim_n_groups;
ExpSettings.stim_l_groups = stim_l_groups;
ExpSettings.stim_e_groups = stim_e_groups;
