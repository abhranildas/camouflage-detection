function stim_sd=local_sd(stim,kernel_size)
    % local luminance*contrast (std) of an image

    % define local patch neighbourhood
    nhood_radius=kernel_size(1)*kernel_size(2);
    nhood_size=2*ceil(nhood_radius)+1;
    nhood=false(nhood_size);
    nhood_center=(floor(nhood_size/2)+1)*[1 1];
    for i=1:nhood_size
        for j=1:nhood_size
            if norm([i,j]-nhood_center)<=nhood_radius
                nhood(i,j)=true;
            end
        end
    end
    stim_sd=stdfilt(stim,nhood);
end