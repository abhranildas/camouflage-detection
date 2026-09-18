function stim_autocorr = autocorr(stim, span)
% AUTOCORR  2D circular autocorrelation of a square image.
%   stim_autocorr = lib.autocorr(stim, span)
%
%   For every row/column shift up to span pixels, wraps the image around
%   itself and takes the dot product with the shifted copy. Can later be
%   changed to cross-correlation between two different images.
%
%   Inputs
%     stim - square image, in normalised luminance units.
%     span - maximum row/column shift to compute the autocorrelation over,
%            in pixels.
%
%   Output
%     stim_autocorr - (2*span+1) x (2*span+1) array, one value per
%                     row/column shift pair, normalised by bg_size^2 (the
%                     image area in pixels).
%
%   See also general.COMPUTE_TEXTURE_AUTOCORRELATION.

    bg_size = size(stim, 1);
    shifts = -span:span;
    n_shifts = length(shifts);
    stim_autocorr = nan(n_shifts);
    parfor i_row_shift = 1:n_shifts
        i_row_shift;
        for i_col_shift = 1:n_shifts
            stim_shifted = circshift(circshift(stim, -shifts(i_row_shift), 1), ...
                -shifts(i_col_shift), 2);
            % c=corrcoef(stim(:),stim_shifted(:));   % alternative: normalised correlation
            % coefficient instead of the raw dot product below. Never wired up; c was never used.
            stim_autocorr(i_row_shift, i_col_shift) = dot(stim(:), ...
                stim_shifted(:));
        end
    end
    stim_autocorr = stim_autocorr/bg_size^2;
end
