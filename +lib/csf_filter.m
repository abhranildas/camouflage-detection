function img_fil=csf_filter(img,ppd)
% filters an image with the human CSF

bg_size=size(img,1);

% array of frequencies (cyc/deg)
f = ones(bg_size);
for i=1:bg_size
    for j=1:bg_size
        f(i,j)=norm([i-bg_size/2-1,j-bg_size/2-1]); % cyc/img
    end
end
f=f*ppd/bg_size; % cyc/deg

% CSF
csf_fil=lib.csf_fitted(f);
csf_fil=csf_fil/max(csf_fil(:));
csf_fil(bg_size/2+1,bg_size/2+1)=1; % leave DC unchanged

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
img_f = fftshift(fft2(img));

% multiply with CSF filter
img_f_fil = csf_fil.*img_f;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
img_fil = ifft2(ifftshift(img_f_fil));