function [density, value] = pink_noise_line_dist(log_k_min, log_k_max, d_log_k)
% pink_noise_line_dist  Theoretical point-value distribution of 1-D pink noise.
%
%     [density, value] = pink_noise_line_dist(log_k_min, log_k_max, d_log_k)
%
% Special case of tinker.pink_noise_dist for 1-D pink noise, with
% frequencies specified as a log-spaced range rather than an explicit
% list.
%
% Inputs
%     log_k_min, log_k_max - log10 of the lowest/highest frequency
%         (cycles per signal) to sum over.
%     d_log_k - log10 spacing of the frequency list.
% Output
%     density - probability density over value, same size as value.
%     value - the support of the distribution.
%
% See also tinker.pink_noise_dist, tinker.pink_noise_line.

value_range = 1/(10^log_k_min);
d_value = value_range/100;
value_grid = -value_range:d_value:value_range;

density = 1;
for k = 10.^(log_k_min:d_log_k:log_k_max)
    % distribution of k-frequency sine
    value_grid_k = value_grid(abs(value_grid) < 1/sqrt(k));
    density_k = 1./(pi*(sqrt(1-k*value_grid_k.^2)));
    % normalize:
    density_k = density_k/sum(density_k);
    % convolve with previous distribution:
    density = conv(density, density_k);
end

% normalize to unit area:
density = density/d_value;

% set up support of the distribution:
value_num = (numel(density)-1)/2;
value = -value_num*d_value:d_value:value_num*d_value;
