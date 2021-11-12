target_radius=64;
texture.type='pink_noise'; texture.alpha=2;

% [stim]=lib.stimulus('seed',1,'texture',texture,'target_radius',target_radius,'ml_b',.5,'cont_b',.15);
% [edge,edge_field]=lib.edge_vector(stim,'kernel_size',[1 3]);

[stim,mask,mask_edge,mask_normal]=lib.stimulus('texture',texture,'target_shape',1,'target_radius',target_radius,'ml_b',.5,'cont_b',.15);
[edge,edge_field,edge_normal_field]=lib.edge_vector(stim,'mask',mask,'mask_edge',mask_edge,'mask_normal',mask_normal,'kernel_size',[1 3]);

vis.show_image(stim)
hold on
[X,Y]=meshgrid(1:256);
% quiver(X,Y,edge_field(:,:,1),-edge_field(:,:,2),4,'y')
quiver(X,Y,mask_normal(:,:,1),-mask_normal(:,:,2),4,'y')
hold off

figure; plot(edge)

edge_power=lib.edge_measures(edge);
title(edge_power)

%% Edge normalized by L,C
target_radius=64;
texture.type='pink_noise'; texture.alpha=4;

stim=lib.stimulus('texture',texture,'target_radius',target_radius,'ml_b',.5,'cont_b',.15);
vis.show_image(stim)
edge=lib.edge_vector_LC(stim,'kernel_size',[1 3]);
figure; plot(edge,'-o')
[n_groups,l_groups,e_groups]=lib.edge_measures_LC(edge)


