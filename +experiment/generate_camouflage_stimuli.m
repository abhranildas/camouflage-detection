function [stimuli, seeds, stim_edge_powers, p_clipped] = generate_camouflage_stimuli(texture, ...
    exp_type, edge_power_block_edges, n_trials, n_sessions, bg_size, target_radius, luminance, ...
    contrast, b_target_present)
% GENERATE_CAMOUFLAGE_STIMULI  Synthesise one experiment's camouflage stimuli.
%   [stimuli, seeds, stim_edge_powers, p_clipped] = experiment.generate_camouflage_stimuli(...
%       texture, exp_type, edge_power_block_edges, n_trials, n_sessions, bg_size, ...
%       target_radius, luminance, contrast, b_target_present)
%
%   A level is a band of target edge power, so choosing a level means choosing
%   a seed whose precomputed edge power falls in that band. Target-present
%   trials draw their seeds, without replacement, from the seeds whose edge
%   power lies inside the level's band; blank trials draw from all seeds. Each
%   seed is then handed to lib.stimulus, which reseeds the generator with it,
%   so a stimulus is fully determined by its seed plus these parameters.
%
%   Inputs
%     texture                - texture struct passed straight to lib.stimulus
%                              (.type, and .stats/.Niter for a Portilla-Simoncelli
%                              texture).
%     exp_type               - experiment name, selecting the edge-power file.
%     edge_power_block_edges - n_levels x 2 array of [lower, upper] edge-power
%                              limits per level, dimensionless edge power.
%     n_trials               - trials per level per session, count.
%     n_sessions             - sessions, count.
%     bg_size                - stimulus side, in pixels.
%     target_radius          - target radius, in pixels.
%     luminance              - mean luminance, normalised, in [0, 1].
%     contrast               - RMS contrast, dimensionless fraction.
%     b_target_present       - n_trials x n_levels x n_sessions logical, which
%                              trials contain a target.
%
%   Output
%     stimuli          - bg_size x bg_size x n_trials x n_levels x n_sessions array in
%                        normalised luminance units.
%     seeds            - n_trials x n_levels x n_sessions RNG seeds, also the row index
%                        into the edge-power table.
%     stim_edge_powers - n_trials x n_levels x n_sessions edge power of each stimulus,
%                        dimensionless. Column 2 of the table for a target trial,
%                        column 1 for a blank.
%     p_clipped        - n_trials x n_levels x n_sessions fraction of each stimulus's
%                        boundary-ribbon pixels outside the displayable range.
%
%   The edge-power file comes from cfg.paths.edge_powers, i.e. this repo's own
%   data/edge_powers/ (S2.2, which resolved B2.1 — the path used to be a
%   cwd-relative literal naming a directory that has never existed).
%
%   The parfor writes only sliced outputs, so worker order cannot change any
%   result. seeds is read and written back unchanged inside the loop, which is
%   a leftover from when the seed was drawn there.
%
%   See also experiment.SESSION_SETTINGS, experiment.GENERATE_TARGET_PRESENT_MATRIX,
%   lib.STIMULUS, lib.COMPUTE_P_CLIPPED.

    cfg = config();
    load(fullfile(cfg.paths.edge_powers, [exp_type, '.mat']), 'edge_powers')
    [~, ~, ~, mask_strip] = lib.target_mask('bg_size', bg_size, 'target_radius', target_radius);
    n_levels = size(edge_power_block_edges, 1);
    stimuli = zeros(bg_size, bg_size, n_trials, n_levels, n_sessions);
    % seeds=zeros(n_trials,n_levels,n_sessions);
    seeds = nan(n_trials*n_sessions, n_levels);
    stim_edge_powers = zeros(n_trials, n_levels, n_sessions);
    p_clipped = zeros(n_trials, n_levels, n_sessions);

    % convert b_target_present to 1 page
    b_target = permute(b_target_present, [1 3 2]);
    b_target = reshape(b_target, [], size(b_target_present, 2), 1);

    % sample all blank seeds
    seeds(~b_target) = randsample(size(edge_powers, 1), sum(~b_target(:)));

    % sample target seeds
    for i_level = 1:n_levels
        seeds_available = find((edge_powers(:, 2) >= edge_power_block_edges(i_level, 1)) & ...
            (edge_powers(:, 2) <= edge_power_block_edges(i_level, 2)));
        seeds(b_target(:, i_level), i_level) = ...
            randsample(seeds_available, nnz(b_target(:, i_level)));
    end

    % split seeds matrix into pages for separate sessions
    seeds = permute(seeds, [2 1]);
    seeds = reshape(seeds, [n_levels n_trials n_sessions]);
    seeds = permute(seeds, [2 1 3]);

    % generate stimuli images
    for i_level = 1:n_levels
        for i_session = 1:n_sessions
            parfor i_trial = 1:n_trials
                fprintf('Level %d Session %d Trial %d\n', [i_level i_session i_trial])
                if b_target_present(i_trial, i_level, i_session) % if this is a with-target stimulus
                    % seed=randsample(seeds_available,1);
                    seed = seeds(i_trial, i_level, i_session);
                    stim_edge_powers(i_trial, i_level, i_session) = edge_powers(seed, 2);
                    stim = lib.stimulus('texture', texture, 'seed', seed, 'bg_size', bg_size, ...
                        'target_radius', target_radius, 'ml_b', luminance, 'cont_b', contrast);
                else % if this is a without-target stimulus
                    %  seed=randi([1 size(edge_powers,1)]); % randomly pick from all seeds
                    seed = seeds(i_trial, i_level, i_session);
                    stim_edge_powers(i_trial, i_level, i_session) = edge_powers(seed, 1);
                    stim = lib.stimulus('texture', texture, 'seed', seed, 'bg_size', bg_size, ...
                        'ml_b', luminance, 'cont_b', contrast);
                end
                seeds(i_trial, i_level, i_session) = seed;
                stimuli(:, :, i_trial, i_level, i_session) = stim;
                p_clipped(i_trial, i_level, i_session) = lib.compute_p_clipped(stim(mask_strip));
            end
        end
        %else
        %fprintf('Cannot choose %d from %d available stimuli in level %d\n',[n_trials,length(seeds_energies_available),i_level]);
        %break
        %end
    end
end
