function [density, value] = pink_noise_dist(dimension, k_list, angle_step)
% pink_noise_dist  Theoretical point-value distribution of pink noise.
%
%     [density, value] = pink_noise_dist(dimension, k_list, angle_step)
%
% Builds the distribution of a single pixel's value in 1-D or 2-D pink
% noise, as the convolution of the distributions of its sinusoidal
% frequency components (each component is a uniformly-phased sinusoid,
% whose value follows an arcsine distribution).
%
% Inputs
%     dimension - 1 or 2, dimensionality of the pink noise.
%     k_list (cycles per signal) - frequencies to sum over.
%     angle_step (radians) - spacing of component wave orientations,
%         2-D only; ignored when dimension == 1.
% Output
%     density - probability density over value, same size as value.
%     value - the support of the distribution.
%
% See also tinker.pink_noise_line_dist, tinker.pink_noise.

value_range = 1/k_list(1);
d_value = value_range/100;
value_grid = -value_range:d_value:value_range;

density = 1;
for k = k_list
    % distribution of k-frequency sine
    value_grid_k = value_grid(abs(value_grid) < k^(-dimension/2));
    density_k = 1./(pi*(sqrt(1-(value_grid_k*k^(dimension/2)).^2)));
    % normalize:
    density_k = density_k/sum(density_k);
    if dimension == 2
        for angle = 0:angle_step:2*pi
            % convolve with previous distribution:
            density = conv(density, density_k);
        end
    elseif dimension == 1
        density = conv(density, density_k);
    end
end

% normalize to unit area:
density = density/d_value;

% set up support of the distribution:
value_num = (numel(density)-1)/2;
value = -value_num*d_value:d_value:value_num*d_value;
