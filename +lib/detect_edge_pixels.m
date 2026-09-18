function edge_pixels = detect_edge_pixels(stim, options)
% DETECT_EDGE_PIXELS  Zero-crossing edge pixels, thresholded by local gradient magnitude.
%   edge_pixels = lib.detect_edge_pixels(stim, ...)
%   edge_pixels = lib.detect_edge_pixels(stim, 'edge_detection_filter', filt)
%   edge_pixels = lib.detect_edge_pixels(stim, 'thresh', value)
%
%   Inputs
%     stim                  - greyscale image, in normalised luminance units.
%     edge_detection_filter - (name-value) filter passed to the builtin
%                             zero-crossing edge detector. Default a
%                             Laplacian-of-Gaussian filter,
%                             lib.laplacian_of_gaussian_filter(2, 3).
%     thresh                - (name-value) minimum 1-pixel-scale gradient
%                             magnitude for a zero-crossing to count as an
%                             edge pixel. Default 4.
%
%   Output
%     edge_pixels - logical image, same size as stim, true at detected edge
%                   pixels.
%
%   The unqualified call below, edge(stim,'zerocross',...), resolves to the
%   Image Processing Toolbox's EDGE, not to lib.edge, despite this file's own
%   name; see lib.EDGE_MEASURES for the same trap.
%
%   See also lib.EDGE_MEASURES, lib.LAPLACIAN_OF_GAUSSIAN_FILTER, lib.STEERABLE_GRAD.

    arguments
        stim {mustBeNumeric}
        % edge_detection_filter=lib.difference_of_gaussians_filter(2,4,2);
        options.edge_detection_filter {mustBeNumeric} = lib.laplacian_of_gaussian_filter(2, 3)
        options.thresh (1, 1) = 4
    end

    edge_detection_filter = options.edge_detection_filter;
    thresh = options.thresh;

    %% compute normalized gradients, and thresholded edge pixels
    edge_pixels = edge(stim, 'zerocross', 0, edge_detection_filter);

    stim_grad_1px = lib.steerable_grad(stim, 'kernel_size', [1 3]);

    % threshold by the 1px gradient magnitude:
    stim_grad_1px_magnitude = vecnorm(stim_grad_1px, 2, 3);
    thresholded = stim_grad_1px_magnitude > thresh;
    edge_pixels = edge_pixels & thresholded;
end
