lum=0.5;
cont=0.15;
target_radius=64;

n_samples=1e5-6060;
n_edge=1e3; % # of elements in edge vector

% if exist('global_data/edge_powers_D110.mat','file')==2
%     load('global_data/edge_powers_D110.mat')
%     sample_start=size(edge_powers,1)+1;
%     edge_powers=[edge_powers;nan(n_samples,2)];
% else
%     edge_powers=nan(n_samples,2);
%     sample_start=1;
% end

% Portilla-Simoncelli texture
addpath(genpath('por_sim_tx_synth'))
input_img='global_data/D110.gif';
im0=double(im2gray(imread(input_img)));
Nsc = 4; % Number of scales
Nor = 4; % Number of orientations
Na = 9;  % Spatial neighborhood is Na x Na coefficients
Niter = 25;	% Number of iterations of synthesis loop
texture=struct;
texture.type='por_sim';
texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
texture.Niter=Niter;

tic
parfor seed=1:1e5 %sample_start:sample_start+n_samples-1
    if any(isnan(edge_powers(seed,:)))
        seed
        % blank
        stim=lib.stimulus('texture',texture,'seed',seed,'ml_b',lum,'cont_b',cont);
        edge_b=lib.edge_vector_ideal(stim);
        edge_power_b=lib.edge_measures_ideal(edge_b);

        % target
        stim=lib.stimulus('texture',texture,'seed',seed,'target_radius',target_radius,'ml_b',lum,'cont_b',cont);
        edge_t=lib.edge_vector_ideal(stim);
        edge_power_t=lib.edge_measures_ideal(edge_t);

        edge_powers(seed,:)=[edge_power_b,edge_power_t];
    end
end
toc

save('global_data/edge_powers_D110.mat','edge_powers')