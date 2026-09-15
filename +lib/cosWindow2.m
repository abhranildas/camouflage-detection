function cos_window = cosWindow2(window_size, window_factor, bPlot)
% COSWINDOW2  2D raised-cosine (Hann-like) window.
%   cos_window = lib.cosWindow2(window_size, window_factor, bPlot)
%
%   Inputs
%     window_size   - scalar or [rows, cols] window size, in pixels.
%     window_factor - (optional) 1/window_factor must be an integer; scales
%                     the radius at which the window reaches zero. Default 1.
%     bPlot         - (optional) if true, plots the window. Default false.
%
%   Output
%     cos_window - window_size(1) x window_size(2) array, 1 at the centre,
%                  falling to 0 at radius window_factor*min(window_size)/2.
%
%   v1.0 Johannes Burge
%
%   See also lib.COSDRADIAL.

    %% Input handling
    if ~exist('window_factor', 'var') || isempty(window_factor)
        window_factor = 1;
    end
    if ~exist('bPlot', 'var')
        bPlot = 0;
    end
    if length(window_size) == 1
        window_size = repmat(window_size, 1, 2);
    end
    window_size_min = min(window_size);

    % Check for legal values of window_factor
    if rem(1, window_factor) ~= 0
        error(['cosWindow: window_factor must divide zero evenly. Current value = ' ...
            num2str(window_factor)]);
    end

    if mod(window_size_min, 2) == 0   % Even
        pos = (-window_size_min/2):(window_size_min/2-1);
    elseif mod(window_size_min, 2) == 1   % Odd
        pos = (-(window_size_min-1)/2):((window_size_min-1)/2);
    end

    %%

    [x_grid, y_grid] = meshgrid(pos);
    radius_grid = sqrt(x_grid.^2 + y_grid.^2);
    hann_window_radius = max(abs(x_grid(:))).*window_factor;

    cos_window = lib.cosdRadial(x_grid, y_grid, .5/hann_window_radius, .5, .5, 0);

    cos_window(radius_grid >= hann_window_radius) = 0;

    if bPlot
        figure; surf(cos_window, 'edgecolor', 'none'); title('Cosine Window', 'fontsize', 15);
        axis tight; box on; zlim([0 1])
    end
end
