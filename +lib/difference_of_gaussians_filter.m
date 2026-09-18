function filter_kernel = diff_of_gaussians_filter(sigma_center, sigma_surround, n_sigma)
% DIFF_OF_GAUSSIANS_FILTER  Center-surround difference-of-Gaussians filter.
%   filter_kernel = lib.diff_of_gaussians_filter(sigma_center, sigma_surround, n_sigma)
%
%   Inputs
%     sigma_center   - Gaussian sd of the center kernel, in pixels.
%     sigma_surround - Gaussian sd of the surround kernel, in pixels.
%     n_sigma        - extent of the filter, in units of surround sd.
%
%   Output
%     filter_kernel - width x width square kernel, where
%                     width = 2*ceil(sigma_surround*n_sigma) + 1 pixels.
%
%   See also lib.LAPLACIAN_OF_GAUSSIAN_FILTER, lib.STEERABLE_FILTER.

    filter_radius = sigma_surround*n_sigma;
    filter_width = 2*ceil(filter_radius) + 1;
    filter_origin = (floor(filter_width/2)+1)*[1 1];

    filter_center = zeros(filter_width);
    filter_surround = zeros(filter_width);

    for i_row = 1:filter_width
        for i_col = 1:filter_width
            offset = [i_row, i_col] - filter_origin;
            if norm(offset) <= filter_radius
                filter_center(i_row, i_col) = mvnpdf(offset, [], eye(2)*sigma_center^2);
                filter_surround(i_row, i_col) = mvnpdf(offset, [], eye(2)*sigma_surround^2);
            end
        end
    end

    % normalize each filter to 1
    filter_center = filter_center/sum(filter_center(:));
    filter_surround = filter_surround/sum(filter_surround(:));

    filter_kernel = filter_center - filter_surround;
end
