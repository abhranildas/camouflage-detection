function white_noise = whiten(pink_noise)
% WHITEN  Reverses a square pink noise image to find the white noise it was created from.
%   white_noise = lib.whiten(pink_noise)
%
%   Inputs
%     pink_noise - bg_size x bg_size pink (1/f) noise image.
%
%   Output
%     white_noise - the white noise image pink_noise would result from
%                   filtering with lib.create_pink_noise_square's 1/f filter.
%
%   See also lib.CREATE_PINK_NOISE_SQUARE.

    bg_size = size(pink_noise, 1);

    % create 1/f Fourier filter.
    pink_noise_filter = ones(bg_size);
    for i_row = 1:bg_size
        for i_col = 1:bg_size
            z = norm([i_row-bg_size/2-1, i_col-bg_size/2-1]);
            if z   % leave fft origin at 1
                pink_noise_filter(i_row, i_col) = 1/z;
            end
        end
    end

    pink_noise_fft = fftshift(fft2(pink_noise));
    white_noise_fft = pink_noise_fft./pink_noise_filter;   % divide by 1/f filter
    white_noise = ifft2(ifftshift(white_noise_fft));
end
