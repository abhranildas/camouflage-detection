function PcoordsRC = samplePatchCoordinates(Isize,Psize,patchSpacing,numPatches)
%SAMPLEPATCHCOORDINATES Returns spaces coordinates across an image
%
% Example: 
%   Return all coordinates with 128 spacing between them
%		PCoordsRC = lib.SAMPLEPATCHCOORDINATES(size(I), size(P), 128);
%
%	Return 10 coordinates sampled from all patches with 128 pixel spacing
%		PCoordsRC = lib.SAMPLEPATCHCOORDINATES(size(I), size(P), 128, 10);
%		
%   [imgOut, percentClupped] = lib.EMBEDIMAGEINCENTER(I, T, 1, 8, 0, 0);
% 
% Output:   
%	PcoordsRC:    row and column indices corresponding to patch location
%
% Johannes Burge

% 1/2 patch width zone in which images are not selected
PcrdsRlims = [1+round(Psize(1)/2) Isize(1)-ceil(3*Psize(1)/2)+1]; 
PcrdsClims = [1+round(Psize(2)/2) Isize(2)-ceil(3*Psize(2)/2)+1];
[PcrdsR, PcrdsC] = meshgrid(PcrdsRlims(1):patchSpacing:PcrdsRlims(2), ...
                           PcrdsClims(1):patchSpacing:PcrdsClims(2));

% Patch coordinates                  
PcoordsRC = [PcrdsR(:) PcrdsC(:)];


if exist('numPatches','var') && ~isempty(numPatches)
   indP      = randsample(size(PcoordsRC,1),numPatches); 
   PcoordsRC = PcoordsRC(indP,:);
end