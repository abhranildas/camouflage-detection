function [stim,stim_b,seed,mask,mask_edge,mask_normal,mask_strip,wn_b,wn_t]=stimulus(varargin)
% STIMULUS Generate camouflage stimulus image
%
% Abhranil Das <abhranil.das@utexas.edu>
% Center for Perceptual Systems, University of Texas at Austin
%
% Example:
% stim=lib.stimulus();
% stim=lib.stimulus('seed',1,'ml_b',0.5,'cont_b',0.15,'target_radius',64);
% texture.type='pink_noise';
% texture.exponent=2;
% stim=lib.stimulus('texture',texture,'target_radius',64);
%
% Required inputs: none
%
% Optional name-value inputs:
% bg_size               size (px) of the square stimulus image. Must be even.
% texture               struct containing texture details. Pink noise by
%                       default.
% seed                  random seed for generating the image. Random by default.
% target_shape          'circular' by default, or specify a number that is the
%                       1/f exponent of a filtered noise function of angle.
% target_radius         0 by default (no target).
% target_radius_cont    target radius contrast if it is a filtered noise function
% target_loc            2-element vector specifying target location. Center by default.
% target_or             target orientation, 0 by default.
% ml_b                  mean luminance of the background, as fraction
% cont_b                contrast of the background, as fraction
% ml_t                  mean luminance of target. By default it matches that of the exact background region it covers.
% cont_t                target contrast. By default it matches that of the exact background region it covers.
%
% Output(s):
% stim                  stimulus image
% stim_b                stimulus background only
% seed                  random seed used to generate the stimulus
% mask                  binary target mask image
% mask_edge             binary image of the target mask edge
% mask_normal           2 arrays specifying the x- and y- components of
%                       the normal vectors to the mask edge
% mask_strip            binary image of a thick strip along the mask edge
%                       over which the edge power is computed
% wn_b                  white noise image that was filtered to make
%                       background texture
% wn_t                  white noise image that was filtered to make
%                       target texture

parser=inputParser;
parser.KeepUnmatched=true;
addParameter(parser,'bg_size', 256, @(x) isscalar(x) && ~mod(x,2)); % bg_size needs to be even, otherwise you get complex numbers.
texture.type='pink_noise'; texture.exponent=1;
addParameter(parser,'texture',texture, @(x) isstruct(x));
addParameter(parser,'texture_bg',[], @isstruct);
addParameter(parser,'seed','rand', @(x) isscalar(x) || strcmp(x,'rand'));
addParameter(parser,'target_shape', 'circular', @(x) strcmp(x,'circular') || isscalar(x));
addParameter(parser,'target_radius', 0, @isnumeric);
addParameter(parser,'target_radius_cont', 0.15, @isnumeric);
addParameter(parser,'target_loc', 'center', @(x) isvector(x) || strcmp(x,'center'));
addParameter(parser,'target_or', 0, @isscalar);
addParameter(parser,'ml_b', [], @isscalar);
addParameter(parser,'cont_b', [], @isscalar);
addParameter(parser,'ml_t', 'match', @(x) isscalar(x) || strcmp(x,'match'));
addParameter(parser,'cont_t', 'match', @(x) isscalar(x) || strcmp(x,'match'));

parse(parser,varargin{:});
bg_size=parser.Results.bg_size;
texture=parser.Results.texture;

seed=parser.Results.seed;
target_radius=parser.Results.target_radius;
target_or=parser.Results.target_or;
ml_b=parser.Results.ml_b;
cont_b=parser.Results.cont_b;
ml_t=parser.Results.ml_t;
cont_t=parser.Results.cont_t;

% set rng seed
if strcmp(seed,'rand')
    %         seed_struct=rng('shuffle');
    %         seed=seed_struct.Seed;
    seed=randi(intmax);
end
rng('default')
rng(seed)

% set up texture
if ~isfield(texture,'img') % if this is a texture and not an image-reference
    if strcmp(texture.type,'pink_noise') && ~isfield(texture,'exponent')
        texture.exponent=1;
    end
end
if any(strcmp(parser.UsingDefaults,'texture_bg'))
    texture_bg=texture;
else
    texture_bg=parser.Results.texture_bg;
    if strcmp(texture_bg.type,'pink_noise') && ~isfield(texture_bg,'exponent')
        texture_bg.exponent=1;
    end
end

% create background
if ~isfield(texture_bg,'img')||isempty(texture_bg.img) % if it is a texture
    if strcmp(texture_bg.type,'pink_noise')
        stim_b=lib.create_pink_noise_square(bg_size,texture_bg.exponent);
    elseif strcmp(texture_bg.type,'ps')
        stim_b=textureSynthesis(texture_bg.stats, [bg_size bg_size], texture_bg.Niter);
    end
else % if it is an image-reference
    % if it is a ps texture with only image-reference and not tx stats
    if strcmp(texture_bg.type,'ps')
        % read image
        img=double(im2gray(imread(texture_bg.img)));

        % crop to square
        min_size=min(size(img));
        img=img(1:min_size,1:min_size);

        % resize
        img=imresize(img,[bg_size bg_size]);

        Nsc = 4; % Number of scales
        Nor = 4; % Number of orientations
        Na = 9;  % Spatial neighborhood is Na x Na coefficients
        Niter = 25;	% Number of iterations of synthesis loop
