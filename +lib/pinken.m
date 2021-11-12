function img_w=pinken(img)
% reverses a square pink noise image to find the white noise
% square that it was created from.

bg_size=size(img,1);

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

img_fft=fftshift(fft2(img));
img_w_fft=img_fft.*fil_1f; % multiply by 1/f filter
img_w=ifft2(ifftshift(img_w_fft));