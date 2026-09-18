% EDGE_POWER_DEMO  Edge vector and edge power of a few pink-noise stimuli.
%   Script, no arguments.
%
%   Three cells, each building one camouflage stimulus and drawing it above
%   its edge vector, with the edge power as the plot title:
%     1. a specific pink-noise stimulus, fixed by its random seed;
%     2. the same, with a fresh random seed each run;
%     3. brown noise, i.e. the same 1/f^exponent family with exponent 2.
%
%   Edit the parameters in the first cell to change the stimulus; they carry
%   over to the later cells.
%
%   Inputs
%     none.
%
%   Output
%     none (side effect: three figures).
%
%   See also lib.stimulus, lib.edge, vis.show_image.

%% edge power of a specific pink noise stimulus
luminance = 0.5;  % mean luminance, normalised (0 = black, 1 = white)
contrast = 0.15;  % RMS contrast, dimensionless
target_radius = 64;  % pixels
seed = 1;  % fixes the random draw, so this cell makes one specific stimulus

% lib.stimulus lives in the +lib folder; type 'doc lib.stimulus' for more.
stim = lib.stimulus('seed', seed, 'ml_b', luminance, 'cont_b', contrast, ...
    'target_radius', target_radius);

figure(1);
subplot(2, 1, 1);
vis.show_image(stim);

% Compute the edge vector and the edge power. lib.edge is also in +lib;
% type 'doc lib.edge' for more.
[edge_vector, edge_power] = lib.edge(stim);

subplot(2, 1, 2);
plot(edge_vector);
title(edge_power);

%% edge power of random pink noise stimulus
stim = lib.stimulus('ml_b', luminance, 'cont_b', contrast, ...
    'target_radius', target_radius);
figure(2);
subplot(2, 1, 1);
vis.show_image(stim);

[edge_vector, edge_power] = lib.edge(stim);
subplot(2, 1, 2);
plot(edge_vector);
title(edge_power);

%% edge power of random brown noise stimulus
texture.type = 'pink_noise';  % 'pink noise' here means the whole 1/f^exponent family
texture.exponent = 2;  % brown noise
stim = lib.stimulus('texture', texture, 'ml_b', luminance, 'cont_b', contrast, ...
    'target_radius', target_radius);
figure(3);
subplot(2, 1, 1);
vis.show_image(stim);

[edge_vector, edge_power] = lib.edge(stim);
subplot(2, 1, 2);
plot(edge_vector);
title(edge_power);
