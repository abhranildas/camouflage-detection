function [pink_noise_signal, white_noise] = create_pink_noise_line(n_samples, exponent)
% CREATE_PINK_NOISE_LINE  Creates a 1D signal of 1/f (pink) noise.
%   [pink_noise_signal, white_noise] = lib.create_pink_noise_line(n_samples, exponent)
%
%   Inputs
%     n_samples - length of the signal, in samples.
%     exponent  - (optional) 1/f exponent. Default 1. See B1.3 in the plan:
%                 the guard below tests the variable name 'alpha', which
%                 never exists, so it is always true and exponent is always
%                 overwritten to 1, whatever the caller passed. Not fixed
%                 here (Stage 1 is behaviour-preserving).
%
%   Output
%     pink_noise_signal - 1 x n_samples pink noise signal.
%     white_noise        - the underlying white noise signal
%                           pink_noise_signal was filtered from.
%
%   See also lib.WHITEN, lib.CREATE_PINK_NOISE_SQUARE, lib.CREATE_PINK_NOISE_CUBE.

    if ~exist('alpha', 'var')
        exponent = 1;
    end

    % create 1/f Fourier filter.
    pink_noise_filter = ones(1, n_samples);
    for i_sample = 1:n_samples
        z = sqrt(norm(i_sample-n_samples/2-1));
        if z   % leave fft origin at 1
            pink_noise_filter(i_sample) = z^(-exponent);
        end
    end
    % white noise signal:
    white_noise = normrnd(0, 1, [1 n_samples]);

    % Fourier transform image, then fftshift to shift 0-frequency
    % to the center of the image, to align with 1/f filter whose
    % 0-frequency is also at the center. Otherwise multiplying
    % them together will not multiply corresponding elements.
    white_noise_fft = fftshift(fft(white_noise));

    % multiply with 1/f filter
    white_noise_filtered_fft = pink_noise_filter.*white_noise_fft;

    % ifftshift to first shift back the fourier transform
    % to have 0-frequency at the start again. This lets
    % ifft2 do inverse Fourier transform correctly:
    pink_noise_signal = ifft(ifftshift(white_noise_filtered_fft));
end
