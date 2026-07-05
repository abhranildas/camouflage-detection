%% Compute edge powers and edge vectors

bg_size=256;
lum=0.5;
cont=0.15;
target_radius=64;
target_loc='center';

n_samples=5;
kernel_sd=1;
n_edge=1e3; % # of elements in edge vector
n_spec=floor(n_edge/2)+1; % # of items in edge spectrum

if exist('vislab_data/edges_bark.mat','file')==2
    load('vislab_data/edges_bark.mat')
    sample_start=size(edges,1)+1;
    edge_powers=[edge_powers;nan(n_samples,2)];
    
    edges_b=[edges(:,:,1); nan(n_samples,n_edge)];
    edges_t=[edges(:,:,2); nan(n_samples,n_edge)];
    
    edge_ps_b=[edge_ps(:,:,1); nan(n_samples,n_spec)];
    edge_ps_t=[edge_ps(:,:,2); nan(n_samples,n_spec)];
    
    clear edges edge_ps
else
    edge_powers=nan(n_samples,2);
    edges_b=nan(n_samples,n_edge);
    edges_t=nan(n_samples,n_edge);
    edge_ps_b=nan(n_samples,n_spec);
    edge_ps_t=nan(n_samples,n_spec);
    sample_start=1;
end

% pink noise texture
% texture_params.type='pink_noise';

% bark texture with Portilla-Simoncelli
addpath(genpath('por_sim_tx_synth'))
input_img='vislab_data/bark.png';
im0=double(im2gray(imread(input_img)));
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
    stim=lib.stimulus(texture_params,seed,bg_size,0,target_loc,0,lum,cont,'match','match');
    edge_b=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
    edges_b(seed,:)=edge_b;
    [edge_power_b,~,edge_ps]=lib.edge_measures(edge_b);
    edge_ps_b(seed,:)=edge_ps;
    
    % target
    stim=lib.stimulus(texture_params,seed,bg_size,target_radius,target_loc,0,lum,cont,'match','match');
    edge_t=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
    edges_t(seed,:)=edge_t;
    [edge_power_t,~,edge_ps]=lib.edge_measures(edge_t);
    edge_ps_t(seed,:)=edge_ps;
    
    edge_powers(seed,:)=[edge_power_b,edge_power_t];    

end

toc

edges=cat(3,edges_b,edges_t);
edge_ps=cat(3,edge_ps_b,edge_ps_t);
clear edges_b edges_t edge_ps_b edge_ps_t

%save('vislab_data/edges_bark.mat','edges','edge_powers','edge_ps','-v7.3')
%% Verify that phases have no structure

n_samples=1e3;
edge_phases_pink_b=nan(n_samples,n_edge);
edge_phases_pink_t=nan(n_samples,n_edge);
edge_phases_white_b=nan(n_samples,n_edge);
edge_phases_white_t=nan(n_samples,n_edge);

parfor seed=1:n_samples
    seed
    
    % pink blank
    stim=lib.stimulus(texture_params,seed,bg_size,0,target_loc,0,0.5,0.15,'match','match');
    [~,~,~,~,~,edge_spectrum_phases]=lib.edge_shape(stim,target_radius,n_edge,0);
    edge_phases_pink_b(seed,:)=edge_spectrum_phases;
    
    % pink target
    stim=lib.stimulus(texture_params,seed,bg_size,target_radius,target_loc,0,0.5,0.15,'match','match');
    [~,~,~,~,~,edge_spectrum_phases]=lib.edge_shape(stim,target_radius,n_edge,0);
    edge_phases_pink_t(seed,:)=edge_spectrum_phases;
    
    % white blank
    stim=lib.whiten(lib.stimulus(texture_params,seed,bg_size,0,target_loc,0,0.5,0.15,'match','match'));
    [~,~,~,~,~,edge_spectrum_phases]=lib.edge_shape(stim,target_radius,n_edge,0);
    edge_phases_white_b(seed,:)=edge_spectrum_phases;
    
    % white target
    stim=lib.whiten(lib.stimulus(texture_params,seed,bg_size,target_radius,target_loc,0,0.5,0.15,'match','match'));
    [~,~,~,~,~,edge_spectrum_phases]=lib.edge_shape(stim,target_radius,n_edge,0);
    edge_phases_white_t(seed,:)=edge_spectrum_phases;
end

figure; histogram(edge_phases_pink_b,linspace(-pi,pi,100),'normalization','pdf'); xlim([-pi pi]); xlabel 'phase', ylabel 'PDF', title 'pink blank'
figure; histogram(edge_phases_pink_t,linspace(-pi,pi,100),'normalization','pdf'); xlim([-pi pi]); xlabel 'phase', ylabel 'PDF', title 'pink target'
figure; histogram(edge_phases_white_b,linspace(-pi,pi,100),'normalization','pdf'); xlim([-pi pi]); xlabel 'phase', ylabel 'PDF', title 'white blank'
figure; histogram(edge_phases_white_t,linspace(-pi,pi,100),'normalization','pdf'); xlim([-pi pi]); xlabel 'phase', ylabel 'PDF', title 'white target'

%% verify that edge power matches integral of psd
% Parseval's theorem for DFT
% https://en.wikipedia.org/wiki/Parseval%27s_theorem#Notation_used_in_physics

