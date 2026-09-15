function [stim, stim_bg, seed, mask, mask_edge, mask_normal, mask_strip, ...
    white_noise_bg, white_noise_target] = stimulus(varargin)
% STIMULUS  Generate a camouflage-detection stimulus image.
%   stim = lib.stimulus()
%   stim = lib.stimulus('seed', 1, 'ml_b', 0.5, 'cont_b', 0.15, 'target_radius', 64)
%   [stim, stim_bg, seed, mask] = lib.stimulus('texture', texture, 'target_radius', 64)
%
%   Synthesises a textured background, synthesises a target patch, cuts the
%   patch to the target mask, matches its mean luminance and contrast to the
%   background region it covers, and pastes it on. With target_radius = 0 the
%   result is a blank background.
%
%   Inputs (all name-value; none required)
%     bg_size            - side of the square stimulus image, in pixels. Must
%                          be even, otherwise the FFT-based texture synthesis
%                          returns complex values. Default 256.
%     texture            - struct describing the target texture. Fields: type
%                          ('pink_noise', 'ps', or 'crop'), exponent (the 1/f
%                          exponent, for pink noise), img (path to a source
%                          image), stats and Niter (Portilla-Simoncelli
%                          analysis and iteration count), scale (for 'crop').
%                          Default: pink noise with exponent 1.
%     texture_bg         - struct of the same shape for the background
%                          texture. Defaults to the target's texture, which is
%                          the maximal-camouflage case.
%     seed               - RNG seed, an integer, or 'rand' (default) to draw
%                          one. The stream is reset with rng('default') before
%                          rng(seed), so one seed reproduces one stimulus
%                          exactly.
%     target_shape       - 'circular' (default), or a scalar 1/f exponent for
%                          a target whose radius is a noise function of angle.
%                          NOTE: the exponent is currently ignored
%                          downstream (B1.3).
%     target_radius      - target radius in pixels. Default 0, i.e. no target.
%     target_radius_cont - RMS contrast of the target radius about its mean, as
%                          a fraction. Only for a non-circular shape. Default
%                          0.15.
%     target_loc         - [row, col] target centre in pixels, or 'center'
%                          (default).
%     target_or          - target orientation in degrees; the target patch is
%                          rotated by this much before masking. Default 0.
%     ml_b               - background mean luminance, as a fraction of the
%                          monitor maximum. Default [], i.e. leave the
%                          synthesised background as it is.
%     cont_b             - background RMS contrast, as a fraction. Default [].
%     ml_t               - target mean luminance, as a fraction. 'match'
%                          (default) matches the background region the target
%                          covers.
%     cont_t             - target RMS contrast, as a fraction. 'match'
%                          (default) matches the background region the target
%                          covers.
%
%   Outputs
%     stim               - bg_size x bg_size stimulus image, in normalised
%                          luminance units.
%     stim_bg            - the background alone, before the target was pasted.
%     seed               - the RNG seed actually used.
%     mask               - logical target mask.
%     mask_edge          - logical image of the target mask boundary.
%     mask_normal        - rows x cols x 2 unit normals to that boundary.
%     mask_strip         - logical ribbon along the boundary, over which the
%                          edge power is computed.
%     white_noise_bg     - the white noise image that, filtered, gives this
%                          background.
%     white_noise_target - the same for the target texture.
%
%   Outputs 4 to 9 are only assigned when target_radius is nonzero, so asking
%   for them on a blank stimulus errors (B2.12). Passing only one of ml_b and
%   cont_b also errors (B2.5). Two further recorded bugs live in the
%   image-reference branches: line 159 tests texture_bg's img field to decide
%   how to build the *target* texture, and line 184 synthesises the target
%   from the background's Portilla-Simoncelli statistics (B1.4, B2.13). All
%   are left as they are.
%
%   Abhranil Das <abhranil.das@utexas.edu>
%   Center for Perceptual Systems, University of Texas at Austin
%
%   See also lib.TARGET_MASK, lib.CREATE_PINK_NOISE_SQUARE, lib.WHITEN,
%   lib.EDGE, lib.EDGE_VECTOR_IDEAL.

    parser = inputParser;
    parser.KeepUnmatched = true;
    % bg_size needs to be even, otherwise you get complex numbers.
    addParameter(parser, 'bg_size', 256, @(x) isscalar(x) && ~mod(x, 2));
    texture.type = 'pink_noise';  texture.exponent = 1;
    addParameter(parser, 'texture', texture, @(x) isstruct(x));
    addParameter(parser, 'texture_bg', [], @isstruct);
    addParameter(parser, 'seed', 'rand', @(x) isscalar(x) || strcmp(x, 'rand'));
    addParameter(parser, 'target_shape', 'circular', @(x) strcmp(x, 'circular') || isscalar(x));
    addParameter(parser, 'target_radius', 0, @isnumeric);
    addParameter(parser, 'target_radius_cont', 0.15, @isnumeric);
    addParameter(parser, 'target_loc', 'center', @(x) isvector(x) || strcmp(x, 'center'));
    addParameter(parser, 'target_or', 0, @isscalar);
    addParameter(parser, 'ml_b', [], @isscalar);
    addParameter(parser, 'cont_b', [], @isscalar);
    addParameter(parser, 'ml_t', 'match', @(x) isscalar(x) || strcmp(x, 'match'));
    addParameter(parser, 'cont_t', 'match', @(x) isscalar(x) || strcmp(x, 'match'));

    parse(parser, varargin{:});
    bg_size = parser.Results.bg_size;
    texture = parser.Results.texture;

    seed = parser.Results.seed;
    target_radius = parser.Results.target_radius;
    target_or = parser.Results.target_or;
    ml_b = parser.Results.ml_b;
    cont_b = parser.Results.cont_b;
    ml_t = parser.Results.ml_t;
    cont_t = parser.Results.cont_t;

    % set rng seed
    if strcmp(seed, 'rand')
        %         seed_struct=rng('shuffle');
        %         seed=seed_struct.Seed;
        seed = randi(intmax);
    end
    rng('default')
    rng(seed)

    % set up texture
    if ~isfield(texture, 'img')  % if this is a texture and not an image-reference
        if strcmp(texture.type, 'pink_noise') && ~isfield(texture, 'exponent')
            texture.exponent = 1;
        end
    end
    if any(strcmp(parser.UsingDefaults, 'texture_bg'))
        texture_bg = texture;
    else
        texture_bg = parser.Results.texture_bg;
        if strcmp(texture_bg.type, 'pink_noise') && ~isfield(texture_bg, 'exponent')
            texture_bg.exponent = 1;
        end
    end

    % create background
    if ~isfield(texture_bg, 'img') || isempty(texture_bg.img)  % if it is a texture
        if strcmp(texture_bg.type, 'pink_noise')
            stim_bg = lib.create_pink_noise_square(bg_size, texture_bg.exponent);
        elseif strcmp(texture_bg.type, 'ps')
            stim_bg = textureSynthesis(texture_bg.stats, [bg_size bg_size], texture_bg.Niter);
        end
    else  % if it is an image-reference
        % if it is a ps texture with only image-reference and not tx stats
        if strcmp(texture_bg.type, 'ps')
            % read image
            source_image = double(im2gray(imread(texture_bg.img)));

            % crop to square
            min_side = min(size(source_image));
            source_image = source_image(1:min_side, 1:min_side);

            % resize
            source_image = imresize(source_image, [bg_size bg_size]);

            n_scales = 4;           % Number of scales
            n_orientations = 4;     % Number of orientations
            neighborhood_size = 9;  % Spatial neighborhood is Na x Na coefficients
            n_synthesis_iter = 25;  % Number of iterations of synthesis loop
