function spot = spot_2d(stimulus_params)
% SPOT_2D  Create a pedestal (annular) spot stimulus.
%   spot = lib.spot_2d(stimulus_params)
%                                    ------
%                                   |  __  |
%                                   | |  | |
%                                   |  --  |
%                                    ------
%
%   Output
%     spot - the pedestal patch: a disc of one sign surrounded by an
%            annulus of the opposite sign, scaled so the whole patch
%            integrates to 0 under the envelope.
%
%   R. Calen Walshe 02/12/2016 (calen.walshe@utexas.edu)
%
%   See also lib.GABOR_2D, lib.HAAR_2D, lib.DIFFERENCE_OF_GAUSSIANS_2D.

    if nargin < 1
        stimulus_params.pixperdeg = 60;
        stimulus_params.size = .35;
        stimulus_params.dc = 0;
        stimulus_params.contrast = 1;
        stimulus_params.type = 'spot';
    end

    if (stimulus_params.dc ~= 0)
        amplitude = stimulus_params.dc * stimulus_params.contrast;
    else
        amplitude = 1;
    end

    param_names = {'pixperdeg', 'size', 'dc', 'contrast', 'type'};
    param_fields = fieldnames(stimulus_params);
    has_params = ismember(param_names, param_fields);
    if (any(~has_params))
        error('Poorly specified haar parameter set');
    end

    spot_radius_px = floor((stimulus_params.size/2)*stimulus_params.pixperdeg);

    interior_radius_deg = stimulus_params.size/2 * 1/sqrt(2);

    [x_grid, y_grid] = meshgrid(-spot_radius_px:spot_radius_px);

    dist_grid = sqrt(x_grid.^2 + y_grid.^2) ./ stimulus_params.pixperdeg;
    envelope = dist_grid < stimulus_params.size/2;

    spot = ones(size(dist_grid)) * -amplitude;
    spot(dist_grid >= interior_radius_deg) = amplitude;
    spot = spot .* envelope;

    % Number of pixels in the inner region
    n_inner = size(spot(dist_grid < interior_radius_deg), 1);
    % Number of pixels in the outer region.
    n_outer = size(spot(dist_grid(envelope) > interior_radius_deg), 1);

    % Scale the magnitude of the inner region. Region under the target envelope integrates to 0.
    spot(dist_grid < interior_radius_deg) = spot(dist_grid < interior_radius_deg) * n_outer/n_inner;
end
