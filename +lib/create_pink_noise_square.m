function [pink_noise, white_noise] = create_pink_noise_square(bg_size, exponent)
% CREATE_PINK_NOISE_SQUARE  Creates a square image of 1/f (pink) noise.
%   [pink_noise, white_noise] = lib.create_pink_noise_square(bg_size, exponent)
%
%   Inputs
%     bg_size  - side length of the square image, in pixels.
%     exponent - (optional) 1/f exponent. Default 1.
%
%   Output
%     pink_noise  - bg_size x bg_size pink noise image.
%     white_noise - the underlying white noise image pink_noise was filtered
%                   from.
%
%   See also lib.WHITEN, lib.CREATE_PINK_NOISE_LINE, lib.CREATE_PINK_NOISE_CUBE.

    if ~exist('exponent', 'var')
        exponent = 1;
    end

    % create 1/f Fourier filter.
    pink_noise_filter = ones(bg_size);
    for i_row = 1:bg_size
        for i_col = 1:bg_size
            z = norm([i_row-bg_size/2-1, i_col-bg_size/2-1]);
            if z   % leave fft origin at 1
                pink_noise_filter(i_row, i_col) = z^(-exponent);
            end
        end
    end
    % white noise image:
    white_noise = normrnd(0, 1, bg_size);

    % Fourier transform image, then fftshift to shift 0-frequency
    % to the center of the image, to align with 1/f filter whose
    % 0-frequency is also at the center. Otherwise multiplying
    % them together will not multiply corresponding elements.
    white_noise_fft = fftshift(fft2(white_noise));

    % multiply with 1/f filter
    white_noise_filtered_fft = pink_noise_filter.*white_noise_fft;

    % ifftshift to first shift back the fourier transform
    % to have 0-frequency at the start again. This lets
    % ifft2 do inverse Fourier transform correctly:
    pink_noise = ifft2(ifftshift(white_noise_filtered_fft));
end
