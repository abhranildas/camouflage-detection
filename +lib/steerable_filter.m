function filter_kernel = steerable_filter(kernel_size)
% STEERABLE_FILTER  First-derivative-of-Gaussian steerable filter pair.
%   filter_kernel = lib.steerable_filter(kernel_size)
%
%   Builds the two basis kernels — the x- and y-derivative of a Gaussian —
%   whose responses can be combined to give the directional derivative at any
%   orientation. Both are truncated to a disc of radius sigma*n_sigma.
%
%   Inputs
%     kernel_size - 2-element [sigma, n_sigma]: Gaussian sd in pixels, and
%                   the number of sds at which the kernel is truncated.
%
%   Output
%     filter_kernel - width x width x 2 array, where
%                     width = 2*ceil(sigma*n_sigma) + 1 pixels. Page 1 is the
%                     x-derivative (column) kernel, page 2 the y-derivative
%                     (row) kernel, with row index increasing downward, hence
%                     the sign flip on page 2.
%
%   The kernels are not normalised to unit L2 norm, so a larger sigma gives a
%   larger response to the same image. lib.steerable_grad normalises the
%   response by the local sd instead; that is a different normalisation, not
%   a substitute for this one.
%
%   See also lib.STEERABLE_GRAD, lib.LOCAL_SD.

    % kernel_sd: Gaussian kernel sd, in pixels
    kernel_sd = kernel_size(1);
    % kernel_nsd: number of kernel sds at which the kernel is truncated
    kernel_nsd = kernel_size(2);

    filter_radius = kernel_nsd*kernel_sd;
    filter_width = 2*ceil(filter_radius) + 1;
    filter_kernel = zeros(filter_width, filter_width, 2);
    filter_center = (floor(filter_width/2) + 1)*[1 1];
    for i_row = 1:filter_width
        for i_col = 1:filter_width
            if norm([i_row, i_col] - filter_center) <= filter_radius
                filter_kernel(i_row, i_col, 1) = (i_col - filter_center(2))/kernel_sd^2 ...
                    * exp(-(norm([i_row, i_col] - filter_center)/kernel_sd)^2/2);
                filter_kernel(i_row, i_col, 2) = (filter_center(1) - i_row)/kernel_sd^2 ...
                    * exp(-(norm([i_row, i_col] - filter_center)/kernel_sd)^2/2);
            end
        end
    end

    % normalize by their L2 norm (so that larger filter responses aren't bigger
    % simply due to size
    % filter_1=filter(:,:,1); filter_1=filter_1(:);
    % filter=filter/norm(filter_1(:));

    %display filter
    % img = filter(:,:,2)- min(min(filter(:,:,2)));
    % img = sqrt(img);                           % gamma correct for display
    % img = 256*img/max(max(img));               % scale to max of 256
    % figure; colormap(gray(256));image(img);axis image;
end
