function [tSigma, smallSample] = computeTemplateResponseSigma(ImgStats, targetTypeStr, bScale)

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,targetTypeStr);

nTargets = size(targetIndex,2);

for iTar = 1:nTargets
    if(nTargets == 1)
        targetIndexCurr = targetIndex;
    else
        targetIndexCurr = targetIndex(iTar);
    end
    patchIndex{iTar} = ImgStats.patchIndex{targetIndexCurr};
    tMatch(:,:,iTar) = ImgStats.tMatch(:,:,targetIndexCurr);
    if(bScale)
        targetCurr = ImgStats.Settings.targets(:,:,targetIndexCurr);
        scaleFactor(iTar) = sum(targetCurr(:).*targetCurr(:));
    else
        scaleFactor(iTar) = 1;
    end
end

if(nTargets > 1)
    tSigma = zeros([size(patchIndex{1}), nTargets]);
    smallSample = zeros([size(patchIndex{1}), nTargets]);
else
    tSigma = zeros(size(patchIndex{1}));
    smallSample = zeros(size(patchIndex{1}));
end

for iTar = 1:nTargets
    if(nTargets > 1)
        patchIndexCurr = patchIndex{iTar};
        tMatchCurr = tMatch(:,:,iTar);
    else
        patchIndexCurr = patchIndex{1};
        tMatchCurr = tMatch;
    end
    
    for iLum = 1:size(tSigma,1)
        for iCon = 1:size(tSigma,2)
            for iSim = 1:size(tSigma,1)
                tSigma(iLum, iCon, iSim,iTar) = std(tMatchCurr(patchIndexCurr{iLum, iCon, iSim}))./scaleFactor(iTar);
                if(size(patchIndexCurr{iLum, iCon, iSim} < 300))
                    smallSample(iLum, iCon, iSim,iTar) = 1;
                end
            end
        end
    end
end
