function h=csf_spatial_filter(ppd)
    %% invert CSF to spatial filter
    
    bg_size=256;
    
    % array of frequencies (cyc/deg)
    f = ones(bg_size);
    for i=1:bg_size
        for j=1:bg_size
            f(i,j)=norm([i-bg_size/2-1,j-bg_size/2-1]); % cyc/img
        end
    end
    f=f*ppd/bg_size; % cyc/deg
    
    % CSF spectral filter
    csf_fil=lib.csf_fitted(f);
    csf_fil=csf_fil/max(csf_fil(:));
    csf_fil(bg_size/2+1,bg_size/2+1)=1; % leave DC unchanged
    
    % CSF spatial filter
    h=fftshift(ifft2(ifftshift(csf_fil)));
%     h=h(128-50:128+50,128-50:128+50);