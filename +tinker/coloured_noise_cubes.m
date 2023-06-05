%% coloured noise cube
bg_size=256;
cube_1f=lib.create_pink_noise_cube(bg_size,2);
min_value=min(cube_1f(:)); max_value=max(cube_1f(:));
% for i = 1:bg_size
%     i%     imagesc(cube_1f(:,:,i),[min_value max_value]); colormap gray; axis image; axis off;
%     exportgraphics(gcf,'testAnimated.gif','Append',true);
% end

imagesc(cube_1f(:,:,1),[min_value max_value]); colormap gray; axis image; axis off;

frame=getframe(gca); im=frame2im(frame);
[imind,cm] = rgb2ind(im,512);
filename='brown_noise_cube.gif';
imwrite(imind,cm,filename,'gif','DelayTime',0.04, 'Loopcount',inf);

for i=2:bg_size
    imagesc(cube_1f(:,:,i),[min_value max_value]); colormap gray; axis image; axis off;
    frame(i)=getframe(gca);
end
for i=2:bg_size
    im=frame2im(frame(i));
    [imind,cm] = rgb2ind(im,512);
    imwrite(imind,cm,filename, 'gif','DelayTime',0.04,'WriteMode','append');
end