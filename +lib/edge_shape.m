function [edge_grid, theta_grid, edge_autocorr, theta_lags, edge_spectrum_amps, ...
    edge_spectrum_phases] = edge_shape(stim, target_radius, n_theta, bPlot)
% EDGE_SHAPE  Gridded edge, its autocorrelation and its spectrum.
%   [edge_grid, theta_grid] = lib.edge_shape(stim, target_radius, n_theta, bPlot)
%
%   Walks a circular target boundary, takes the normal component of the image
%   gradient, resamples it onto a uniform grid of the polar angle theta, and
%   returns its circular autocorrelation and Fourier spectrum.
%
%   Inputs
%     stim          - greyscale stimulus image, in normalised luminance units.
%     target_radius - target radius in pixels.
%     n_theta       - number of theta samples on the returned grid.
%     bPlot         - logical; true draws a three-panel summary figure.
%
%   Outputs
%     edge_grid            - 1 x n_theta normal gradient along the boundary,
%                            in luminance per pixel (not normalised).
%     theta_grid           - 1 x n_theta polar angle in radians, over (-pi, pi].
%     edge_autocorr        - circular autocorrelation of edge_grid, one value
%                            per lag from 0 to floor(n_theta/2).
%     theta_lags           - the lags of edge_autocorr, in radians.
%     edge_spectrum_amps   - one-sided DFT magnitude of edge_grid.
%     edge_spectrum_phases - two-sided DFT phase of edge_grid, in radians.
%
%   This function does not currently run: line 19 calls lib.circular_mask,
%   which does not exist anywhere in the repo, and line 16 calls
%   lib.steerable_grad positionally, which that function rejects. Both are
%   already recorded, as B2.9 and B2.3 respectively, and are not fixed here.
%   lib.edge and lib.edge_vector_ideal are the maintained successors: they use
%   lib.target_mask and normalise the gradient.
%
%   See also lib.EDGE, lib.EDGE_VECTOR_IDEAL, lib.EDGE_MEASURES_IDEAL,
%   lib.STEERABLE_GRAD.

    bg_size = size(stim, 1);
    target_center = floor(bg_size/2)*[1 1];

    % array of angles
    thetas = zeros(bg_size);
    for i_row = 1:bg_size
        for i_col = 1:bg_size
            offset_vec = [i_row, i_col] - target_center;
            thetas(i_row, i_col) = cart2pol(offset_vec(1), offset_vec(2));
        end
    end

    % calculate stimulus gradient using steerable filter:
    stim_grad = lib.steerable_grad(stim, [1 3]);

    % create target mask
    [~, mask_edge, mask_normal] = lib.circular_mask(size(stim, 1), target_radius, 'center');

    % normal gradient
    grad_normal = mask_normal(:, :, 1).*stim_grad(:, :, 1) ...
        + mask_normal(:, :, 2).*stim_grad(:, :, 2);

    % table of theta and edge
    theta_edge = sortrows([thetas(mask_edge), grad_normal(mask_edge)]);

    % make unique
    [~, unique_idx] = unique(theta_edge(:, 1));
    theta_edge = theta_edge(unique_idx, :);

    % wrap on either side to help interpolation
    theta_edge_wrap = [[theta_edge(:, 1) - 2*pi; theta_edge(:, 1); theta_edge(:, 1) + 2*pi], ...
        repmat(theta_edge(:, 2), [3 1])];

    % gridded interpolation
    edge_interp = griddedInterpolant(theta_edge_wrap(:, 1), theta_edge_wrap(:, 2));

    theta_grid = linspace(-pi, pi, n_theta + 1);
    theta_grid = theta_grid(2:end);
    edge_grid = edge_interp(theta_grid);

    % edge autocorrelation:
    n_lags = floor(n_theta/2) + 1;  % # of items in autocorr
    theta_lags = (0:n_lags-1)*2*pi/n_theta;
    %th_lags=th_lags(1:end-1);
    edge_autocorr = zeros(1, n_lags);
    % here i_row indexes lags, not image rows; the two loops cannot take
    % different index names without renaming one "i" to two things, which the
    % Stage 1 check forbids
    for i_row = 1:n_lags
        edge_autocorr(i_row) = mean(edge_grid.*circshift(edge_grid, i_row - 1));
    end

    % edge spectrum amplitude and phase:
    edge_fft = fft(edge_grid);
    edge_spectrum_amps = abs(edge_fft(1:ceil((n_theta + 1)/2)));  % remove repeated part
    edge_spectrum_phases = angle(edge_fft);

    if bPlot
        figure
        subplot(3, 1, 1)
        plot(theta_grid, edge_grid)
        hold on
        plot(theta_edge(:, 1), theta_edge(:, 2), '.')
        title 'gridded edge'

        subplot(3, 1, 2)
        plot(theta_lags, edge_autocorr)
        title 'edge autocorrelation'

        subplot(3, 1, 3)
        plot(edge_spectrum_amps)
        title 'edge spectrum'
    end
end
