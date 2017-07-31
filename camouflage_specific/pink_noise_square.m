function img_1f=pink_noise_square(size)
% creates a square image on pink noise of given size

% create 1/f Fourier filter
fil1f = zeros(size);
for i=1:size
    for j=1:size
        z=norm([i-size/2-1,j-size/2-1]);
        if z  % leave fft origin at 0
            fil1f(i,j) = 1/z;
        end
    end
end
% make 1/f noise image
wn = normrnd(0,1,size);                  % white noise image
wnf = fftshift(fft2(fftshift(wn)));         % fourier transform image
wnf = fil1f.*wnf;                           % apply 1/f fourier filter
img_1f = ifftshift(ifft2(ifftshift(wnf)));  % inverse fourier transform
