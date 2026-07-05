function [sig_1f,wn]=create_pink_noise_line(len,exponent)
    % creates a 1d pink noise signal
    
    if ~exist('alpha','var')
        exponent=1;
    end
    
    % create 1/f Fourier filter.
    fil_1f = ones(1,len);
    for i=1:len
        z=sqrt(norm(i-len/2-1));
        if z  % leave fft origin at 1
            fil_1f(i) = z^(-exponent);
        end
    end
    % white noise signal:
    wn = normrnd(0,1,[1 len]);
    
    % Fourier transform image, then fftshift to shift 0-frequency
    % to the center of the image, to align with 1/f filter whose
    % 0-frequency is also at the center. Otherwise multiplying
    % them together will not multiply corresponding elements.
    wnf = fftshift(fft(wn));
    
    % multiply with 1/f filter
    wnf_fil = fil_1f.*wnf;
    
    % ifftshift to first shift back the fourier transform
    % to have 0-frequency at the start again. This lets
    % ifft2 do inverse Fourier transform correctly:
    sig_1f = ifft(ifftshift(wnf_fil));