function [neg_log_likelihood, p_correct, d_prime_all, responses] = ...
    compute_nll_edge_model(params, edge_model, n_boundary_pixels, subj_id)
% COMPUTE_NLL_EDGE_MODEL  Negative log likelihood of the edge-counting model.
%   [neg_log_likelihood, p_correct, d_prime_all, responses] = ...
%       general.compute_nll_edge_model(params, edge_model, n_boundary_pixels, subj_id)
%
%   Scores a one-parameter edge-counting observer against one subject's data, or
%   against the ideal observer, for use inside an fminsearch/fmincon fit. The
%   observer counts edge pixels along the target boundary and compares that
%   count with what the surrounding texture alone would produce. Its decision
%   variable is the z-score of the observed count under the texture-only
%   binomial model,
%
%       z = (n_edge - n*p) / sqrt(noise_sd^2 + n*p*(1 - p)),
%
%   with n = n_boundary_pixels and p = texture_edge_density. Per level, d' is
%   the difference between the mean target and blank z-scores divided by their
%   mean sd, and predicted accuracy is normcdf(d'/2) — the unbiased
%   two-alternative rate, so response bias is ignored.
%
%   Inputs
%     params            - 1-element vector; params(1) is the internal response
%                         noise sd, in units of edge-pixel counts (so
%                         dimensionless). Values <= 0 return inf, which keeps a
%                         fit inside the feasible region.
%     edge_model        - struct array, one element per experiment, as stored in
%                         vislab-common/data/edge_model.mat. Fields read:
%                         .target (nTrials x nLevels logical, target present),
%                         .n_bdry_edge_pixels (nTrials x nLevels pixel count),
%                         .txtr_edge_density (edge pixels per pixel, in [0, 1]),
%                         .subject_data(subj_id).correct (logical).
%     n_boundary_pixels - length of the boundary ribbon, in pixels.
%     subj_id           - index into .subject_data, or 0 for the ideal observer.
%
%   Outputs
%     neg_log_likelihood - dimensionless. For subj_id > 0, minus the summed
%                          binomial log likelihood of the subject's per-level
%                          correct counts. For subj_id == 0 it is instead minus
%                          the summed mean accuracy, which is an accuracy score
%                          and not a likelihood, despite the function's name.
%     p_correct          - 1 x nLevels predicted proportion correct.
%     d_prime_all        - numel(edge_model) x 1 cell, each cell 1 x nLevels d'.
%     responses          - nTrials x nLevels decision variable (z-score).
%
%   Three of the four outputs are unreliable, recorded as B3.19 and not fixed
%   here: p_correct and responses are overwritten on every pass of the
%   experiment loop, so they hold only the last experiment's values, and
%   p_correct, d_prime_all and responses are all left unassigned on the
%   params(1) <= 0 branch, so a caller asking for them there gets an error.
%
%   The local names n_boundary_edge_pixels and texture_edge_density spell out
%   the abbreviations used elsewhere in the repo (bdry -> boundary, txtr ->
%   texture). The struct fields they are copied from, .n_bdry_edge_pixels and
%   .txtr_edge_density, keep their names, because edge_model.mat on disk
%   carries them. That local-vs-field mismatch is deliberate.
%
%   The only caller anywhere in the tree is +general/_fit_edge_model_old.m, one
%   of the deprecated _-prefixed files, so nothing live reaches this function
%   today.
%
%   See also lib.EDGE_MEASURES.

    noise_sd = params(1);

    if noise_sd > 0
        d_prime_all = cell(numel(edge_model), 1);
        log_likelihood = 0;
        for i_exp = 1:numel(edge_model)
            target_present = edge_model(i_exp).target;
            nTrials = size(target_present, 1);
            nLevels = size(target_present, 2);

            %     n_bdry_pixels=edge_model.n_bdry_pixels;
            n_boundary_edge_pixels = edge_model(i_exp).n_bdry_edge_pixels;
            texture_edge_density = edge_model(i_exp).txtr_edge_density;
            %         responses=cellfun(@(stim) lib.new_edge(stim,'bdry_strip',bdry_strip,'sig_n',sig_n),stimuli);
            edge_count_z = (n_boundary_edge_pixels - n_boundary_pixels*texture_edge_density) ./ ...
                sqrt(noise_sd^2 + ...
                n_boundary_pixels*texture_edge_density.*(1 - texture_edge_density));
            responses = edge_count_z;

            % mean and sd of edge responses for blanks and targets in each level
            response_blank_means = nan(1, nLevels);
            response_blank_sds = nan(1, nLevels);
            response_target_means = nan(1, nLevels);
            response_target_sds = nan(1, nLevels);
            for i_level = 1:nLevels
                responses_this_level = responses(:, i_level);
                responses_blank = responses_this_level(~target_present(:, i_level));
                responses_target = responses_this_level(target_present(:, i_level));
                response_blank_means(i_level) = mean(responses_blank);
                % the added 1 is the response noise, of sd=1
                response_blank_sds(i_level) = sqrt(var(responses_blank) + 1);
                response_target_means(i_level) = mean(responses_target);
                response_target_sds(i_level) = sqrt(var(responses_target) + 1);
            end

            % d'_e
            d_prime = abs(response_target_means - response_blank_means) ./ ...
                ((response_blank_sds + response_target_sds)/2);
            d_prime_all{i_exp} = d_prime;

            % ignoring bias
            p_correct = normcdf(d_prime/2);
            if subj_id == 0  % optimal
                log_likelihood = log_likelihood + mean(p_correct);
            else
                n_correct = sum(edge_model(i_exp).subject_data(subj_id).correct);
                log_likelihood = log_likelihood + sum(log(binopdf(n_correct, nTrials, p_correct)));
            end

            % incorporating bias
            %         p_h=normcdf(d*(1-gamma)/2); % prob. of hits
            %         p_cr=normcdf(d*(1+gamma)/2); % prob. of correct rejection
            %         p_c=(p_h+p_cr)/2; % prob. of correct
            %         ll=sum(log(binopdf(num_hits,num_targets,p_h)))+...
            %             sum(log(binopdf(num_cr,num_blanks,p_cr)));
        end
        neg_log_likelihood = -log_likelihood;
    else
        neg_log_likelihood = inf;
    end
end
