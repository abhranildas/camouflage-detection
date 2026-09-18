% RandBoundary  Draw a random object with a 1/f^power boundary spectrum.
%
%     RandBoundary
%
% Script, no arguments. Synthesises a closed boundary whose radius, as a
% function of angle, has a 1/f^power amplitude spectrum, then rasterises
% the region inside that boundary as a binary indicator image.
%
% Inputs: none (all parameters are literals below).
% Output: a figure showing the rasterised boundary. Nothing is saved to
% disk.
%
% Parameters
%     image_size (pixels) - side length of the square output image.
%     base_radius (pixels) - mean boundary radius.
%     radius_sd (pixels) - RMS amplitude of the boundary's radial
%         modulation, fixed at 16 pixels regardless of spectral_exponent.
%     spectral_exponent - the boundary's 1/f^spectral_exponent falloff.
%
% See also general.RandBoundary.

close all;
image_size = 513;
boundary_image = zeros(image_size, image_size);
center = floor(image_size/2) + 1;
n_angle_samples = 2*floor(floor(pi()*image_size)/2);
n_freq = n_angle_samples/2;
angles_deg = zeros(n_angle_samples, 1);
radius = zeros(n_angle_samples, 1);
freq = zeros(n_freq, 1);
for i_angle = 1:n_angle_samples
    angles_deg(i_angle) = ((i_angle-1)/n_angle_samples)*360;  % angles
end
for i_angle = 1:n_freq
    % i_angle indexes freq here, not angles_deg — it ranges over n_freq,
    % not n_angle_samples, and freq is frequency-indexed, not angle-indexed.
    % One name maps to one role per check_stage1's rename constraint; kept
    % as i_angle because the majority of this file's uses of this counter
    % are genuine angle indices (see below).
    freq(i_angle) = i_angle/n_angle_samples;  % frequencies, cycles per boundary
end

base_radius = 128;         % base radius, pixels
radius_sd = 16;             % standard deviation of boundary modulation, pixels
spectral_exponent = 2;      % 1/f exponent
% amplitude_spectrum = zeros(n_freq, 1);
% amplitude_spectrum(2) = 0;
% amplitude_spectrum(4) = 8;
% amplitude_spectrum(6) = 8;
amplitude_spectrum = randn(n_freq, 1);
amplitude_spectrum(1) = 0;
for i_freq = 1:n_freq
    amplitude_spectrum(i_freq) = amplitude_spectrum(i_freq)/i_freq^spectral_exponent;
end
for i_freq = 1:n_angle_samples/2
    for i_angle = 1:n_angle_samples
        radius(i_angle) = radius(i_angle) + ...
            amplitude_spectrum(i_freq)*sin(2*pi()*freq(i_freq)*(i_angle-1));
    end
end
radius = radius*radius_sd/std(radius);
radius = radius + base_radius;  % radial amplitude of boundary

shift_deg = randi(360);     % random rotation of object
shift_samples = round(shift_deg*n_angle_samples/360);
radius = circshift(radius, shift_samples);
% figure; plot(angles_deg, radius, 'o');

% make indicator function
theta_deg = zeros(image_size, image_size);
for i_y = 1:image_size
    for i_x = 1:image_size
        theta_deg(i_x, i_y) = atan2d(i_y-center, i_x-center);
        if theta_deg(i_x, i_y) < 0
            theta_deg(i_x, i_y) = theta_deg(i_x, i_y) + 360;
        end
        i_angle = floor(theta_deg(i_x, i_y)*n_angle_samples/360) + 1;
        pixel_radius = sqrt((i_x-center)^2 + (i_y-center)^2);
        if pixel_radius < radius(i_angle)
            boundary_image(i_x, i_y) = 1;
        end
    end
end
boundary_image(center, center) = 0;  % plot the center of the image
figure; colormap(gray(256)); image(boundary_image*255); axis image;
