function [target_edge_vector, target_edge_power, target_edge_field, theta_grid] = ...
    edge(stim, varargin)
% EDGE  Edge vector and edge power along a target boundary.
%   [edge_vector, edge_power] = lib.edge(stim)
%   [...] = lib.edge(stim, 'mask', mask, 'mask_edge', mask_edge, 'mask_normal', mask_normal)
%
%   Walks the target boundary, takes the component of the image gradient
%   normal to it, divides by the local standard deviation, and resamples the
%   result onto a uniform grid of the boundary parameter theta.
%
%   Inputs
%     stim        - greyscale stimulus image, in normalised luminance units.
%     mask        - (name-value) logical target mask, or a scalar target
%                   radius in pixels meaning "circular mask of this radius,
%                   centred". Default 64.
%     mask_edge   - (name-value) logical image of the target mask boundary.
%                   Only used when mask is a logical image.
%     mask_normal - (name-value) rows x cols x 2 unit normals to the boundary;
%                   page 1 is the x- (column) component, page 2 the y- (row)
%                   component. Only used when mask is a logical image.
%     n_edge      - (name-value) number of theta samples in the returned edge
%                   vector. Default 1e3.
%     kernel_size - (name-value) 2-element [sigma, n_sigma] of the steerable
%                   gradient filter: Gaussian sd in pixels, and the number of
%                   sds at which the kernel is truncated. Default [1 3].
%
%   Outputs
%     target_edge_vector - 1 x n_edge normalised normal gradient, sampled on a
%                          uniform theta grid. Dimensionless.
%     target_edge_power  - mean of target_edge_vector.^2, dimensionless.
%     target_edge_field  - rows x cols image of the normalised normal
%                          gradient, before sampling.
%     theta_grid         - 1 x n_edge boundary parameter, in radians, covering
%                          (-pi, pi].
%
%   Two incompatible definitions of edge power are live in this repo: this
%   function divides the normal gradient by the per-pixel lib.local_sd, while
%   lib.edge_vector_ideal divides by the scalar rms gradient magnitude along
%   the boundary. They differ by a factor of order 1e3 on the same stimulus.
%   That is B1.1 in the plan and is not resolved here. Note also that
%   lib.steerable_grad already normalises by default, so this function's
%   division by stim_sd is a second normalisation.
%
%   The function name shadows the Image Processing Toolbox EDGE. An
%   unqualified call to edge() from inside +lib resolves to the toolbox
%   function, not to this one (see lib.EDGE_MEASURES); that is correct and
%   deliberate, and must not be "fixed".
%
%   Outputs 3 and 4 used to be per-contour lengths and energies; see the
%   commented-out block at the end and B1.5, which records a caller that still
%   destructures them that way.
%
%   Abhranil Das <abhranil.das@utexas.edu>
%   Center for Perceptual Systems, University of Texas at Austin
%
%   See also lib.EDGE_VECTOR_IDEAL, lib.EDGE_MEASURES_IDEAL, lib.TARGET_MASK,
%   lib.STEERABLE_GRAD, lib.LOCAL_SD.

    parser = inputParser;
    parser.KeepUnmatched = true;
    addRequired(parser, 'stim', @isnumeric);
    % a scalar mask means a circular mask of that radius
    addParameter(parser, 'mask', 64, @(x) isscalar(x) || islogical(x));
    addParameter(parser, 'mask_edge', [], @islogical);
    addParameter(parser, 'mask_normal', [], @isnumeric);
    addParameter(parser, 'n_edge', 1e3, @isnumeric);
    addParameter(parser, 'kernel_size', [1 3], @isnumeric);

    % parse inputs
    parse(parser, stim, varargin{:});
    stim = parser.Results.stim;
    if isscalar(parser.Results.mask)
        target_radius = parser.Results.mask;
    else
        mask = parser.Results.mask;
        mask_edge = parser.Results.mask_edge;
        mask_normal = parser.Results.mask_normal;
    end
    n_edge = parser.Results.n_edge;
    kernel_size = parser.Results.kernel_size;

    bg_size = size(stim, 1);
    target_center = floor(bg_size/2)*[1 1];

    %% compute the edge along the target boundary

    % field of parameter theta along the boundary
    theta_field = nan(bg_size);
    if isscalar(parser.Results.mask)  % if circular mask

        % array of angles theta for circular mask
        for i_row = 1:bg_size
            for i_col = 1:bg_size
                offset_vec = [i_row, i_col] - target_center;
                theta_field(i_row, i_col) = cart2pol(offset_vec(1), offset_vec(2));
            end
        end

        % create mask edge and normal
        [~, mask_edge, mask_normal] = lib.target_mask('bg_size', size(stim, 1), ...
            'target_radius', target_radius);

    else
        % array of parameter theta along the boundary
        boundaries = bwboundaries(mask, 'noholes');
        [~, i_longest] = max(cellfun(@(x) size(x, 1), boundaries));  %longest boundary
        boundary = boundaries{i_longest};
        thetas = linspace(-pi, pi, size(boundary, 1) + 1);
        thetas = thetas(1:end-1);
        [edge_rows, edge_cols] = find(mask_edge);
        nearest_idx = knnsearch([boundary(:, 1), boundary(:, 2)], [edge_rows edge_cols]);
        % here i_row indexes the list of edge pixels, not image rows; the two
        % loops cannot take different index names without renaming one "i" to
        % two things, which the Stage 1 check forbids
        for i_row = 1:length(edge_rows)
            theta_field(edge_rows(i_row), edge_cols(i_row)) = thetas(nearest_idx(i_row));
        end
    end

    % stimulus gradient using steerable filter:
    stim_grad = lib.steerable_grad(stim, 'kernel_size', kernel_size);

    % normal gradient
    normal_gradient_field = mask_normal(:, :, 1).*stim_grad(:, :, 1) ...
        + mask_normal(:, :, 2).*stim_grad(:, :, 2);

    % normalize by local luminance and contrast, i.e. by local std
    stim_sd = lib.local_sd(stim, kernel_size);
    target_edge_field = normal_gradient_field./stim_sd;

    % table of theta and edge
    theta_edge = sortrows([theta_field(mask_edge), target_edge_field(mask_edge)]);

    % wrap on either side to help interpolation
    theta_edge_wrap = [[theta_edge(:, 1) - 2*pi; theta_edge(:, 1); theta_edge(:, 1) + 2*pi], ...
        repmat(theta_edge(:, 2), [3 1])];

    % make unique, averaging across the degenerate thetas
    [~, ~, i_unique_theta] = unique(theta_edge_wrap(:, 1));
    theta_edge_wrap = groupsummary(theta_edge_wrap, i_unique_theta, @nanmean);

    % Return a uniform-gridded edge vector without nans
    theta_wrap = theta_edge_wrap(:, 1);
    edge_normal_wrap = theta_edge_wrap(:, 2);
    edge_normal_interp = griddedInterpolant(theta_wrap(~isnan(edge_normal_wrap)), ...
        edge_normal_wrap(~isnan(edge_normal_wrap)));

    theta_grid = linspace(-pi, pi, n_edge + 1);
    theta_grid = theta_grid(2:end);

    target_edge_vector = edge_normal_interp(theta_grid);
    target_edge_power = mean(target_edge_vector.^2);

    %% compute edge contours along the target boundary
%     s=sign([target_edge_vector,target_edge_vector]);
%     sign_changes=diff(s);
%     sign_changes=sign_changes(1:length(target_edge_vector));
%     locs=find(sign_changes);
%
%     % circularly shift to begin at a group
%     if ~isempty(locs)
%         edge_rotated=circshift(target_edge_vector,-locs(1));
%         sign_changes=circshift(sign_changes,-locs(1));
%     end
%
%     locs=find(sign_changes);
%     n_groups=length(locs);
%     locs=[0,locs];
%     target_contours_l=diff(locs)';
%
%     target_contours_e=nan(n_groups,1);
%     for i=1:n_groups
%         target_contours_e(i)=mean(edge_rotated(locs(i)+1:locs(i+1)).^2);
%     end
end
