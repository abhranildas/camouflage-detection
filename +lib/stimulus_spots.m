function stim=stimulus_spots(texture_params,seed,bg_size,target_radius,target_loc,target_or,ml,cont)
%bg_size needs to be even, otherwise you get complex numbers.

% set rng seed
if strcmp(seed,'rand')
    rng('shuffle')
else
    rng('default')
    rng(seed)
end

% create background
stim = textureSynthesis(texture_params.stats, [bg_size bg_size], texture_params.Niter);

% if target present,
if exist('target_radius','var') && target_radius
    % create target
    target_patch=textureSynthesis(texture_params.stats, [bg_size bg_size], texture_params.Niter);
end

% if target present,
if exist('target_radius','var') && target_radius
    
    % if target location is unspecified,
    if ~exist('target_loc','var')
        % set target location to center:
        target_loc='center';
    end
    
    mask=lib.circular_mask(bg_size,target_radius,target_loc);
    target_mask=double(lib.circular_mask(bg_size,target_radius,'center'));
    target_mask(~target_mask)=nan;
    
    if exist('target_or','var') && target_or
        % rotate target
        target_patch=imrotate(target_patch,target_or,'crop');
    end
    
    % crop target
    target=target_patch.*target_mask;
    
    % put target on background
    stim(mask)=target(~isnan(target));    
end

% adjust stimulus ml and cont,
if exist('ml','var') && exist('cont','var')
    stim=(stim-mean(stim(:)))*ml*cont/std(stim(:))+ml;
end

