function [template_sigma, small_sample] = compute_template_response_sigma(ImgStats, ...
    target_type_str, b_scale)
%COMPUTE_TEMPLATE_RESPONSE_SIGMA  Per-bin sd of template-match response, across one or more targets.
%
%   [template_sigma, small_sample] = ...
%       experiment.analysis.COMPUTE_TEMPLATE_RESPONSE_SIGMA(ImgStats, ...
%       target_type_str, b_scale)
%
% For each (luminance, contrast, similarity) bin, the sd of
% ImgStats.tMatch over the patches indexed by ImgStats.patchIndex, optionally
% scaled down by each target's own energy.
%
% B3.4 (pre-existing, not fixed here): the size(...) at the small_sample
% guard below should be numel(...), and the i_similarity loop bound should be
% size(template_sigma,3), not size(template_sigma,1) — possibly harmless if
% those dimensions happen to match, unverified.
%
% Inputs
%   ImgStats        image-statistics struct, as built by the (out-of-scope,
%                   excluded) +stats/ package
%   target_type_str   target identifier, passed to lib.target_index_from_string
%   b_scale          true to divide each target's response sd by its own
%                   energy sum(target(:).^2)
%
% Output
%   template_sigma   sd of template-match response, size(patch_index{1}) x
%                   n_targets (or size(patch_index{1}) if n_targets == 1)
%   small_sample     1 where the corresponding bin has fewer than 300
%                   patches, same size as template_sigma
%
%   See also LIB.TARGET_INDEX_FROM_STRING, EXPERIMENT.ANALYSIS.COMPUTE_THRESHOLDS_VS_STATISTIC.

target_index = lib.target_index_from_string(ImgStats.Settings, target_type_str);

n_targets = size(target_index, 2);

for i_target = 1:n_targets
    if(n_targets == 1)
        target_index_curr = target_index;
    else
        target_index_curr = target_index(i_target);
    end
    patch_index{i_target} = ImgStats.patchIndex{target_index_curr};
    t_match(:, :, i_target) = ImgStats.tMatch(:, :, target_index_curr);
    if(b_scale)
        target_curr = ImgStats.Settings.targets(:, :, target_index_curr);
        scale_factor(i_target) = sum(target_curr(:).*target_curr(:));
    else
        scale_factor(i_target) = 1;
    end
end

if(n_targets > 1)
    template_sigma = zeros([size(patch_index{1}), n_targets]);
    small_sample = zeros([size(patch_index{1}), n_targets]);
else
    template_sigma = zeros(size(patch_index{1}));
    small_sample = zeros(size(patch_index{1}));
end

for i_target = 1:n_targets
    if(n_targets > 1)
        patch_index_curr = patch_index{i_target};
        t_match_curr = t_match(:, :, i_target);
    else
        patch_index_curr = patch_index{1};
        t_match_curr = t_match;
    end

    for i_luminance = 1:size(template_sigma, 1)
        for i_contrast = 1:size(template_sigma, 2)
            for i_similarity = 1:size(template_sigma, 1)
                template_sigma(i_luminance, i_contrast, i_similarity, i_target) = ...
                    std(t_match_curr(patch_index_curr{i_luminance, i_contrast, ...
                    i_similarity})) ./ ...
                    scale_factor(i_target);
                if(size(patch_index_curr{i_luminance, i_contrast, i_similarity} < 300))
                    small_sample(i_luminance, i_contrast, i_similarity, i_target) = 1;
                end
            end
        end
    end
end
end
