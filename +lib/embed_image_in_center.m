function [output_image, percent_clipped] = embed_image_in_center(source_image, target, ...
    b_additive, n_bits, offset_px, b_clip, target_window)
% EMBED_IMAGE_IN_CENTER  Embeds a target in the center of the input image.
%   [output_image, percent_clipped] = lib.embed_image_in_center(source_image, target, ...
%       b_additive, n_bits, offset_px, b_clip, target_window)
%
%   Output
%     output_image   - source_image with target embedded (or blended, in the
%                      windowed case).
%     percent_clipped - if b_additive == 1, the % of clipped pixels.
%
%   v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>
%
%   See also lib.DIFFERENCE_OF_GAUSSIANS_2D.

    %% Set defaults
    if (~exist('b_additive', 'var'))
        b_additive = 0;
    end

    if (~exist('n_bits', 'var') || isempty(n_bits))
        n_bits = 16;
    end

    if (~exist('offset_px', 'var')) || isempty(offset_px)
        offset_px = 0;
    end

    if (~exist('b_clip', 'var')) || isempty(b_clip)
        b_clip = 0;
    end

    if (~exist('target_window', 'var')) || isempty(target_window)
        %     warning('If you are using an occluding target you need a window. Execution may crash if no window is supplied');
    end

    percent_clipped = 0;

    max_pixel_val = 2^n_bits - 1;

    % get the patch sizes
    input_size = size(source_image);
    target_size = size(target);

    if (target_size(1) > input_size(1) || target_size(2) > input_size(2))
        error('ERROR: Target is larger than image');
    end

    % get the location of the center of the image
    center_location = floor(input_size./2) + 1;

    center_location(2) = center_location(2) + offset_px;

    % get the x and y areas over which to embed the target
    target_range_x = (center_location(1) - floor(target_size(1)./2)): ...
        (center_location(1) + ceil(target_size(1)./2) - 1);
    target_range_y = (center_location(2) - floor(target_size(2)./2)): ...
        (center_location(2) + ceil(target_size(2)./2) - 1);

    % embed the target
    if (b_additive)
        source_image(target_range_x, target_range_y) = ...
            source_image(target_range_x, target_range_y) + target;
        % check for clipping
        percent_clipped = (sum(source_image(:) > max_pixel_val) + ...
            sum(source_image(:) < 0))./(length(target(:)))*100;
        % clip the image
        if (b_clip)
            source_image(source_image < 0) = 0;
            source_image(source_image > max_pixel_val) = max_pixel_val;
        end
    else
        patch = source_image(target_range_x, target_range_y);
        patch(target_window) = target(target_window);

        source_image(target_range_x, target_range_y) = patch;

    end

    output_image = source_image;
end
