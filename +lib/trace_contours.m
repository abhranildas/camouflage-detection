function contours = trace_contours(binary_image)
% TRACE_CONTOURS  Traces contours from a binary image.
%   contours = lib.trace_contours(binary_image)
%
%   Example
%     source_image = imread('circuit.tif');
%     edge_pixels = edge(source_image);
%     contours = lib.trace_contours(edge_pixels);
%
%   Inputs
%     binary_image - binary image of contour pixels.
%
%   Output
%     contours - cell array, whose each element is a list of the sequential
%                pixel coordinates of a connected contour.
%
%   Abhranil Das <abhranil.das@utexas.edu>
%   Center for Perceptual Systems, University of Texas at Austin
%   If you use this code, please cite:
%   <a href="matlab:web('http://dx.doi.org/10.13140/RG.2.2.10585.80487')"
%   >Camouflage Detection & Signal Discrimination: Theory, Methods & Experiments</a>.
%
%   See also lib.DETECT_EDGE_PIXELS.

    binary_image(isnan(binary_image)) = 0;   % convert any NaNs to 0
    [pixel_rows, pixel_cols] = find(binary_image);
    pixel_coords = [pixel_rows, pixel_cols];
    contours = {};
    n_pixels = size(pixel_coords, 1);

    % create link map of the different pixels
    links = false(n_pixels);
    for i_pixel = 1:n_pixels
        for j_pixel = i_pixel+1:n_pixels
            if norm(pixel_coords(i_pixel, :)-pixel_coords(j_pixel, :)) <= 2
                links(i_pixel, j_pixel) = true; links(j_pixel, i_pixel) = true;
            end
        end
    end

    while nnz(links(:))   % while there are pixels left in link map

        % find first pixel in link map with only one link (end point)
        pixel_idx = find(sum(links, 2) == 1, 1);
        if isempty(pixel_idx)   % if no endpoint found
            pixel_idx = find(sum(links, 2), 1);   % pick the first pixel with any link
        end

        % trace contour starting from this pixel
        contour = zeros(1, 2);
        % i_pixel here indexes position along the traced contour, not the
        % pixel list above; it cannot be split into its own name in Stage 1
        % (one old name maps to one new name per file).
        i_pixel = 1;
        while true
            contour(i_pixel, :) = pixel_coords(pixel_idx, :);   % store this pixel
            next_pixel_idx = find(links(pixel_idx, :), 1);   % find the next pixel
            if isempty(next_pixel_idx)
                break
            end
            links(pixel_idx, :) = false; links(:, pixel_idx) = false;   % remove this pixel
            pixel_idx = next_pixel_idx;   % move to the next pixel
            i_pixel = i_pixel+1;
        end

        contours{end+1, 1} = contour;   % add contour to the list of contours
    end
end
