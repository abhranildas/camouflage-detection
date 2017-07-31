function cosWin = cosWindow2(winSize,winFactor,bPLOT)
%COSWINDOW2 Creates a 2D cosine window
%
% Example: 
%   cosWin = lib.COSWINDOW2([101 101], 1, 1);
% 
% Output:
%   cosWin:  2D cosine window
%
%   See also COSDRADIAL, COSWINDOWFLATTOP2.
% 
% v1.0 Johannes Burge

%% Input handlign
if ~exist('winFactor','var') || isempty(winFactor)
   winFactor = 1; 
end
if ~exist('bPLOT','var')
   bPLOT = 0; 
end
if length(winSize) == 1
   winSize = repmat(winSize,1,2); 
end
winSizeMin = min(winSize);

% Check for legal values of winFactor
if rem(1,winFactor) ~= 0
   error(['cosWindow: winFactor must divide zero evenly. Current value = ' num2str(winFactor)]);
end

if mod(winSizeMin,2) == 0 %Even
    pos = (-winSizeMin/2):(winSizeMin/2-1);  
elseif mod(winSizeMin,2) == 1 %Odd
    pos = (-(winSizeMin-1)/2):((winSizeMin-1)/2);
end

%%

[xx, yy] = meshgrid(pos);
rr = sqrt(xx.^2 + yy.^2);
hannWinRadius = max(abs(xx(:))).*winFactor;

cosWin = lib.cosdRadial(xx,yy,.5/hannWinRadius,.5,.5,0);

cosWin(rr >= hannWinRadius) = 0;

if bPLOT
    figure; surf(cosWin,'edgecolor','none'); title('Cosine Window','fontsize',15);
    axis tight; box on; zlim([0 1])
end