bg_size=256;
lum=0.5;
cont=0.15;
target_radius=64;

n_samples=2e4-116;
kernel_sd=1;
n_edge=1e4; % # of elements in edge vector
n_spec=floor(n_edge/2)+1; % # of items in edge spectrum

% if exist('vislab_data/natural/edge_powers_camo.mat','file')==2
%     load('vislab_data/natural/edge_powers_camo.mat')
%     sample_start=size(edge_powers,1)+1;
%     edge_powers=[edge_powers;nan(n_samples,2)];
% else
%     edge_powers=nan(n_samples,2);
%     sample_start=1;
% end

% pink noise texture
texture.type='pink_noise';

% % Portilla-Simoncelli texture
% addpath(genpath('por_sim_tx_synth'))
% input_img='vislab_data/textures/natural/camo.png';
% im0=double(im2gray(imread(input_img)));
% Nsc = 4; % Number of scales
% Nor = 4; % Number of orientations
% Na = 9;  % Spatial neighborhood is Na x Na coefficients
% Niter = 25;	% Number of iterations of synthesis loop
% texture=struct;
% texture.type='ps';
% texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
% texture.Niter=Niter;

tic
for seed=1:1e3
    seed
    [stim_t,stim_b]=lib.stimulus('seed',seed,'texture',texture,'ml_b',0.5,'cont_b',0.15,'target_radius',target_radius);
    edge_power_b=lib.edge_measures_ideal(lib.edge_vector_ideal(stim_b));
    edge_power_t=lib.edge_measures_ideal(lib.edge_vector_ideal(stim_t));
    edge_powers_new(seed,:)=[edge_power_b,edge_power_t];
end
toc

% save('vislab_data/natural/edge_powers_camo.mat','edge_powers')