function show_image(stim)
% SHOW_IMAGE  Display a stimulus image, marking clipped pixels.
%   vis.show_image(stim)
%
%   Inputs
%     stim - stimulus image, in normalised [0, 1] luminance units.
%
%   Output
%     none; displays the image in the current figure, with pixels clipped
%     below 0 shown red and pixels clipped above 255 shown white, against
%     an 8-bit grayscale colormap for the unclipped range.
%
%   See also lib.stimulus.

stim = stim*255;

% note clipped pixels
upper_clip = stim > 255;
lower_clip = stim < 0;

% clip clipped pixels
stim(upper_clip) = 255;
stim(lower_clip) = 0;

% gamma correction:
% stim_max = max(stim(:));
% stim = stim/stim_max;
% stim = sqrt(stim);
% stim = stim*stim_max;

% add back clipping info
stim(upper_clip) = 256;
stim(lower_clip) = -1;

colormap([1 1 1; gray(256); 1 0 0]); imagesc(stim, [0 255]); axis image; axis off;
