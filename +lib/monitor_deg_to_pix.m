function position_px = monitorDegreesToPixels(position_deg, monitor_size, ppd)
% MONITORDEGREESTOPIXELS  Convert a position in degrees to pixels.
%   position_px = lib.monitorDegreesToPixels(position_deg, monitor_size, ppd)
%
%   The center of the monitor is at (0, 0).
%
%   Inputs
%     position_deg - position(s) relative to the center, in degrees. Third
%                    dimension indexes (x, y).
%     monitor_size - [width, height] of the monitor, in pixels.
%     ppd          - pixels per degree.
%
%   Output
%     position_px - absolute position, in pixels, same size as position_deg.
%
%   v1.0, 1/19/2016, Steve Sebastian <sebastian@utexas.edu>
%
%   See also experiment.LOADSTIMULICAMOUFLAGE.

    %%
    % Point in the center is (0,0)
    center_px = round(monitor_size./2);

    position_px_relative = position_deg.*ppd;

    position_px(:, :, 1) = center_px(1) + position_px_relative(:, :, 1);
    position_px(:, :, 2) = center_px(2) + position_px_relative(:, :, 2);
end
