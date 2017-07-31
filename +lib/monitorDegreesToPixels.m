function posPix = monitorDegreesToPixels(posDeg, monitorSize, pixPerDeg)
%MONITORDEGREESTOPIXELS Convert a position in degrees to pixels (center is
% at 0,0).
%
% Example: 
%   posPix = MONITORDEGREESTOPIXELS(ImgStats)
%   
% Outout: 
%   posPix  Absolute position in pixels
%
% v1.0, 1/19/2016, Steve Sebastian <sebastian@utexas.edu>

%% 
% Point in the center is (0,0)
zeroPointPix = round(monitorSize./2);

posPixRelative = posDeg.*pixPerDeg;

posPix(:,:,1) = zeroPointPix(1) + posPixRelative(:,:,1); 
posPix(:,:,2) = zeroPointPix(2) + posPixRelative(:,:,2); 