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

%% test new edge response based fitting
[th,n,sigma]=experiment.analysis.computeThreshold_edgeResponse('noise_colour/ecc_0','optimal',1,0)

%% classification image: collect stimuli

idx=find(ExpSettings.bTargetPresent & SubjectExpFile.response);
[iTrial,iLevel,iSession]=ind2sub(size(ExpSettings.bTargetPresent),idx);
stims=nan(256,256,length(idx));
for i=1:length(idx)
    stims(:,:,i)=ExpSettings.stimuli(:,:,iTrial(i),iLevel(i),iSession(i));
end
stims_all=cat(3,stims_all,stims);

%% classification image
kernel_size=[2 3];

stim_grads_all=nan(256,256,length(idx));
for i=1:size(stims_miss,3)
    stim_grads_all(:,:,i)=vecnorm(lib.steerable_grad(stims_miss(:,:,i),kernel_size),2,3);
end
class_img=mean(stim_grads_all,3);
figure; imagesc(class_img(50:200,50:200)); colormap gray; colorbar

%% new edge finding

% stim=ExpSettings.stimuli(:,:,2,10,1);

% generate stimulus
addpath(genpath('por_sim_tx_synth'))
input_img='global_data/foliage.jpg';
im0=double(im2gray(imread((input_img))));
Nsc = 4; % Number of scales
Nor = 4; % Number of orientations
Na = 9;  % Spatial neighborhood is Na x Na coefficients
Niter = 25;	% Number of iterations of synthesis loop
texture=struct;
texture.type='por_sim';
texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
texture.Niter=Niter;

seed=35096;

[stim,~,mask,mask_edge,~,bdry_strip]=lib.stimulus('seed',seed,'texture',texture,'target_radius',64,'ml_b',0.5,'cont_b',0.15);

stim=lib.stimulus('seed',seed,'texture',texture,'target_radius',0,'ml_b',0.5,'cont_b',0.15);

vis.show_image(stim); hold on
[response,bdry_contours,text_contours]=lib.new_edge(stim,'bdry_strip',bdry_strip);

for i=1:length(bdry_contours)
    contour=bdry_contours{i};
    plot(contour(:,1),contour(:,2),'y');
end

for i=1:length(text_contours)
    contour=text_contours{i};
    plot(contour(:,1),contour(:,2),'b');
end

%% check Canny thresholds
stim=ExpSettings.stimuli(:,:,2,10,1);
figure; vis.show_image(stim)

[~,~,bdry_contours,txtr_contours]=lib.edge_measures(stim);
figure; vis.show_image(stim); hold on; 

for i=1:length(bdry_contours)
    contour=bdry_contours{i};
    plot(contour(:,1),contour(:,2),'y');
end

for i=1:length(txtr_contours)
    contour=txtr_contours{i};
    plot(contour(:,1),contour(:,2),'b');
end

%% compute responses of all images in experiment
stimuli=squeeze(num2cell(ExpSettings.stimuli,[1 2]));
responses=cellfun(@(stim) lib.new_edge(stim,'bdry_strip',bdry_strip),stimuli);

figure; hold on
histogram(responses(ExpSettings.bTargetPresent))
histogram(responses(~ExpSettings.bTargetPresent))

figure; hold on
plot(responses(ExpSettings.bTargetPresent),ExpSettings.edgePowers(ExpSettings.bTargetPresent),'.r')
plot(responses(~ExpSettings.bTargetPresent),ExpSettings.edgePowers(~ExpSettings.bTargetPresent),'.b')

%% fit pmf using new edge
[th,sigma,threshold_sd]=experiment.analysis.computeThreshold_new_edge('natural/foliage', 'neel', true, false);

%% wiggly shape
texture.type='pink_noise'; texture.exponent=1;

[stim,mask,mask_edge,mask_normal]=lib.stimulus('bg_size',512,'texture',texture,'target_shape',3,'target_radius',128,'ml_b',.5,'cont_b',.15);
vis.show_image(stim)

[~,target_edge_power]=lib.edge(stim,'mask',mask,'mask_edge',mask_edge,'mask_normal',mask_normal,'kernel_size',[1 3]);

