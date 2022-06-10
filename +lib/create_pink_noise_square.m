function [img_1f,wn]=create_pink_noise_square(bg_size,exponent)
% creates a square image of pink noise of given size

if ~exist('exponent','var')
    exponent=1;
end

% create 1/f Fourier filter.
fil_1f = ones(bg_size);
for i=1:bg_size
    for j=1:bg_size
        z=norm([i-bg_size/2-1,j-bg_size/2-1]);
        if z  % leave fft origin at 1
            fil_1f(i,j) = z^(-exponent);
        end
    end
end
% white noise image:
wn = normrnd(0,1,bg_size);

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
wnf = fftshift(fft2(wn));

% multiply with 1/f filter
wnf_fil = fil_1f.*wnf;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
img_1f = ifft2(ifftshift(wnf_fil));