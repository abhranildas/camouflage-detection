function [P, PcoordsRC] = cropImage(I,PcoordsRC,patchSize,indColorChannels, bCenter)
%CROPIMAGE Crops patch from image based input coordinates in row-column form 
%
% Example: 
%   [P PcoordsRC] = lib.CROPIMAGE(I,[475 1625],[128 128]); imagesc(P(:,:,1))
%
% Output:   
%   P:          cropped patch
%   PcoordsRC:  row and column indices corresponding to patch location
%
% Steve Sebastian, Johannes Burge

if length(patchSize) == 1
    patchSize = [patchSize patchSize];
end

if ~exist('PcoordsRC','var') || isempty(PcoordsRC)
   PcoordsRC(1) = floor((size(I,1) - patchSize(1))/2 + 1);
   PcoordsRC(2) = floor((size(I,1) - patchSize(2))/2 + 1);
end
if ~exist('indColorChannel','var') || isempty(indColorChannels)
   indColorChannels = 1:size(I,3); 
end
if ~exist('bCenter','var') || isempty(bCenter)
   bCenter = 0; 
end

if(bCenter)
    rowRange = (PcoordsRC(1,1) - floor(patchSize(1)./2)):(PcoordsRC(1,1) + ceil(patchSize(1)./2) - 1);
    colRange = (PcoordsRC(1,2) - floor(patchSize(2)./2)):(PcoordsRC(1,2) + ceil(patchSize(2)./2) - 1);
    P = I(rowRange, colRange, indColorChannels);
else
    P = I(PcoordsRC(1,1):(PcoordsRC(1,1)+patchSize(2)-1), ...
        PcoordsRC(1,2):(PcoordsRC(1,2)+patchSize(1)-1), ...
        indColorChannels);
end;