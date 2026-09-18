function filter_kernel = laplacian_of_gaussian_filter(sigma, n_sigma)
% LAPLACIAN_OF_GAUSSIAN_FILTER  2D Laplacian-of-Gaussian filter.
%   filter_kernel = lib.laplacian_of_gaussian_filter(sigma, n_sigma)
%
%   Inputs
%     sigma   - Gaussian sd, in pixels.
%     n_sigma - extent of the filter, in units of sigma.
%
%   Output
%     filter_kernel - width x width square kernel, where
%                     width = 2*ceil(sigma*n_sigma) + 1 pixels.
%
%   See also lib.DIFFERENCE_OF_GAUSSIANS_FILTER, FSPECIAL.

    filter_radius = sigma*n_sigma;
    filter_width = 2*ceil(filter_radius) + 1;
    filter_kernel = fspecial('log', filter_width*[1, 1], sigma);
end