%         texture_bg=struct;
        texture_bg.stats=textureAnalysis(img, Nsc, Nor, Na);
        texture_bg.Niter=Niter;
        stim_b=textureSynthesis(texture_bg.stats, [bg_size bg_size], texture_bg.Niter);

    elseif strcmp(texture_bg.type,'crop')
        img=double(im2gray(imread(texture_bg.img)));
        [rows,cols]=size(img);
        img_min_size=min(size(img));

        % set the size of the crop
        crop_size_b=round(bg_size+(img_min_size-bg_size)*texture_bg.scale);
        crop_size_b=crop_size_b-mod(crop_size_b,2); % round to even

        % crop a random square region
        xb=randi(cols-crop_size_b+1);  % Ensure the crop is within bounds
        yb=randi(rows-crop_size_b+1);
        stim_b=img(yb:yb+crop_size_b-1,xb:xb+crop_size_b-1);

        % resize
        stim_b=imresize(stim_b,[bg_size bg_size]);
    end
end

% adjust background luminance and contrast:
if ~isempty(ml_b) || ~isempty(cont_b)
    stim_b=(stim_b-mean(stim_b(:)))*ml_b*cont_b/std(stim_b(:))+ml_b;
end
% white noise that produces this background (with its particular ml and cont):
wn_b=lib.whiten(stim_b);

stim=stim_b;

% create target patch
if target_radius
    if ~isfield(texture_bg,'img')||isempty(texture_bg.img) % if this is a texture and not image-reference
        if strcmp(texture.type,'pink_noise')
            [target_patch,wn_t]=lib.create_pink_noise_square(bg_size,texture.exponent);
        elseif strcmp(texture.type,'ps')
            target_patch=textureSynthesis(texture.stats, [bg_size bg_size], texture.Niter);
        end
    else % if it is an image-reference
        if strcmp(texture.type,'ps')
            % read image
            img=double(im2gray(imread(texture.img)));

            % crop to square
            min_size=min(size(img));
            img=img(1:min_size,1:min_size);

            % resize
            img=imresize(img,[bg_size bg_size]);

            Nsc = 4; % Number of scales
            Nor = 4; % Number of orientations
            Na = 9;  % Spatial neighborhood is Na x Na coefficients
            Niter = 25;	% Number of iterations of synthesis loop
%             texture=struct;
            texture.stats=textureAnalysis(img, Nsc, Nor, Na);
            texture.Niter=Niter;
            target_patch=textureSynthesis(texture_bg.stats, [bg_size bg_size], texture_bg.Niter);

        elseif strcmp(texture_bg.type,'crop')

            % set the size of the crop
            crop_size_t=2*target_radius*crop_size_b/bg_size;
            crop_size_t=crop_size_t-mod(crop_size_t,2); % round to even

            % crop a random square region
            xt=randi(cols-crop_size_t+1);  % Ensure the crop is within bounds
            yt=randi(rows-crop_size_t+1);
            target_patch=img(yt:yt+crop_size_t-1,xt:xt+crop_size_t-1);

            % resize
            target_patch=imresize(target_patch,2*target_radius*[1 1]);
        end
    end
end

% crop square target patch using mask and put on background
if target_radius
    if ~strcmp(texture.type,'crop') % if this is not a crop
        [mask,mask_edge,mask_normal,mask_strip]=lib.target_mask(varargin{:});
        target_mask=double(mask);
    else % if it is an image-crop
        % create a tight mask
        [mask_tight,mask_edge_tight,mask_normal_tight,mask_strip_tight]=lib.target_mask('bg_size',2*target_radius,'target_radius',target_radius);
        target_mask=double(mask_tight);

        % expand tight mask to the size of the image
        mask=false(bg_size);
        startX = floor((bg_size - 2*target_radius) / 2) + 1;
        endX = startX + 2*target_radius - 1;
        startY = floor((bg_size - 2*target_radius) / 2) + 1;
        endY = startY + 2*target_radius - 1;
        mask(startY:endY, startX:endX) = mask_tight;

    end
    blocked=stim_b.*mask;
    target_mask(~target_mask)=nan;

    if target_or
        % rotate target
        target_patch=imrotate(target_patch,target_or,'crop');
    end
    target=target_patch.*target_mask;

    % if target luminance is to match background luminance,
    if strcmp(ml_t,'match')
        % match target luminance with blocked bg region.
        ml_t=mean(nonzeros(blocked));
    end

    % if target contrast is to match background contrast,
    if strcmp(cont_t,'match')
        % match target contrast with blocked bg region.
        cont_t=std(nonzeros(blocked))/ml_t;
    end

    % adjust target luminance and contrast
    target=(target-mean(target(:),'omitnan'))*ml_t*cont_t/std(target(:),'omitnan')+ml_t;

    % put target on background
    stim(mask)=target(~isnan(target));

    % white noise that produces this target (with its particular ml and cont):
    target(isnan(target))=0;
    wn_t=lib.whiten(target);
end
