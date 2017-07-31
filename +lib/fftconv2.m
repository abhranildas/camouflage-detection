function C = fftconv2(A,B)
%FFTCONV2 Calculate 2D convolution of A and B using fft2
%
% Example: 
%   C = lib.FFTCONV2(A,B)
% 
% Output:
%   C:	Convolution of A and B. Has same size as biggest input (A or B)
%   percentClipped: If bAdditive == 1, the % of clipped pixels
%
% YC at ES lab
% Created on Sep. 29, 2009
% Last modified on Oct. 1, 2009

%% Check inputs and/or outputs
[nYA,nXA] = size(A);
[nYB,nXB] = size(B);

%% Convolution
tFFTA = zeros(nYA+nYB-1,nXA+nXB-1);
tFFTB = zeros(nYA+nYB-1,nXA+nXB-1);

tFFTA(1:nYA,1:nXA) = A;
tFFTB(1:nYB,1:nXB) = B;

tConv = ifft2(fft2(tFFTA).*fft2(tFFTB));

% return region size from larger input
% 1. Y dimension
if(nYA > nYB)
    y_range = (1:nYA) + floor(nYB/2);
else
    y_range = (1:nYB) + floor(nYA/2);
end
% 2. X dimension
if(nXA > nXB)
    x_range = (1:nXA) + floor(nXB/2);
else
    x_range = (1:nXB) + floor(nXA/2);
end

C = tConv(y_range, x_range);


