function stim_sd = local_sd(stim, kernel_size, varargin)
% LOCAL_SD  Local standard deviation (luminance x contrast) of an image.
%   stim_sd = lib.local_sd(stim, kernel_size)
%   stim_sd = lib.local_sd(stim, kernel_size, 'pad_val', value)
%
%   Standard deviation over a disc-shaped neighbourhood centred on each
%   pixel. This is the local luminance-times-contrast signal that lib.edge
%   and lib.steerable_grad divide the raw gradient by.
%
%   Inputs
%     stim        - greyscale image, in normalised luminance units.
%     kernel_size - 2-element [sigma, n_sigma]: the Gaussian sd in pixels of
%                   the steerable gradient filter, and the number of sds at
%                   which that kernel is truncated. Only the product
%                   sigma*n_sigma is used here, as the disc radius in pixels,
%                   so the neighbourhood matches the support of the gradient
%                   kernel built by lib.steerable_filter.
%     pad_val     - (name-value) value to pad the image border with before
%                   filtering, in the same units as stim. NaN (default) means
%                   no padding, leaving stdfilt's own border handling.
%
%   Output
%     stim_sd - same size as stim, local standard deviation in the units of
%               stim.
%
%   Extra name-value arguments are tolerated and ignored, because
%   lib.steerable_grad forwards its whole varargin here.
%
%   See also lib.STEERABLE_GRAD, lib.STEERABLE_FILTER, lib.EDGE, STDFILT.

    parser = inputParser;
    parser.KeepUnmatched = true;
    addRequired(parser, 'stim');
    addParameter(parser, 'pad_val', nan, @isscalar);

    % parse inputs
    parse(parser, stim, varargin{:});
    pad_val = parser.Results.pad_val;

    % define the local patch neighbourhood: a disc of radius sigma*n_sigma
    disc_radius = kernel_size(1)*kernel_size(2);
    disc_size = 2*ceil(disc_radius) + 1;
    disc_mask = false(disc_size);
    disc_center = (floor(disc_size/2) + 1)*[1 1];
    for i_row = 1:disc_size
        for i_col = 1:disc_size
            if norm([i_row, i_col] - disc_center) <= disc_radius
                disc_mask(i_row, i_col) = true;
            end
        end
    end

    if isnan(pad_val)
        stim_sd = stdfilt(stim, disc_mask);
    else
        % pad the image
        pad_len = floor(disc_size/2);
        stim_padded = padarray(stim, [pad_len, pad_len], pad_val, 'both');

        % filter and keep the valid region
        stim_sd_padded = stdfilt(stim_padded, disc_mask);
        stim_sd = stim_sd_padded(pad_len+1:end-pad_len, pad_len+1:end-pad_len);
    end
end
