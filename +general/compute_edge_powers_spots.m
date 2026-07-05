bg_size=256;
lum=0.5;
cont=0.15;
target_radius=64;
target_loc='center';

n_samples=1e5-20;
kernel_sd=1;
n_edge=1e4; % # of elements in edge vector
n_spec=floor(n_edge/2)+1; % # of items in edge spectrum

if exist('vislab_data/edge_powers_spots.mat','file')==2
    load('vislab_data/edge_powers_spots.mat')
    sample_start=size(edge_powers,1)+1;
    edge_powers=[edge_powers;nan(n_samples,2)];
    
%     edges_b=[edges(:,:,1); nan(n_samples,n_edge)];
%     edges_t=[edges(:,:,2); nan(n_samples,n_edge)];
    
%     edge_ps_b=[edge_ps(:,:,1); nan(n_samples,n_spec)];
%     edge_ps_t=[edge_ps(:,:,2); nan(n_samples,n_spec)];
    
%     clear edges edge_ps
else
    edge_powers=nan(n_samples,2);
%     edges_b=nan(n_samples,n_edge);
%     edges_t=nan(n_samples,n_edge);
%     edge_ps_b=nan(n_samples,n_spec);
%     edge_ps_t=nan(n_samples,n_spec);
    sample_start=1;
end

% pink noise texture
% texture_params.type='pink_noise';

% Portilla-Simoncelli texture
addpath(genpath('por_sim_tx_synth'))
input_img='vislab_data/spots.jpg';
im0=double(rgb2gray(imread(input_img)));
Nsc = 4; % Number of scales
Nor = 4; % Number of orientations
Na = 9;  % Spatial neighborhood is Na x Na coefficients
Niter = 25;	% Number of iterations of synthesis loop
texture_params=struct;
texture_params.type='por_sim';
texture_params.stats=textureAnalysis(im0, Nsc, Nor, Na);
texture_params.Niter=Niter;

tic
parfor seed=sample_start:sample_start+n_samples-1
    seed
    
    % blank
    stim=lib.stimulus_spots(texture_params,seed,bg_size,0,target_loc,0,lum,cont);
    edge_b=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
%     edges_b(seed,:)=edge_b;
    edge_power_b=lib.edge_measures(edge_b);
%     edge_ps_b(seed,:)=edge_ps;
    
    % target
    stim=lib.stimulus_spots(texture_params,seed,bg_size,target_radius,target_loc,0,lum,cont);
    edge_t=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
%     edges_t(seed,:)=edge_t;
    edge_power_t=lib.edge_measures(edge_t);
%     edge_ps_t(seed,:)=edge_ps;
    
    edge_powers(seed,:)=[edge_power_b,edge_power_t];    
end
toc

% edges=cat(3,edges_b,edges_t);
% edge_ps=cat(3,edge_ps_b,edge_ps_t);
% clear edges_b edges_t edge_ps_b edge_ps_t

% edge_ps_mean=mean(edge_ps);
% template=-diff(1./edge_ps_mean,1,3);
% template([1 end])=template([1 end])/2;
% 
% const=-diff(log(edge_ps_mean),1,3);
% const([1 end])=const([1 end])/2;
% 
% edge_lpr=[edge_ps(:,:,1)*template',edge_ps(:,:,2)*template']+sum(const);

save('vislab_data/edge_powers_spots.mat','edge_powers')