%         texture_bg=struct;
            texture_bg.stats = textureAnalysis(source_image, n_scales, n_orientations, ...
                neighborhood_size);
            texture_bg.Niter = n_synthesis_iter;
            stim_bg = textureSynthesis(texture_bg.stats, [bg_size bg_size], texture_bg.Niter);

        elseif strcmp(texture_bg.type, 'crop')
            source_image = double(im2gray(imread(texture_bg.img)));
            [n_source_rows, n_source_cols] = size(source_image);
            source_min_side = min(size(source_image));

            % set the size of the crop
            crop_size_bg = round(bg_size + (source_min_side - bg_size)*texture_bg.scale);
            crop_size_bg = crop_size_bg - mod(crop_size_bg, 2);  % round to even

            % crop a random square region
            % Ensure the crop is within bounds
            crop_col_bg = randi(n_source_cols - crop_size_bg + 1);
            crop_row_bg = randi(n_source_rows - crop_size_bg + 1);
            stim_bg = source_image(crop_row_bg:crop_row_bg+crop_size_bg-1, ...
                crop_col_bg:crop_col_bg+crop_size_bg-1);

            % resize
            stim_bg = imresize(stim_bg, [bg_size bg_size]);
        end
    end

    % adjust background luminance and contrast:
    if ~isempty(ml_b) || ~isempty(cont_b)
        stim_bg = (stim_bg - mean(stim_bg(:)))*ml_b*cont_b/std(stim_bg(:)) + ml_b;
    end
    % white noise that produces this background (with its particular ml and cont):
    white_noise_bg = lib.whiten(stim_bg);

    stim = stim_bg;

    % create target patch
    if target_radius
        % if this is a texture and not image-reference
        if ~isfield(texture_bg, 'img') || isempty(texture_bg.img)
            if strcmp(texture.type, 'pink_noise')
                [target_patch, white_noise_target] = ...
                    lib.create_pink_noise_square(bg_size, texture.exponent);
            elseif strcmp(texture.type, 'ps')
                target_patch = textureSynthesis(texture.stats, [bg_size bg_size], texture.Niter);
            end
        else  % if it is an image-reference
            if strcmp(texture.type, 'ps')
                % read image
                source_image = double(im2gray(imread(texture.img)));

                % crop to square
                min_side = min(size(source_image));
                source_image = source_image(1:min_side, 1:min_side);

                % resize
                source_image = imresize(source_image, [bg_size bg_size]);

                n_scales = 4;           % Number of scales
                n_orientations = 4;     % Number of orientations
                neighborhood_size = 9;  % Spatial neighborhood is Na x Na coefficients
                n_synthesis_iter = 25;  % Number of iterations of synthesis loop