bg_size=256;                              % background width
target_radius=64;
cont=0.15;                                % image RMS contrast
lum=0.5;                                   % image mean luminance
texture_params.type='pink_noise';
seed=1;
n_edge=1e4;

stim=lib.stimulus(texture_params,seed,bg_size,target_radius,'center',0,lum,cont,'match','match');
[edge_norm,edge_mag]=lib.edge_vector(stim,target_radius,n_edge);
[edge_power,edge_norm_power,~,edge_psd,edge_ps]=lib.edge_measures(edge_norm,edge_mag);

edge_power
sum(edge_ps)/n_edge

%% LPR for exponential power distribution 

edge_ps_mean=mean(edge_ps);
%edge_exp_lpr=[sum(-diff(log(edge_ps_mean),1,3))-edge_ps_pink(:,:,1)*diff(1./edge_ps_mean,1,3)',...
%    sum(-diff(log(edge_ps_mean),1,3))-edge_ps_pink(:,:,2)*diff(1./edge_ps_mean,1,3)'];

template=ones(1,size(edge_ps,2));

%template_dc=(ps_mean(1,1,1)-ps_mean(1,1,2))/2;
template=-diff(1./edge_ps_mean,1,3);
template(1)=template(1)/2;
template(end)=template(end)/2;
%template=[template_dc, template(2:end)];

%template=[0, ones(1,500)];
edge_opt_tm=[edge_ps(:,:,1)*template',edge_ps(:,:,2)*template'];
results_opt_tm=classify_normals(edge_opt_tm(:,1),edge_opt_tm(:,2),'type','samp');

const=-diff(log(edge_ps_mean),1,3);
const(1)=const(1)/2;
edge_lpr=edge_opt_tm+sum(const);
results_lpr=classify_normals(edge_lpr(:,1),edge_lpr(:,2),'type','samp');

% classify
results_exp_lpr=classify_normals(edge_exp_lpr(:,1),edge_exp_lpr(:,2),'type','samp');
title(sprintf('edge exp LPR: d''=%.1f',results_exp_lpr.samp_opt_dprime))

% combine with edge power
edge_combined=permute(cat(3,edge_powers_pink,edge_exp_lpr), [1 3 2]);
results_combined=classify_normals(edge_combined(:,:,1),edge_combined(:,:,2),'type','samp');
xlabel 'edge power: d''=8.7';
ylabel(sprintf('edge exp LPR: d''=%.1f',results_exp_lpr.samp_opt_dprime))
title(sprintf('combined: d''=%.1f',results_combined.samp_opt_dprime))

sigma=std(edges(:,:,1),0,'all');
hold off
histogram(edges(:,:,1).^2,'edgecolor','none','normalization','pdf');
hold on
fplot(@(x) chi2pdf(x/sigma^2,1)/sigma^2,[0 10])
set(gca,'yscale','log')


fplot(@(x) chi2pdf(x,1),[0 10])
hold on

l=1;
dx=.0001;
x=dx:dx:20;
p=sqrt(l./(2*pi*x.*exp(l*x)));
plot(x,p);
sum(p)*dx

mu=sum(p.*x)*dx
v=sum(p.*x.^2)*dx-mu^2

errs=nan(1,501);
for u=1:501
    u
    results=classify_normals(edge_ps_pink(:,u,1),edge_ps_pink(:,u,2),'type','samp','bplot',false);
    errs(u)=results.samp_opt_err;
end

%% Simple straight edge 

% stimulus parameters
bg_size=256;                              % background width
cont=0.15;                                % image RMS contrast
lum=0.5;                                   % image mean luminance
texture_params.type='pink_noise';

n_samples=8e5;
n_edge=bg_size;
n_spec=floor(n_edge/2)+1; % # of items in spectrum

% if exist('vislab_data/edge_measures.mat','file')==2
%     load('vislab_data/edge_measures.mat')
    sample_start=size(edge_powers,1)+1;
    edge_powers=[edge_powers; nan(n_samples,2)];
    edge_ps_b=[edge_ps(:,:,1); nan(n_samples,n_spec)];    
    edge_ps_t=[edge_ps(:,:,2); nan(n_samples,n_spec)];
    clear edge_ps
% else
%     edge_powers=nan(n_samples,2);    
%     edge_ps_b=nan(n_samples,n_spec);
%     edge_ps_t=nan(n_samples,n_spec);    
%     sample_start=1;
% end

tic
parfor seed=sample_start:sample_start+n_samples-1
    %seed
    
    % blank
    stim_b=lib.create_pink_noise_square(bg_size);
    stim_b_diff=diff(stim_b,1,2);
    edge=stim_b_diff(:,bg_size/2);
    [edge_power_b,~,edge_ps]=lib.edge_measures(edge);
    edge_ps_b(seed,:)=edge_ps; 
    
    % target
    stim_t=[stim_b,lib.create_pink_noise_square(bg_size)];
    stim_t_diff=diff(stim_t,1,2);
    edge=stim_t_diff(:,bg_size);
    [edge_power_t,~,edge_ps]=lib.edge_measures(edge);
    %edge_psd_pink(seed,:,2)=edge_psd;
    edge_ps_t(seed,:)=edge_ps;
    
    edge_powers(seed,:)=[edge_power_b,edge_power_t];
    
end

edge_ps=cat(3,edge_ps_b,edge_ps_t);
clear edge_ps_b edge_ps_t

results=classify_normals(edge_powers(:,1),edge_powers(:,2),'type','samp')
toc