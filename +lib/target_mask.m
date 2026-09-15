function [mask, mask_edge, mask_normal, mask_strip, mask_center, target_radius] = ...
    target_mask(varargin)
% TARGET_MASK  Binary target region, its boundary, normals and boundary ribbon.
%   [mask, mask_edge, mask_normal, mask_strip] = lib.target_mask()
%   [...] = lib.target_mask('bg_size', 256, 'target_radius', 64)
%   [...] = lib.target_mask('target_shape', 2, 'target_radius_cont', 0.15)
%
%   Builds the target region that lib.stimulus pastes a texture patch into and
%   that lib.edge measures the edge along. The shape is either an exact circle
%   or a circle whose radius is a 1/f noise function of polar angle.
%
%   Inputs (all name-value)
%     bg_size            - side of the square image, in pixels. Must be even,
%                          otherwise downstream FFTs produce complex values.
%                          Default 256.
%     target_shape       - 'circular' (default), or a scalar 1/f exponent for a
%                          noisy radius as a function of angle. NOTE: the
%                          exponent is currently ignored by
%                          lib.create_pink_noise_line (B1.3), so every
%                          non-circular shape comes out at exponent 1.
%     target_radius      - target radius in pixels. Default 64. For a noisy
%                          shape this is the mean radius.
%     target_radius_cont - RMS contrast of the radius about its mean, as a
%                          fraction. Only used for a non-circular shape.
%                          Default 0.15.
%     target_loc         - [row, col] centre in pixels, or 'center' (default).
%     kernel_size        - 2-element [sigma, n_sigma] of the steerable gradient
%                          kernel, in pixels, used only to set the width of the
%                          boundary ribbon. Default [1 3].
%
%   Outputs
%     mask          - bg_size x bg_size logical, true inside the target.
%     mask_edge     - logical, true on the one-pixel boundary of the target.
%                     The outermost row and column are forced false.
%     mask_normal   - bg_size x bg_size x 2, unit normal to the boundary; page
%                     1 is the x- (column) component, page 2 the y- (row)
%                     component. For a circular target these are filled in at
%                     every interior pixel, not only on the boundary; for a
%                     noisy target they are masked to the boundary.
%     mask_strip    - logical ribbon along the boundary, as wide as the
%                     steerable kernel's support. lib.edge_measures calls this
%                     the boundary strip; lib.stimulus calls it mask_strip.
%     mask_center   - [row, col] centre actually used, in pixels.
%     target_radius - the radius that was used, in pixels (echoed so callers
%                     that relied on the default can read it back).
%
%   See also lib.STIMULUS, lib.EDGE, lib.STEERABLE_GRAD,
%   lib.CREATE_PINK_NOISE_LINE.

    parser = inputParser;
    parser.KeepUnmatched = true;
    % bg_size needs to be even, otherwise you get complex numbers.
    addParameter(parser, 'bg_size', 256, @(x) isscalar(x) && ~mod(x, 2));
    %     addParameter(parser,'seed','rand', @(x) isscalar(x) || strcmp(x,'rand'));
    addParameter(parser, 'target_shape', 'circular', @(x) strcmp(x, 'circular') || isscalar(x));
    addParameter(parser, 'target_radius', 64, @isnumeric);
    addParameter(parser, 'target_radius_cont', .15, @isnumeric);
    addParameter(parser, 'target_loc', 'center', @(x) isvector(x) || strcmp(x, 'center'));
    addParameter(parser, 'kernel_size', [1 3], @isnumeric);

    parse(parser, varargin{:});
    bg_size = parser.Results.bg_size;
    %     seed=parser.Results.seed;
    target_radius = parser.Results.target_radius;
    target_shape = parser.Results.target_shape;
    target_radius_cont = parser.Results.target_radius_cont;
    target_loc = parser.Results.target_loc;
    kernel_size = parser.Results.kernel_size;

    if strcmp(target_loc, 'center')
        mask_center = floor(bg_size/2)*[1 1];
    else
        mask_center = target_loc;
    end

    % compute mask
    mask = false(bg_size);

    if strcmp(target_shape, 'circular')
        for i_row = 1:bg_size
            for i_col = 1:bg_size
                mask(i_row, i_col) = (norm([i_row, i_col] - mask_center) < target_radius);
            end
        end
    else
        n_angles = 1e3;  % no. of angle points
        radius_grid = lib.create_pink_noise_line(n_angles, target_shape);

        % set mean and std of target radius:
        radius_grid = (radius_grid - mean(radius_grid(:)))*target_radius*target_radius_cont ...
            /std(radius_grid(:)) + target_radius;

        % polar coords of each pixel in the image
        [x_grid, y_grid] = meshgrid(1:bg_size);
        [theta_field, radius_field] = cart2pol(x_grid - mask_center(1), y_grid - mask_center(2));
        theta_idx = round((theta_field + pi)/(2*pi)*n_angles) + 1;
        theta_idx(theta_idx == n_angles + 1) = 1;
        mask = radius_field < radius_grid(theta_idx);
    end

    %             %check if boundary point (old method):
    %             if mask(i,j)&&...
    %                     ~(mask(i-1,j-1)&&mask(i-1,j)&&mask(i-1,j+1)&&mask(i,j-1)...
    %                     &&mask(i,j+1)&&mask(i+1,j-1)&&mask(i+1,j)&&mask(i+1,j+1))
    %                 mask_edge_old(i,j)=true;
    %             end

    %check if boundary point (new method):
    %nbd=mask(i-1:i+1,j-1:j+1);
    %if length(unique(nbd))>1
    %mask_edge(i,j)=1;

    % compute mask edge: all pixels where at least one of its neighbours
    % is diff. from it
    mask_edge = bwperim(mask, 4) | bwperim(~mask, 4);
    mask_edge(:, [1 end]) = 0;  mask_edge([1 end], :) = 0;

    % compute mask normal vectors
    mask_normal = zeros(bg_size, bg_size, 2);

    if strcmp(target_shape, 'circular')
        for i_row = 2:bg_size-1
            for i_col = 2:bg_size-1
    %             if mask_edge(i,j)
                normal_vec = [i_col - mask_center(2), mask_center(1) - i_row];
                if norm(normal_vec)
                    normal_vec = normal_vec/norm(normal_vec);
                end
                mask_normal(i_row, i_col, 1) = normal_vec(1);
                mask_normal(i_row, i_col, 2) = normal_vec(2);
    %             end
            end
        end
    else
        %         [target_normal(:,:,1),target_normal(:,:,2)] = imgradientxy(mask);
        %         target_normal(:,:,1)=-target_normal(:,:,1);
        [~, grad_dir] = imgradient(~mask);
        mask_normal(:, :, 1) = cosd(grad_dir);
        mask_normal(:, :, 2) = sind(grad_dir);

        %         target_normal=lib.steerable_grad(~mask,[1 3]);
        %
        %         target_normal=target_normal./vecnorm(target_normal,2,3);
        mask_normal = mask_normal.*mask_edge;
    end

    % make boundary ribbon of steerable kernel width
    mask_grad = lib.steerable_grad(mask, 'kernel_size', kernel_size, 'normalize', false);
    mask_grad_sq = mask_grad(:, :, 1).^2 + mask_grad(:, :, 2).^2;
    mask_strip = mask_grad_sq > 1e-20;
end
