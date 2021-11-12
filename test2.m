bg_size=256;
target_radius=64;
texture.type='pink_noise'; texture.alpha=2;

n_samp=100;
stims=nan(bg_size,bg_size,n_samp);
edge_powers=nan(n_samp,1);

for i=1:n_samp
    i
    [stim,mask,mask_edge,mask_normal]=lib.stimulus('texture',texture,'target_shape',1,'target_radius',target_radius,'ml_b',.5,'cont_b',.15);
    stims(:,:,i)=stim;
    
    [edge,edge_field]=lib.edge_vector(stim,'mask',mask,'mask_edge',mask_edge,'mask_normal',mask_normal,'kernel_size',[1 3]);
    
    edge_power=lib.edge_measures(edge);
    edge_powers(i)=edge_power;
end

[edge_powers,idx]=sort(edge_powers);
stims_sorted=nan(bg_size,bg_size,n_samp);
for i=1:n_samp
    stims_sorted(:,:,i)=stims(:,:,idx(i));
end

for i=1:5:n_samp
%     subplot(2,1,1);
    vis.show_image(stims_sorted(:,:,i))
    % hold on
    % [X,Y]=meshgrid(1:256);
    % quiver(X,Y,edge_field(:,:,1),-edge_field(:,:,2),4,'y')
    % hold off
    
%     subplot(2,1,2);
%     plot(edge)
    title(edge_powers(i))
    pause()
end