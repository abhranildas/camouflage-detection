function filter_kernel = create_averaging_filter(kernel_size)
% CREATE_AVERAGING_FILTER  Averaging filter matching a steerable filter's support.
%   filter_kernel = lib.create_averaging_filter(kernel_size)
%
%   Returns an averaging filter the same size as lib.steerable_filter's
%   kernel, to be used for calculating mean luminance over a patch.
%
%   Inputs
%     kernel_size - 2-element [sigma, n_sigma]: Gaussian sd in pixels, and
%                   the number of sds at which the kernel is truncated.
%
%   Output
%     filter_kernel - width x width square kernel, normalised to sum to 1.
%
%   See also lib.STEERABLE_FILTER.

    % kernel_sigma: gaussian kernel sd
    kernel_sigma = kernel_size(1);
    % kernel_n_sigma: number of kernel sds for truncation
    kernel_n_sigma = kernel_size(2);

    filter_radius = kernel_n_sigma*kernel_sigma;
    filter_width = 2*filter_radius + 1;
    filter_kernel = zeros(filter_width, filter_width);
    filter_center = (floor(filter_width/2)+1)*[1 1];
    for i_row = 1:filter_width
        for i_col = 1:filter_width
            filter_kernel(i_row, i_col) = (norm([i_row, i_col]-filter_center) <= filter_radius);
        end
    end
    % so that it's mean instead of sum when convolved.
    filter_kernel = filter_kernel/sum(filter_kernel(:));
end
