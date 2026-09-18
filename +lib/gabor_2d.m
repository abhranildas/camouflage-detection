function [gabor, envelope, sinusoid] = gabor_2d(Parameters, bPlot)
% GABOR_2D  Create a Gabor patch with the given parameters.
%   [gabor, envelope, sinusoid] = lib.gabor_2d(Parameters, bPlot)
%
%   Parameters is a struct with the following fields:
%       Parameters.std        (scalar or [X,Y])
%       Parameters.sf         (cpd)
%       Parameters.ori        (deg)
%       Parameters.phase      (deg)
%       Parameters.pixperdeg
%       Parameters.size       (deg) (default: 6*std)
%       Parameters.offset     (deg) (scalar or [X,Y], default: 0)
%       Parameters.odd_even   ('odd'/'even', default: 'odd')
%       Parameters.envelope   ('gau'/'coswin', default: 'coswin')
%       Parameters.dc         DC value (default: 0)
%       Parameters.contrast   Michelson contrast (default (100%): 1)
%
%   Output
%     gabor    - the Gabor target, envelope times sinusoid (plus dc), same
%                size as the coordinate grid.
%     envelope - envelope of the Gabor.
%     sinusoid - sinusoid of the Gabor.
%
%   See also lib.DIFFERENCE_OF_GAUSSIANS_2D.
%
%   v2.0, July 2, 2015, Yoon Bai, Steve Sebastian, and Spencer Chen <spencer.chen@utexas.edu>

    %% Check input
    GABOR_PARAMS = {'std', 'sf', 'ori', 'pixperdeg', 'size', 'phase', 'odd_even', ...
        'envelope', 'offset', 'dc', 'contrast'};
    param_fields = fieldnames(Parameters);
    has_params = ismember(GABOR_PARAMS, param_fields);

    % optional parameters
    for missing_param = GABOR_PARAMS(~has_params)
        switch (missing_param{1})
            case 'odd_even'
                Parameters.odd_even = 'odd';
            case 'envelope'
                Parameters.envelope = 'coswin';
            case 'offset'
                Parameters.offset = 0;
            case 'dc'
                Parameters.dc = 0;
            case 'contrast'
                Parameters.contrast = 1;
            case 'size'
                Parameters.size = 6*Parameters.std;
            case {'std', 'sf', 'ori', 'phase', 'pixperdeg'}
                error('Insufficient gabor parameters.');
        end
    end

    % scalar std means both X and Y are the same
    if (numel(Parameters.std) == 1)
        Parameters.std = [Parameters.std Parameters.std];
    end

    % scalar std means both X and Y are the same
    if (numel(Parameters.offset) == 1)
        Parameters.offset = [Parameters.offset Parameters.offset];
    end

    Parameters.sf = 2*pi*Parameters.sf;
    Parameters.ori = lib.deg2rad(Parameters.ori);
    Parameters.phase = lib.deg2rad(Parameters.phase);

    %% Create Gabor grid x_grid and y_grid and transform it

    % create coordinate mesh
    envelope_radius = floor(Parameters.size/2 * Parameters.pixperdeg);
    x = (-envelope_radius:envelope_radius) / Parameters.pixperdeg;
    y = (-envelope_radius:envelope_radius) / Parameters.pixperdeg;

    [x_grid, y_grid] = meshgrid(x - Parameters.offset(1), y - Parameters.offset(2));

    % rotate coordinate mesh
    x_grid_rot = x_grid*cos(Parameters.ori) - y_grid*sin(Parameters.ori);
    y_grid_rot = x_grid*sin(Parameters.ori) + y_grid*cos(Parameters.ori);

    % change coordinate aspect ratio
    aspect_ratio = Parameters.std(2) / Parameters.std(1);
    scale_y = sqrt(1/aspect_ratio);
    scale_x = aspect_ratio * scale_y;
    radius_sq = (scale_x*x_grid_rot).^2 + (scale_y*y_grid_rot).^2;

    % envelop
    gabor_sd = geomean(Parameters.std);
    switch (Parameters.envelope)
        case 'gau'
            envelope = exp(-radius_sq/(2*gabor_sd^2));
        case 'coswin'
            envelope = lib.cos_window_2d(numel(x), 1, 0);
        otherwise
            envelope = ones(size(radius_sq));
    end

    % sinusoid
    switch (Parameters.odd_even)
        case 'odd'
            sinusoid = cos(Parameters.sf*x_grid_rot - Parameters.phase);
        case 'even'
            sinusoid = sin(Parameters.sf*x_grid_rot - Parameters.phase);
        otherwise
            sinusoid = ones(size(x_grid_rot));
    end

    % amplitude depends on requested contrast
    % but when dc == 0, contrast is undefined, so use unity amplitude
    if (Parameters.dc ~= 0)
        amplitude = Parameters.dc * Parameters.contrast;
    else
        amplitude = 1;
    end

    % output
    gabor = envelope .* sinusoid * amplitude + Parameters.dc;

    %%
    if (nargin >= 2 && bPlot)
        imagesc(gabor, [0 255]);
        colormap(gray);
    end
end
