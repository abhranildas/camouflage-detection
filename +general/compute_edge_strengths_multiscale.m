n_samples=1e5;
bg_size=256;                              % background width
target_radius=64;
cont=0.15;                                % image RMS contrast
ml=0.5;                                   % image mean luminance

n_edge=1e3;

% if exist('vislab_data/seed_energy_pn_gradbynorm.mat','file')==2
%     load('vislab_data/seed_energy_pn_gradbynorm.mat')
%     sample_start=seed_energy(end,1)+1;
%     seed_energy=[seed_energy;nan(n_samples,3)];
% else
    edge_powers_1=nan(n_samples,2);
    edge_powers_2=nan(n_samples,2);
    edge_powers_4=nan(n_samples,2);
    edge_powers_8=nan(n_samples,2);
    edge_powers_16=nan(n_samples,2);
    
    edge_powers_w_1=nan(n_samples,2);
    edge_powers_w_2=nan(n_samples,2);
    edge_powers_w_4=nan(n_samples,2);
    edge_powers_w_8=nan(n_samples,2);
    edge_powers_w_16=nan(n_samples,2);
    
    sample_start=1;
% end

% for pink noise texture:
texture_params.type='pink_noise';

% for bark texture with portilla simoncelli:
% addpath(genpath('por_sim_tx_synth'))
% input_img='vislab_data/bark.png';
% im0=double((imread(input_img)));
% 
% Nsc = 4; % Number of scales
% Nor = 4; % Number of orientations
% Na = 9;  % Spatial neighborhood is Na x Na coefficients
% Niter = 25;	% Number of iterations of synthesis loop
% 
% texture_params=struct;
% texture_params.type='por_sim';
% texture_params.stats=textureAnalysis(im0, Nsc, Nor, Na);
% texture_params.Niter=Niter;

tic
parfor seed=sample_start:sample_start+n_samples-1
    seed
    
    % pink
    
    stim_b=lib.stimulus(texture_params,seed,bg_size,0,'center',0,ml,cont,'match','match');
    stim_t=lib.stimulus(texture_params,seed,bg_size,target_radius,'center',0,ml,cont,'match','match');
    %stim_t=lib.whiten(stim_b);
    
    % kernel size 1:
    edge_powers_1(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b,target_radius,n_edge,1)),...
                            lib.edge_measures(lib.edge_vector(stim_t,target_radius,n_edge,1))];

    % kernel size 2:
    edge_powers_2(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b,target_radius,n_edge,2)),...
                            lib.edge_measures(lib.edge_vector(stim_t,target_radius,n_edge,2))];

    % kernel size 4:
    edge_powers_4(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b,target_radius,n_edge,4)),...
                            lib.edge_measures(lib.edge_vector(stim_t,target_radius,n_edge,4))];

    % kernel size 8:
    edge_powers_8(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b,target_radius,n_edge,8)),...
                            lib.edge_measures(lib.edge_vector(stim_t,target_radius,n_edge,8))];

    % kernel size 16:
    edge_powers_16(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b,target_radius,n_edge,16)),...
                            lib.edge_measures(lib.edge_vector(stim_t,target_radius,n_edge,16))];


    % white
    
    stim_b_w=lib.whiten(stim_b);
    stim_t_w=lib.whiten(stim_t);
    
    % kernel size 1:
    edge_powers_w_1(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b_w,target_radius,n_edge,1)),...
                            lib.edge_measures(lib.edge_vector(stim_t_w,target_radius,n_edge,1))];

    % kernel size 2:
    edge_powers_w_2(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b_w,target_radius,n_edge,2)),...
                            lib.edge_measures(lib.edge_vector(stim_t_w,target_radius,n_edge,2))];

    % kernel size 4:
    edge_powers_w_4(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b_w,target_radius,n_edge,4)),...
                            lib.edge_measures(lib.edge_vector(stim_t_w,target_radius,n_edge,4))];
                        
    % kernel size 8:
    edge_powers_w_8(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b_w,target_radius,n_edge,8)),...
                            lib.edge_measures(lib.edge_vector(stim_t_w,target_radius,n_edge,8))];

    % kernel size 16:
    edge_powers_w_16(seed,:)=[ lib.edge_measures(lib.edge_vector(stim_b_w,target_radius,n_edge,16)),...
                            lib.edge_measures(lib.edge_vector(stim_t_w,target_radius,n_edge,16))];


end

toc

% save('vislab_data/seed_energy_pn_gradbynorm.mat', 'seed_energy');


%% d' with 1, 2 and 3 scales

results_3scale=classify_normals([edge_powers_1(:,1),edge_powers_2(:,1),edge_powers_4(:,1)],[edge_powers_1(:,2),edge_powers_2(:,2),edge_powers_4(:,2)],'type','samp');
xlim([0 1]); ylim([0.25 1]); zlim([0 1]);
results_3scale_w=classify_normals([edge_powers_w_1(:,1),edge_powers_w_2(:,1),edge_powers_w_4(:,1)],[edge_powers_w_1(:,2),edge_powers_w_2(:,2),edge_powers_w_4(:,2)],'type','samp');

results_4scale=classify_normals([edge_powers_1(:,1),edge_powers_2(:,1),edge_powers_4(:,1),edge_powers_8(:,1)],[edge_powers_1(:,2),edge_powers_2(:,2),edge_powers_4(:,2),edge_powers_8(:,2)],'type','samp');
results_4scale_w=classify_normals([edge_powers_w_1(:,1),edge_powers_w_2(:,1),edge_powers_w_4(:,1),edge_powers_w_8(:,1)],[edge_powers_w_1(:,2),edge_powers_w_2(:,2),edge_powers_w_4(:,2),edge_powers_w_8(:,2)],'type','samp');

results_5scale=classify_normals([edge_powers_1(:,1),edge_powers_2(:,1),edge_powers_4(:,1),edge_powers_8(:,1),edge_powers_16(:,1)],[edge_powers_1(:,2),edge_powers_2(:,2),edge_powers_4(:,2),edge_powers_8(:,2),edge_powers_16(:,2)],'type','samp');
results_5scale_w=classify_normals([edge_powers_w_1(:,1),edge_powers_w_2(:,1),edge_powers_w_4(:,1),edge_powers_w_8(:,1),edge_powers_w_16(:,1)],[edge_powers_w_1(:,2),edge_powers_w_2(:,2),edge_powers_w_4(:,2),edge_powers_w_8(:,2),edge_powers_w_16(:,2)],'type','samp');


