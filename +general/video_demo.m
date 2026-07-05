kernel_size=[1 3];
ml=0.5;
cont=0.15;
target_radius=50;
bg_size=500;
texture_params.type='pink_noise';
seed=1;
n_samples=5e5;
stim_energy=nan(n_samples,4);
tic
parfor i=1:n_samples
    i
    rng('shuffle');
    target_loc=datasample(target_radius+1:bg_size-target_radius,2);
    target_or=unifrnd(0,360);
    stim=lib.stimulus(texture_params,seed,bg_size,target_radius,target_loc,target_or,ml,cont,ml,cont);
    e=lib.edge_energy(stim,target_radius,target_loc,kernel_size,'perp_ratio');
    stim_energy(i,:)=[target_loc target_or e]
end
toc

stim_energy=sortrows(stim_energy,4);
save('vislab_data/video_demo.mat','stim_energy');

% see one of these images
i=1;
target_loc=stim_energy(i,[1 2]);
target_or=stim_energy(i,3);
stim=lib.stimulus(texture_params,seed,bg_size,target_radius,target_loc,target_or,ml,cont,ml,cont);
vis.show_image(stim);
