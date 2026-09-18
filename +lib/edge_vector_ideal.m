function [edge_vector, edge_field, edge_normal_field, theta_grid] = ...
    edge_vector_ideal(stim, options)
% EDGE_VECTOR_IDEAL  Dimensionless edge vector along a target boundary.
%   [edge_vector, edge_field] = lib.edge_vector_ideal(stim)
%   [...] = lib.edge_vector_ideal(stim, 'mask', mask, 'mask_edge', mask_edge, ...
%               'mask_normal', mask_normal)
%
%   Same walk along the target boundary as lib.edge, but normalised
%   differently: the normal gradient is divided by the RMS gradient magnitude
%   along the boundary, a single scalar, rather than by the per-pixel local
%   standard deviation. This is the ratio e = g_perp / g_rms reported in the
%   paper, and it is the definition frozen into data/edge_powers/*.mat.
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
%     edge_vector       - 1 x n_edge dimensionless edge, sampled on a uniform
%                         theta grid. Feed this to lib.edge_measures_ideal.
%     edge_field        - rows x cols x 2 gradient masked to the boundary.
%     edge_normal_field - rows x cols normal component of the gradient, over
%                         the whole image and not only the boundary.
%     theta_grid        - 1 x n_edge boundary parameter, in radians, covering
%                         (-pi, pi].
%
%   This function and lib.edge are the two incompatible live definitions of
%   edge power recorded as B1.1 in the plan; on the same stimulus they differ
%   by a factor of order 1e3. Nothing is changed here to reconcile them.
%
%   The returned vector was called "edge" before this pass, shadowing the
%   Image Processing Toolbox EDGE; it is now edge_vector, which is a local
%   name only and does not affect callers.
%
%   See also lib.EDGE_MEASURES_IDEAL, lib.EDGE, lib.TARGET_MASK,
%   lib.STEERABLE_GRAD.

    arguments
        stim {mustBeNumeric}
        % a scalar mask means a circular mask of that radius
        options.mask {must_be_scalar_or_logical} = 64
        options.mask_edge {must_be_logical_or_empty} = []
        options.mask_normal {mustBeNumeric} = []
        options.n_edge {mustBeNumeric} = 1e3
        options.kernel_size {mustBeNumeric} = [1 3]
    end

    if isscalar(options.mask)
        target_radius = options.mask;
    else
        mask = options.mask;
        mask_edge = options.mask_edge;
        mask_normal = options.mask_normal;
    end
    n_edge = options.n_edge;
    kernel_size = options.kernel_size;

    bg_size = size(stim, 1);
    target_center = floor(bg_size/2)*[1 1];

    % field of parameter theta along the boundary
    theta_field = nan(bg_size);
    if isscalar(options.mask)  % if circular mask

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
%         F=scatteredInterpolant(boundary(:,1),boundary(:,2),thetas','nearest');
%         [X,Y] = meshgrid(1:bg_size);
%         theta_field=F(X,Y);
%         theta_field=theta_field.*mask_edge;
        % here i_row indexes the list of edge pixels, not image rows; the two
        % loops cannot take different index names without renaming one "i" to
        % two things, which the Stage 1 check forbids
        for i_row = 1:length(edge_rows)
            theta_field(edge_rows(i_row), edge_cols(i_row)) = thetas(nearest_idx(i_row));
        end
    end

    % calculate stimulus gradient using steerable filter:
    stim_grad = lib.steerable_grad(stim, 'kernel_size', kernel_size);

    % edge magnitude
    edge_field = mask_edge.*stim_grad;
    [~, edge_magnitude_field] = cart2pol(edge_field(:, :, 1), edge_field(:, :, 2));

    % normal gradient
    edge_normal_field = mask_normal(:, :, 1).*stim_grad(:, :, 1) ...
        + mask_normal(:, :, 2).*stim_grad(:, :, 2);

    % table of theta and edge
    theta_edge = sortrows([theta_field(mask_edge), edge_normal_field(mask_edge), ...
        edge_magnitude_field(mask_edge)]);

    %     th_edge=th_edge(unique_idx_1,:);

    % wrap on either side to help interpolation
    theta_edge_wrap = [[theta_edge(:, 1) - 2*pi; theta_edge(:, 1); theta_edge(:, 1) + 2*pi], ...
        repmat(theta_edge(:, [2 3]), [3 1])];

    % make unique, averaging across the degenerate thetas
    [~, ~, i_unique_theta] = unique(theta_edge_wrap(:, 1));
    theta_edge_wrap = groupsummary(theta_edge_wrap, i_unique_theta, @nanmean);

    % Return a uniform-gridded edge vector without nans
    theta_wrap = theta_edge_wrap(:, 1);
    edge_normal_wrap = theta_edge_wrap(:, 2);
    edge_magnitude_wrap = theta_edge_wrap(:, 3);
    edge_normal_interp = griddedInterpolant(theta_wrap(~isnan(edge_normal_wrap)), ...
        edge_normal_wrap(~isnan(edge_normal_wrap)));
    edge_magnitude_interp = griddedInterpolant(theta_wrap(~isnan(edge_magnitude_wrap)), ...
        edge_magnitude_wrap(~isnan(edge_magnitude_wrap)));

    theta_grid = linspace(-pi, pi, n_edge + 1);
    theta_grid = theta_grid(2:end);

    edge_magnitude = edge_magnitude_interp(theta_grid);
    edge_vector = edge_normal_interp(theta_grid)/rms(edge_magnitude);
end

function must_be_scalar_or_logical(value)
% Validator for mask: either a scalar target radius, or a logical mask image.
    if ~(isscalar(value) || islogical(value))
        error('lib:edge_vector_ideal:invalidMask', ...
            'mask must be a scalar target radius, or a logical mask image.');
    end
end

function must_be_logical_or_empty(value)
% Validator for mask_edge: a logical image, or empty. Empty is admitted only
% because it is this argument's own default, which inputParser never validated.
    if ~(islogical(value) || isempty(value))
        error('lib:edge_vector_ideal:invalidMaskEdge', ...
            'mask_edge must be a logical image.');
    end
end
