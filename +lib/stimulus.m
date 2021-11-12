function [stim,mask,mask_edge,mask_normal,seed,wn_b,wn_t]=stimulus(varargin)
    
    parser=inputParser;
    parser.KeepUnmatched=true;
    addParameter(parser,'bg_size', 256, @(x) isscalar(x) && ~mod(x,2)); %bg_size needs to be even, otherwise you get complex numbers.
    s.type='pink_noise'; s.alpha=1;
    addParameter(parser,'texture',s, @isstruct);
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
        seed_struct=rng('shuffle');
        seed=seed_struct.Seed;
    else
        rng('default')
        rng(seed)
    end
    
    if strcmp(texture.type,'pink_noise')
        % create background
        if ~isfield(texture,'alpha')
            alpha=1;
        else
            alpha=texture.alpha;
        end
        stim=lib.create_pink_noise_square(bg_size,alpha);
        % if target present,
        if target_radius
            % create target
            [target_patch,wn_t]=lib.create_pink_noise_square(bg_size,alpha);
        end
    elseif strcmp(texture.type,'por_sim')
        % create background
        stim=textureSynthesis(texture.stats, [bg_size bg_size], texture.Niter);
        % if target present,
        if target_radius
            % create target
            target_patch=textureSynthesis(texture.stats, [bg_size bg_size], texture.Niter);
        end
    end
    
    if ~isempty(ml_b) || ~isempty(cont_b)
        % adjust background luminance and contrast:
        stim=(stim-mean(stim(:)))*ml_b*cont_b/std(stim(:))+ml_b;
    end
    
    % white noise that produces this background (with its particular ml and cont):
    wn_b=lib.whiten(stim);
    
    % if target present,
    if target_radius
        [mask,mask_edge,mask_normal]=lib.target_mask(varargin{:});
        blocked=stim.*mask;
        target_mask=double(mask);
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
        target=(target-nanmean(target(:)))*ml_t*cont_t/nanstd(target(:))+ml_t;
        
        % put target on background
        stim(mask)=target(~isnan(target));
        
        % white noise that produces this target (with its particular ml and cont):
        target(isnan(target))=0;
        wn_t=lib.whiten(target);
    end
