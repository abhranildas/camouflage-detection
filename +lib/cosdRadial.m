function cos_grid = cosdRadial(x_deg, y_deg, freq_cyc_deg, amplitude, dc_offset, bPlot)
% COSDRADIAL  Radially symmetric cosine with a specified frequency.
%   cos_grid = lib.cosdRadial(x_deg, y_deg, freq_cyc_deg, amplitude, dc_offset, bPlot)
%
%   Radially symmetric cosine grating evaluated at locations x_deg, y_deg.
%
%   Inputs
%     x_deg, y_deg - coordinate grids, in degrees (e.g. from meshgrid).
%     freq_cyc_deg - spatial frequency of the cosine, in cycles/degree.
%     amplitude    - peak amplitude of the cosine, dimensionless.
%     dc_offset    - value added uniformly, same units as amplitude.
%     bPlot        - (optional) if true, plots the result. Default false.
%
%   Output
%     cos_grid - height of the cosine at each (x_deg, y_deg), same size as
%                the inputs.
%
%   Johannes Burge
%
%   See also lib.COSWINDOW2.

    if ~exist('bPlot')
        bPlot = 0;
    end

    phi = 0;
    cos_grid = amplitude.*cosd(360.*freq_cyc_deg.*sqrt(x_deg.^2 + y_deg.^2) + phi) + dc_offset;

    if bPlot == 1
        figure('position', [193 944 646 338]); subplot(1, 2, 1);
        imagesc(x_deg(1, :), y_deg(:, 1)', cos_grid);
        axis square;

        subplot(1, 2, 2);
        surf(x_deg(1, :), y_deg(:, 1)', cos_grid, 'edgecolor', 'none');
        axis square; box on

        colormap gray
    end
end
