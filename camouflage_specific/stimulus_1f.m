function stim=stimulus_1f(seed,bg_size,target_radius,ml_b,cont_b,ml_t,cont_t)
if strcmp(seed,'rand')
    rng('shuffle')
else
    rng('default')
    rng(seed)
end

% generate background
bg=pink_noise_square(bg_size);

% adjust background luminance and contrast:
bg=bg*ml_b*cont_b/std(bg(:))+ml_b;

% if target present,
if target_radius
    mask=circular_mask(bg_size,target_radius);
    blocked=bg.*mask;
    % if target luminance is not specified,
    if ~exist('ml_t','var')
        % match target luminance with blocked bg region.
        ml_t=mean(nonzeros(blocked));
    end

    % if target contrast is not specified,
    if ~exist('cont_t','var')
        % match target contrast with blocked bg region.
        cont_t=std(nonzeros(blocked))/ml_t;
    end
    
    % generate target
    nanmask=mask; nanmask(~nanmask)=nan;
    target=pink_noise_square(bg_size).*nanmask;
    
    
    
    % adjust target luminance and contrast
    target=(target-nanmean(target(:)))*ml_t*cont_t/nanstd(target(:))+ml_t;
    
    % put target on background
    target(isnan(target))=0;
    stim=bg.*(1-mask)+target;
    
else
    stim=bg;
end
