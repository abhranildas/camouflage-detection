function [dog, envelope] = difference_of_gaussians_2d(Parameters, bPlot)
% DIFFERENCE_OF_GAUSSIANS_2D  Create a difference-of-Gaussians patch.
%   [dog, envelope] = lib.difference_of_gaussians_2d(Parameters, bPlot)
%
%   Parameters is a struct with the following fields:
%       Parameters.stdCenter  (scalar or [X,Y])
%       Parameters.stdSurround
%       Parameters.pixperdeg
%       Parameters.size       (deg) (default: 6*std)
%       Parameters.offset     (deg) (scalar or [X,Y], default: 0)
%       Parameters.envelope   ('gau'/'coswin', default: 'coswin')
%       Parameters.dc         DC value (default: 0)
%
%   Output
%     dog      - difference of Gaussians (center minus surround, each
%                normalised to unit sum).
%     envelope - envelope of the D.O.G. (the surround, after normalising).
%
%   See also lib.GABOR_2D.
%
%   v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

    %% Check input
    GABOR_PARAMS = {'stdCenter', 'stdSurround', 'pixperdeg', 'sizeCenter', 'sizeSurround', ...
        'offset', 'envelope', 'dc', 'contrast'};
    param_fields = fieldnames(Parameters);
    has_params = ismember(GABOR_PARAMS, param_fields);

    % optional parameters
    for missing_param = GABOR_PARAMS(~has_params)
        switch (missing_param{1})
            case 'envelope'
                Parameters.envelope = 'coswin';
            case 'offset'
                Parameters.offset = [0, 0];
            case 'dc'
                Parameters.dc = 0;
            case 'contrast'
                Parameters.contrast = 1;
            case 'sizeSurround'
                Parameters.sizeSurround = 6*Parameters.stdSurround;
            case 'sizeCenter'
                Parameters.sizeCenter = 6*Parameters.stdCenter;
            case {'stdCenter', 'stdSurround', 'pixperdeg'}
                error('Insufficient gabor parameters.');
        end
    end

    %% Center
    % create coordinate mesh
    envelope_radius = floor(Parameters.sizeCenter/2 * Parameters.pixperdeg);
    x = (-envelope_radius:envelope_radius) / Parameters.pixperdeg;
    y = (-envelope_radius:envelope_radius) / Parameters.pixperdeg;
    [x_grid, y_grid] = meshgrid(x - Parameters.offset(1), y - Parameters.offset(2));

    radius_sq = (x_grid).^2 + (y_grid).^2;
    gabor_sd = geomean(Parameters.stdCenter);
    switch (Parameters.envelope)
        case 'gau'
            center = exp(-radius_sq/(2*gabor_sd^2));
        case 'coswin'
            center = lib.cos_window_2d(numel(x), 1, 0);
        otherwise
            center = ones(size(radius_sq));
    end

    %% Surround

    % create coordinate mesh
    envelope_radius = floor(Parameters.sizeSurround/2 * Parameters.pixperdeg);
    x = (-envelope_radius:envelope_radius) / Parameters.pixperdeg;
    y = (-envelope_radius:envelope_radius) / Parameters.pixperdeg;
    [x_grid, y_grid] = meshgrid(x - Parameters.offset(1), y - Parameters.offset(2));

    radius_sq = (x_grid).^2 + (y_grid).^2;
    gabor_sd = geomean(Parameters.stdSurround);
    switch (Parameters.envelope)
        case 'gau'
            surround = exp(-radius_sq/(2*gabor_sd^2));
        case 'coswin'
            surround = lib.cos_window_2d(numel(x), 1, 0);
        otherwise
            surround = ones(size(radius_sq));
    end

    surround = surround./(sum(surround(:)));
    center = center./(sum(center(:)));

    center = lib.embed_image_in_center(zeros(size(surround)), center, 1);
    dog = center - surround;
    envelope = surround;

    if (nargin >= 2 && bPlot)
        figure; subplot(1, 2, 1);
        imagesc(dog); axis square; colormap gray;
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        set(gca, 'fontsize', 14);
        xlabel('X');
        ylabel('Y');

        subplot(1, 2, 2);
        plot(1:size(dog, 1), dog(ceil(size(dog, 1)/2), 1:size(dog, 1)), '-k', 'LineWidth', 2);
        set(gca, 'TickDir', 'out');
        set(gcf, 'color', 'w');
        set(gca, 'fontsize', 14);
        xlim([0 size(dog, 1)]);
        xlabel('X');
        ylabel('Amplitude');
        axis square; box off;
    end
end