%             texture=struct;
                texture.stats = textureAnalysis(source_image, n_scales, n_orientations, ...
                    neighborhood_size);
                texture.Niter = n_synthesis_iter;
                target_patch = textureSynthesis(texture_bg.stats, [bg_size bg_size], ...
                    texture_bg.Niter);

            elseif strcmp(texture_bg.type, 'crop')

                % set the size of the crop
                crop_size_target = 2*target_radius*crop_size_bg/bg_size;
                crop_size_target = crop_size_target - mod(crop_size_target, 2);  % round to even

                % crop a random square region
                % Ensure the crop is within bounds
                crop_col_target = randi(n_source_cols - crop_size_target + 1);
                crop_row_target = randi(n_source_rows - crop_size_target + 1);
                target_patch = source_image( ...
                    crop_row_target:crop_row_target+crop_size_target-1, ...
                    crop_col_target:crop_col_target+crop_size_target-1);

                % resize
                target_patch = imresize(target_patch, 2*target_radius*[1 1]);
            end
        end
    end

    % crop square target patch using mask and put on background
    if target_radius
        if ~strcmp(texture.type, 'crop')  % if this is not a crop
            [mask, mask_edge, mask_normal, mask_strip] = lib.target_mask(varargin{:});
            target_mask_nan = double(mask);
        else  % if it is an image-crop
            % create a tight mask
            [mask_tight, mask_edge_tight, mask_normal_tight, mask_strip_tight] = ...
                lib.target_mask('bg_size', 2*target_radius, 'target_radius', target_radius);
            target_mask_nan = double(mask_tight);

            % expand tight mask to the size of the image
            mask = false(bg_size);
            col_first = floor((bg_size - 2*target_radius) / 2) + 1;
            col_last = col_first + 2*target_radius - 1;
            row_first = floor((bg_size - 2*target_radius) / 2) + 1;
            row_last = row_first + 2*target_radius - 1;
            mask(row_first:row_last, col_first:col_last) = mask_tight;

        end
        blocked_bg = stim_bg.*mask;
        target_mask_nan(~target_mask_nan) = nan;

        if target_or
            % rotate target
            target_patch = imrotate(target_patch, target_or, 'crop');
        end
        target = target_patch.*target_mask_nan;

        % if target luminance is to match background luminance,
        if strcmp(ml_t, 'match')
            % match target luminance with blocked bg region.
            ml_t = mean(nonzeros(blocked_bg));
        end

        % if target contrast is to match background contrast,
        if strcmp(cont_t, 'match')
            % match target contrast with blocked bg region.
            cont_t = std(nonzeros(blocked_bg))/ml_t;
        end

        % adjust target luminance and contrast
        target = (target - mean(target(:), 'omitnan'))*ml_t*cont_t ...
            /std(target(:), 'omitnan') + ml_t;

        % put target on background
        stim(mask) = target(~isnan(target));

        % white noise that produces this target (with its particular ml and cont):
        target(isnan(target)) = 0;
        white_noise_target = lib.whiten(target);
    end
end
