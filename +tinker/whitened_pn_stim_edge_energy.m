bg_size=256;
target_radius=64;
texture_params.type='pink_noise';
ml=.5;
cont=.15;

n_samples=9890000;

kernel_size=[1 3];

if exist('global_data/seed_energy_pink_noise_whitened.mat','file')==2
    load('global_data/seed_energy_pink_noise_whitened.mat')
    sample_start=seed_energy(end,1)+1;
    seed_energy=[seed_energy;nan(n_samples,3)];
else
    seed_energy=nan(n_samples,3);
    sample_start=1;
end

tic
parfor seed=sample_start:sample_start+n_samples-1
    seed
    
    % blank
    img_pink_b=lib.stimulus(texture_params,seed,bg_size,0,'center',0,ml,cont,'match','match');
    %figure; imagesc(stim_b); colormap gray; axis image; colorbar
    img_whitened_b=lib.whiten_pink_noise_square(img_pink_b);
    %figure; imagesc(wn_reverse_b); colormap gray; axis image; colorbar    
    
    % target
    img_pink_t=lib.stimulus(texture_params,seed,bg_size,target_radius,'center',0,ml,cont,'match','match');
    %figure; imagesc(stim_t); colormap gray; axis image; colorbar
    img_whitened_t=lib.whiten_pink_noise_square(img_pink_t);
    %figure; imagesc(wn_reverse_t); colormap gray; axis image; colorbar
    
    % Only compute perp_ratio energy
    e_b=lib.edge_energy(img_whitened_b,target_radius,'center',kernel_size,'grad_by_norm');
    e_t=lib.edge_energy(img_whitened_t,target_radius,'center',kernel_size,'grad_by_norm');
    seed_energy(seed,:)=[seed e_b e_t];
    
    % Compute multiple types of energies
%     this_seed_energies=[];
%     for type={'mag','cos','normal','grad_by_lum','grad_by_norm','grad_by_sd','perp_ratio'}        
%         e_b=lib.edge_energy(img_whitened_b,target_radius,'center',kernel_size,type);        
%         e_t=lib.edge_energy(img_whitened_t,target_radius,'center',kernel_size,type);
%         this_seed_energies=[this_seed_energies e_b e_t];
%     end
%     seed_energy(seed,:)=[seed this_seed_energies];
end
toc

save('global_data/seed_energy_pink_noise_whitened.mat','seed_energy');
