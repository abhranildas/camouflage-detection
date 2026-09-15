function stim_grad = steerable_grad(stim, varargin)
% STEERABLE_GRAD  Image gradient from a steerable derivative-of-Gaussian pair.
%   stim_grad = lib.steerable_grad(stim)
%   stim_grad = lib.steerable_grad(stim, 'kernel_size', [1 3], 'normalize', false)
%
%   Filters the image with the two basis kernels from lib.steerable_filter and
%   optionally divides the result by the local standard deviation, giving a
%   contrast-normalised gradient.
%
%   Inputs
%     stim        - greyscale image, in normalised luminance units.
%     kernel_size - (name-value) 2-element [sigma, n_sigma]: Gaussian sd in
%                   pixels, and the number of sds at which the kernel is
%                   truncated. Ignored when 'filter' is supplied.
%     filter      - (name-value) width x width x 2 kernel pair to use instead
%                   of building one from kernel_size.
%     pad_val     - (name-value) value, in the units of stim, to pad the image
%                   border with. NaN (default) means do not pad: the border of
%                   the output, half a kernel wide, is left NaN.
%     normalize   - (name-value) false to return the raw filter response;
%                   true to divide by the local sd; or a numeric k (default
%                   2e-4) to divide by sqrt(local_sd^2 + k), where k is the
%                   smallest offset that removes division artifacts in flat
%                   regions.
%
%   Output
%     stim_grad - rows x cols x 2 array. Page 1 is the x- (column) derivative,
%                 page 2 the y- (row) derivative. Units are luminance per
%                 pixel when normalize is false, and dimensionless otherwise.
%
%   Because the default is a numeric k rather than false, this function
%   normalises unless a caller says otherwise, and lib.edge then divides by
%   the local sd a second time. That double normalisation is B1.1 in the plan;
%   it is not changed here.
%
%   All name-value arguments are forwarded to lib.local_sd, which tolerates
%   the ones it does not declare.
%
%   See also lib.STEERABLE_FILTER, lib.LOCAL_SD, lib.EDGE.

    parser = inputParser;
    parser.KeepUnmatched = true;
    addRequired(parser, 'stim');
    addParameter(parser, 'kernel_size', [], @isnumeric);
    addParameter(parser, 'filter', [], @isnumeric);
    addParameter(parser, 'pad_val', nan, @isscalar);
    addParameter(parser, 'normalize', 2e-4);  % smallest offset to remove artifacts
    % if normalize = false, don't normalize
    % if = true, normalize by sd
    % if = k (numeric value), normalize by sqrt(sd^2+k)

    % parse inputs
    parse(parser, stim, varargin{:});
    stim = parser.Results.stim;
    kernel_size = parser.Results.kernel_size;
    filter_kernel = parser.Results.filter;
    pad_val = parser.Results.pad_val;
    normalize = parser.Results.normalize;

    if isempty(filter_kernel)
        filter_kernel = lib.steerable_filter(kernel_size);
    end

    % stim is n_rows x n_cols, filter_kernel is n_kernel_rows x n_kernel_cols
    [n_rows, n_cols] = size(stim);
    [n_kernel_rows, n_kernel_cols, ~] = size(filter_kernel);

    stim_grad = nan(n_rows, n_cols, 2);

    if isnan(pad_val)
        % get the valid output
        grad_x_valid = filter2(filter_kernel(:, :, 1), stim, 'valid');
        grad_y_valid = filter2(filter_kernel(:, :, 2), stim, 'valid');

        % locate where to paste it
        row_first = ceil(n_kernel_rows/2);          % first row index in stim_grad
        row_last = n_rows - floor(n_kernel_rows/2);   % last row index in stim_grad
        col_first = ceil(n_kernel_cols/2);          % first col index in stim_grad
        col_last = n_cols - floor(n_kernel_cols/2);   % last col index in stim_grad

        stim_grad(row_first:row_last, col_first:col_last, 1) = grad_x_valid;
        stim_grad(row_first:row_last, col_first:col_last, 2) = grad_y_valid;

        % leave out the edges of the image
        % padsize=kernel_size(1)*kernel_size(2);
        % grad(padsize+1:end-padsize,padsize+1:end-padsize,1)=filter2(filt(:,:,1),stim,'valid');
        % grad(padsize+1:end-padsize,padsize+1:end-padsize,2)=filter2(filt(:,:,2),stim,'valid');
    else
        % pad the image
        pad_len = floor(size(filter_kernel, 1)/2);
        stim_padded = padarray(stim, [pad_len, pad_len], pad_val, 'both');

        % filter and keep valid region
        stim_grad(:, :, 1) = filter2(filter_kernel(:, :, 1), stim_padded, 'valid');
        stim_grad(:, :, 2) = filter2(filter_kernel(:, :, 2), stim_padded, 'valid');
    end

    % normalize by local luminance and contrast, i.e. by local std
    if normalize
        stim_sd = lib.local_sd(stim, kernel_size, varargin{:});
        % stim_sd=std(stim(:));
        if normalize == true
            stim_grad = stim_grad./stim_sd;
            stim_grad(isnan(stim_grad)) = 0;  % change 0/0 to 0
        else
            stim_grad = stim_grad./sqrt(stim_sd.^2 + normalize);
        end
    end
end
