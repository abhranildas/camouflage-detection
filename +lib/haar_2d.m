function [haar, envelope] = haar_2d(Parameters)
% HAAR_2D  Create a Haar-like edge patch with the given parameters.
%   [haar, envelope] = lib.haar_2d(Parameters)
%
%   Parameters is a struct with the following fields:
%       Parameters.pixperdeg
%       Parameters.size       (deg) (default: 6*std)
%       Parameters.dc         DC value (default: 0)
%       Parameters.contrast   Michelson contrast (default (100%): 1)
%       Parameters.type       Type of Haar: 'horizontal', 'vertical', or
%                             'bowtie' (default: 'vertical' when Parameters
%                             is omitted; otherwise required)
%
%   Output
%     haar     - the Haar patch, size_radius_px*2+1 (or *3 for 'bowtie')
%                square.
%     envelope - the disc-shaped support of the patch (haar_grid).
%
%   October 2, 2015, R. Calen Walshe <calen.walshe@utexas.edu>
%
%   See also lib.GABOR_2D, lib.DIFFERENCE_OF_GAUSSIANS_2D, lib.SPOT_2D.

    %% Check input
    if (nargin < 1)
        Parameters.pixperdeg = 60;
        Parameters.size = .35;
        Parameters.dc = 0;
        Parameters.type = 'vertical';
        Parameters.contrast = 1;
    else
        HAAR_PARAMS = {'pixperdeg', 'size', 'dc', 'contrast', 'type'};
        param_fields = fieldnames(Parameters);
        has_params = ismember(HAAR_PARAMS, param_fields);
        if (any(~has_params))
            error('Poorly specified haar parameter set');
        end
    end

    %% Create Haar grid x_grid and y_grid and transform it
    size_radius_px = floor(Parameters.size/2*Parameters.pixperdeg);
    radius = Parameters.size/2;   % radius of Haar

    x = (-size_radius_px:size_radius_px) / Parameters.pixperdeg;
    y = (size_radius_px:-1:-size_radius_px) / Parameters.pixperdeg;

    [x_grid, y_grid] = meshgrid(x, y);
    haar_grid = x_grid.^2 + y_grid.^2 < radius^2;

    % amplitude depends on requested contrast
    % but when dc == 0, contrast is undefined, so use unity amplitude
    if (Parameters.dc ~= 0)
        amplitude = Parameters.dc * Parameters.contrast;
    else
        amplitude = 1;
    end

    switch Parameters.type
        case ('horizontal')
            haar = [repmat(amplitude, size_radius_px, 2*size_radius_px+1); ...
                repmat(Parameters.dc, 1, 2*size_radius_px+1); ...
                repmat(-amplitude, size_radius_px, 2*size_radius_px+1)];
        case ('vertical')
            haar = [repmat(amplitude, 2*size_radius_px+1, size_radius_px), ...
                repmat(Parameters.dc, 2*size_radius_px+1, 1), ...
                repmat(-amplitude, 2*size_radius_px+1, size_radius_px)];   % vertical edge haar
        case ('bowtie')
            angle_grid = atan2(y_grid, x_grid);
            angle_grid(isnan(angle_grid(:))) = 0;   % middle pixel is NaN. We want it to be 0.

            haar = ones(size_radius_px*2 + 1) * Parameters.dc;

            haar(angle_grid > 0 & angle_grid < pi/2) = amplitude;
            haar(angle_grid > pi/2 & angle_grid < pi) = -amplitude;
            haar(angle_grid < 0 & angle_grid > -pi/2) = -amplitude;
            haar(angle_grid < -pi/2 & angle_grid > -pi) = amplitude;
        otherwise
            error('Haar type error');
    end

    haar = haar_grid .* haar;
    haar(haar == 0) = Parameters.dc;   % make the surround mean luminance.

    %% Envelope
    envelope = haar_grid;
end
