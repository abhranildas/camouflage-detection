function ImgStats = binImageStats(ImgStats, bSpatialSim)
%BINIMAGESTATS Bin image statistics and add to structure (using different
%stimilarity metrics
%
% Example: 
%   ImgStats = BINIMAGESTATS(ImgStats, 0)
%   
%   See also COMPUTEIMAGESTATS.
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>

if(nargin < 2)
    bSpatialSim = 0;
end

binEdges = ImgStats.Settings.binEdges;

if(bSpatialSim)
    binEdges.S = ImgStats.Settings.binEdges.Ss;
    Sim = ImgStats.Ss;
else
    binEdges.S = ImgStats.Settings.binEdges.Sa;
    Sim = ImgStats.Sa;
end

nBins = size(binEdges.L,2) - 1;
nTargets = size(ImgStats.Settings.targets,3);

patchIndex = cell(nTargets,1);

for iTar = 1:nTargets
    patchIndex{iTar} = cell(nBins,nBins,nBins);
    for iLum = 1:nBins    
        disp(num2str(iLum));
        for iCon = 1:nBins
            for iSim = 1:nBins
                S = Sim(:,:,iTar);
                patchIndex{iTar}{iLum,iCon,iSim} = ...
                 find(ImgStats.L(:) > binEdges.L(iLum) & ImgStats.L(:) <= binEdges.L(iLum+1) ...
                    & ImgStats.C(:) > binEdges.C(iCon) & ImgStats.C(:) <= binEdges.C(iCon+1) ...
                    & S(:) > binEdges.S(iSim,iTar) & S(:) <= binEdges.S(iSim+1,iTar));
            end
        end
    end
end

if(bSpatialSim)
    ImgStats.patchIndexSs = patchIndex;
else
    ImgStats.patchIndex = patchIndex;
end