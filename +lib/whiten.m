function img_wn=whiten(img_1f)
% reverses a square pink noise image to find the white noise
% square that it was created from.

bg_size=size(img_1f,1);

% create 1/f Fourier filter.
fil_1f = ones(bg_size);
for i=1:bg_size
    for j=1:bg_size
        z=norm([i-bg_size/2-1,j-bg_size/2-1]);
        if z  % leave fft origin at 1
            fil_1f(i,j) = 1/z;
        end
    end
end

wnf_fil_reverse=fftshift(fft2(img_1f));
wnf_reverse=wnf_fil_reverse./fil_1f; % divide by 1/f filter
img_wn=ifft2(ifftshift(wnf_reverse));