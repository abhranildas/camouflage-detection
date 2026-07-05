function Z = cosdRadial(Xdeg,Ydeg,freqCycDeg,amp,dc,bPLOT)
%COSDRADIAL Radially symmetric cosine with specified frequency at locations Xdeg, Ydeg
%
% Example: 
%   Return all coordinates with 128 spacing between them
%		[X Y] = meshgrid(linspace(-180,180));
%		Z = lib.COSDRADIAL(X,Y,3,1);
%
% radially symmetric cosine with specified frequency at locations Xdeg, Ydeg
%
% Output:   
%	Z:	height of cosine
%
% Johannes Burge


if ~exist('bPLOT')
   bPLOT = 0; 
end

phi = 0;
Z = amp.*cosd(360.*freqCycDeg.*sqrt(Xdeg.^2 + Ydeg.^2) + phi) + dc; 


if bPLOT == 1
    figure('position',[193   944   646   338]); subplot(1,2,1);
    imagesc(Xdeg(1,:),Ydeg(:,1)',Z); 
    axis square;
    
    subplot(1,2,2); 
    surf(Xdeg(1,:),Ydeg(:,1)',Z,'edgecolor','none');
    axis square; box on 
    
    colormap gray
end