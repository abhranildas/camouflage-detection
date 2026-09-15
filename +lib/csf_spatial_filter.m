function spatial_filter = csf_spatial_filter(ppd)
% CSF_SPATIAL_FILTER  Invert the CSF to a spatial-domain filter.
%   spatial_filter = lib.csf_spatial_filter(ppd)
%
%   Inputs
%     ppd - pixels per degree.
%
%   Output
%     spatial_filter - 256x256 spatial-domain filter, the inverse Fourier
%                      transform of the (normalised) CSF spectral filter.
%
%   See also lib.CSF_FITTED.

    %% invert CSF to spatial filter

    bg_size = 256;

    % array of frequencies (cyc/deg)
    spatial_freq_grid = ones(bg_size);
    for i_row = 1:bg_size
        for i_col = 1:bg_size
            % cyc/img
            spatial_freq_grid(i_row, i_col) = norm([i_row-bg_size/2-1, i_col-bg_size/2-1]);
        end
    end
    spatial_freq_grid = spatial_freq_grid*ppd/bg_size;   % cyc/deg

    % CSF spectral filter
    csf_filter = lib.csf_fitted(spatial_freq_grid);
    csf_filter = csf_filter/max(csf_filter(:));
    csf_filter(bg_size/2+1, bg_size/2+1) = 1;   % leave DC unchanged

    % CSF spatial filter
    spatial_filter = fftshift(ifft2(ifftshift(csf_filter)));
    %     h=h(128-50:128+50,128-50:128+50);
end
