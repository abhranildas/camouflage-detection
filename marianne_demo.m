%% generate specific pink noise stimulus
ml=0.5; % mean luminance
cont=0.15; % contrast
target_radius=64;
seed=1; % specifies the random seed, so it generates a specific stimulus

stim=lib.stimulus('seed',seed,'ml_b',ml,'cont_b',cont,'target_radius',target_radius);
% this function is inside the +lib folder.
% type 'doc lib.stimulus' for more help

figure(1);
subplot(2,1,1); vis.show_image(stim);

% compute edge vector and edge power
[edge_vector,edge_power]=lib.edge(stim); %should be 9.36978
% this function is also inside the +lib folder.
% type 'doc lib.edge' for more help

subplot(2,1,2); plot(edge_vector);
title(edge_power);

%% generate random pink noise stimulus
stim=lib.stimulus('ml_b',ml,'cont_b',cont,'target_radius',target_radius);
figure(2);
subplot(2,1,1); vis.show_image(stim);

[edge_vector,edge_power]=lib.edge(stim);
subplot(2,1,2); plot(edge_vector);
title(edge_power);

%% generate brown noise stimulus
texture.type='pink_noise'; % here pink noise means the entire f^(-a) noise family
texture.exponent=2; % f^(-2)
stim=lib.stimulus('texture',texture,'ml_b',ml,'cont_b',cont,'target_radius',target_radius);
figure(3);
subplot(2,1,1); vis.show_image(stim);

[edge_vector,edge_power]=lib.edge(stim);
subplot(2,1,2); plot(edge_vector);
title(edge_power);
