function noise_image = pink_noise_square_manual(n_side, k_list, angle_step)
% pink_noise_square_manual  Synthesize 2-D pink noise by explicit summation.
%
%     noise_image = pink_noise_square_manual(n_side, k_list, angle_step)
%
% Sums plane waves at each frequency in k_list and each orientation
% (spaced by angle_step), directly in the spatial domain rather than via
% an FFT filter -- a slow, literal implementation kept for cross-checking
% tinker.pink_noise's FFT-based method.
%
% Inputs
%     n_side (pixels) - side length of the square output image.
%     k_list (cycles per image) - frequencies to sum over.
%     angle_step (radians) - spacing of component wave orientations.
% Output
%     noise_image - the synthesized n_side x n_side pink-noise image.
%
% See also tinker.pink_noise, tinker.pink_noise_dist.

noise_image = zeros(n_side);
x_grid = repmat(1:n_side, [n_side, 1]);
y_grid = x_grid';

for k = k_list % component frequency
    for angle = 0:angle_step:2*pi % component direction
        freq_x = k*cos(angle); freq_y = k*sin(angle); % x_grid and y_grid freqs of component
        phase = unifrnd(0, 2*pi);
        wave = sin(freq_x*x_grid+freq_y*y_grid+phase)/k;
        noise_image = noise_image+wave;
    end
end
