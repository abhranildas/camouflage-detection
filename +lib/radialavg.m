function [radial_average, bin_radii] = radialavg(matrix, n_bins, x_offset, y_offset)
% RADIALAVG  Radially average a 2D square matrix into n_bins bins.
%   [radial_average, bin_radii] = lib.radialavg(matrix, n_bins, x_offset, y_offset)
%
%   Computes the average along the radius of a unit circle inscribed in the
%   square matrix. The average is computed in n_bins bins. The radial average
%   is computed 1/2 bin beyond the unit circle, but all values beyond that
%   (i.e. corners of the matrix) are excluded from the calculation. RADIALAVG
%   will fail if NaN values are in the data; they are not excluded from the
%   calculation. If offset values x_offset, y_offset are used, the origin
%   (0,0) of the unit circle about which the average is computed is offset
%   by x_offset and y_offset relative to the origin of the unit square of the
%   input matrix.
%
%   Example
%     N = 101;
%     [X, Y] = meshgrid(-1:2/(N-1):1);
%     x_offset = +0.25;
%     y_offset = -0.25;
%     X = X - x_offset;
%     Y = Y - y_offset;
%     matrix = 1 - sqrt(X.^2 + Y.^2);
%     n_bins = (N-1)/2 + 1;
%     [radial_average, bin_radii] = lib.radialavg(matrix, n_bins, x_offset, y_offset);
%     figure; plot(bin_radii, radial_average, '.-');
%
%   Output
%     radial_average - radial average of length n_bins.
%     bin_radii      - n_bins locations of radial_average (i.e. midpoints of
%                      the n_bins bins).
%
%   See also linspace, meshgrid, accumarray
%
%   (c) 2022 David J. Fischer | fischer@shoutingman.com
%   4/4/14 DJF first working version
%   5/2/14 DJF documentation & radialavg_tester.m to demonstrate use
%   radial distances r over grid of z
%   6/20/16 DJF Excludes NaN values
%   6/21/16 DJF Added origin offset
%   1/21/22 DJF Changed to accumarray for averaging,
%               made improvements based on recommendations in comments
%               https://www.mathworks.com/matlabcentral/answers/251714-radial-average-of-2d-matrix

    if ~exist('x_offset', 'var')
        x_offset = 0;
    end
    if ~exist('y_offset', 'var')
        y_offset = 0;
    end

    % Compute unit circle radial distances
    matrix_size = size(matrix, 1);
    [x_grid, y_grid] = meshgrid(-1:2/(matrix_size-1):1);
    x_grid = x_grid - x_offset;
    y_grid = y_grid - y_offset;
    radius = sqrt(x_grid.^2 + y_grid.^2);

    % Compute bin and bin locations
    bin_width = 1/(n_bins-1);
    bin_radii = (0:bin_width:1);

    % Compute bins of data matrix for averaging by accumarray
    bins = round(radius/bin_width) + 1;

    % reshape matrices to vectors for accumarray operation
    bins = reshape(bins, matrix_size*matrix_size, 1);
    matrix = reshape(matrix, matrix_size*matrix_size, 1);

    % Compute radial average (mean)
    radial_average = accumarray(bins, matrix, [], @mean);

    % Remove average values beyond unit circle & transpose to match format from prior versions
    radial_average = radial_average(1:n_bins)';
end
