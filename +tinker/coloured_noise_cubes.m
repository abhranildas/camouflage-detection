% coloured_noise_cubes  Render a 1/f pink-noise volume as an animated GIF.
%
%     coloured_noise_cubes
%
% Script, no arguments. Synthesizes a bg_size x bg_size x bg_size 1/f
% (pink) noise cube (lib.create_pink_noise_cube) and writes each slice
% along the third dimension as one frame of an animated GIF, on a shared
% grayscale scale.
%
% Inputs: none (bg_size is a literal below).
% Output: writes brown_noise_cube.gif to the current directory; nothing
% returned (script).
%
% See also lib.create_pink_noise_cube.

%% coloured noise cube
bg_size = 256;
pink_noise_cube = lib.create_pink_noise_cube(bg_size, 2);
min_value = min(pink_noise_cube(:)); max_value = max(pink_noise_cube(:));
% for i_frame = 1:bg_size
%     i_frame%     imagesc(pink_noise_cube(:,:,i_frame),[min_value max_value]); colormap gray; axis image; axis off;
%     exportgraphics(gcf,'testAnimated.gif','Append',true);
% end

imagesc(pink_noise_cube(:, :, 1), [min_value max_value]); colormap gray; axis image; axis off;

frame_capture = getframe(gca); rgb_frame = frame2im(frame_capture);
[indexed_frame, color_map] = rgb2ind(rgb_frame, 512);
gif_filename = 'brown_noise_cube.gif';
imwrite(indexed_frame, color_map, gif_filename, 'gif', 'DelayTime', 0.04, 'Loopcount', inf);

for i_frame = 2:bg_size
    imagesc(pink_noise_cube(:, :, i_frame), [min_value max_value]); colormap gray; ...
        axis image; axis off;
    frame_capture(i_frame) = getframe(gca);
end
for i_frame = 2:bg_size
    rgb_frame = frame2im(frame_capture(i_frame));
    [indexed_frame, color_map] = rgb2ind(rgb_frame, 512);
    imwrite(indexed_frame, color_map, gif_filename, 'gif', 'DelayTime', 0.04, ...
        'WriteMode', 'append');
end
