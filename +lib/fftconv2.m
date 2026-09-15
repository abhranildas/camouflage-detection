function C = fftconv2(A, B)
% FFTCONV2  Calculate 2D convolution of A and B using fft2.
%   C = lib.fftconv2(A, B)
%
%   Output
%     C - convolution of A and B. Has same size as biggest input (A or B).
%
%   YC at ES lab
%   Created on Sep. 29, 2009
%   Last modified on Oct. 1, 2009
%
%   See also CONV2, FFT2.

    %% Check inputs and/or outputs
    [n_rows_a, n_cols_a] = size(A);
    [n_rows_b, n_cols_b] = size(B);

    %% Convolution
    padded_a = zeros(n_rows_a+n_rows_b-1, n_cols_a+n_cols_b-1);
    padded_b = zeros(n_rows_a+n_rows_b-1, n_cols_a+n_cols_b-1);

    padded_a(1:n_rows_a, 1:n_cols_a) = A;
    padded_b(1:n_rows_b, 1:n_cols_b) = B;

    conv_full = ifft2(fft2(padded_a).*fft2(padded_b));

    % return region size from larger input
    % 1. Y dimension
    if (n_rows_a > n_rows_b)
        y_range = (1:n_rows_a) + floor(n_rows_b/2);
    else
        y_range = (1:n_rows_b) + floor(n_rows_a/2);
    end
    % 2. X dimension
    if (n_cols_a > n_cols_b)
        x_range = (1:n_cols_a) + floor(n_cols_b/2);
    else
        x_range = (1:n_cols_b) + floor(n_cols_a/2);
    end

    C = conv_full(y_range, x_range);
end
