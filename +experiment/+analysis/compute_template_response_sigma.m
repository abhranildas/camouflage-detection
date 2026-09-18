function [templateSigma, smallSample] = compute_template_response_sigma(ImgStats, ...
    targetTypeStr, bScale)
%COMPUTE_TEMPLATE_RESPONSE_SIGMA  Per-bin sd of template-match response, across one or more targets.
%
%   [templateSigma, smallSample] = ...
%       experiment.analysis.COMPUTE_TEMPLATE_RESPONSE_SIGMA(ImgStats, ...
%       targetTypeStr, bScale)
%
% For each (luminance, contrast, similarity) bin, the sd of
% ImgStats.tMatch over the patches indexed by ImgStats.patchIndex, optionally
% scaled down by each target's own energy.
%
% B3.4 (pre-existing, not fixed here): the size(...) at the smallSample
% guard below should be numel(...), and the iSimilarity loop bound should be
% size(templateSigma,3), not size(templateSigma,1) — possibly harmless if
% those dimensions happen to match, unverified.
%
% Inputs
%   ImgStats        image-statistics struct, as built by the (out-of-scope,
%                   excluded) +stats/ package
%   targetTypeStr   target identifier, passed to lib.target_index_from_string
%   bScale          true to divide each target's response sd by its own
%                   energy sum(target(:).^2)
%
% Output
%   templateSigma   sd of template-match response, size(patchIndex{1}) x
%                   n_targets (or size(patchIndex{1}) if n_targets == 1)
%   smallSample     1 where the corresponding bin has fewer than 300
%                   patches, same size as templateSigma
%
%   See also LIB.TARGET_INDEX_FROM_STRING, EXPERIMENT.ANALYSIS.COMPUTE_THRESHOLDS_VS_STATISTIC.

targetIndex = lib.target_index_from_string(ImgStats.Settings, targetTypeStr);

nTargets = size(targetIndex, 2);

for iTarget = 1:nTargets
    if(nTargets == 1)
        targetIndexCurr = targetIndex;
    else
        targetIndexCurr = targetIndex(iTarget);
    end
    patchIndex{iTarget} = ImgStats.patchIndex{targetIndexCurr};
    tMatch(:, :, iTarget) = ImgStats.tMatch(:, :, targetIndexCurr);
    if(bScale)
        targetCurr = ImgStats.Settings.targets(:, :, targetIndexCurr);
        scaleFactor(iTarget) = sum(targetCurr(:).*targetCurr(:));
    else
        scaleFactor(iTarget) = 1;
    end
end

if(nTargets > 1)
    templateSigma = zeros([size(patchIndex{1}), nTargets]);
    smallSample = zeros([size(patchIndex{1}), nTargets]);
else
    templateSigma = zeros(size(patchIndex{1}));
    smallSample = zeros(size(patchIndex{1}));
end

for iTarget = 1:nTargets
    if(nTargets > 1)
        patchIndexCurr = patchIndex{iTarget};
        tMatchCurr = tMatch(:, :, iTarget);
    else
        patchIndexCurr = patchIndex{1};
        tMatchCurr = tMatch;
    end

    for iLuminance = 1:size(templateSigma, 1)
        for iContrast = 1:size(templateSigma, 2)
            for iSimilarity = 1:size(templateSigma, 1)
                templateSigma(iLuminance, iContrast, iSimilarity, iTarget) = ...
                    std(tMatchCurr(patchIndexCurr{iLuminance, iContrast, iSimilarity})) ./ ...
                    scaleFactor(iTarget);
                if(size(patchIndexCurr{iLuminance, iContrast, iSimilarity} < 300))
                    smallSample(iLuminance, iContrast, iSimilarity, iTarget) = 1;
                end
            end
        end
    end
end
end
