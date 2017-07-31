function show_image(stim)
% display stimulus as image

stim=stim*255;

% note clipped pixels
upper_clip=stim>255;
lower_clip=stim<0;

%clip clipped pixels
stim(upper_clip)=255;
stim(lower_clip)=0;

% gamma correction:
% stim_max=max(stim(:));
% stim=stim/stim_max;
% stim = sqrt(stim);                 
% stim=stim*stim_max;

% add back clipping info
stim(upper_clip)=256;
stim(lower_clip)=-1;

colormap([0 0 1; gray(256); 1 0 0]); imagesc(stim,[0 255]); axis image; axis off;
colorbar

