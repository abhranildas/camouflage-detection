function plot_edge_energy_dists(stimuli_b,stimuli_b_t,target_radius,ml_i,cont_i,ml_b,cont_b,ml_t,cont_t)
% plots histograms of edge energies for 1/f samples with and without
% target.
tic
bg_size=size(stimuli_b,1);

% change luminance and contrast of background:
stimuli_b=(stimuli_b-ml_i)*(ml_b*cont_b)/(ml_i*cont_i)+ml_b;

% change luminance and contrast of target:
stimuli_b_t=(stimuli_b_t-ml_i)/(ml_i*cont_i);
mask=circular_mask(bg_size,target_radius);
stimuli_b_t=(stimuli_b_t*ml_t*cont_t+ml_t).*mask + (stimuli_b_t*ml_b*cont_b+ml_b).*(1-mask);

% plot example images:
figure
subplot('Position',[0.1 0.55 0.3 0.4])
show_image(stimuli_b(:,:,1));
subplot('Position',[0.6 0.55 0.3 0.4])
show_image(stimuli_b_t(:,:,1));

% initiate edge energy lists:
edge_energies_bg=zeros(size(stimuli_b,3),1);
edge_energies_bg_t=zeros(size(stimuli_b_t,3),1);

% compute edge energies:
parfor idx=1:length(edge_energies_bg)
    edge_energies_bg(idx)=edge_energy(stimuli_b(:,:,idx),target_radius);
    edge_energies_bg_t(idx)=edge_energy(stimuli_b_t(:,:,idx),target_radius);
end

% normalize edge energies by maximum possible value:
edge_energies_bg=edge_energies_bg/edge_energy(circular_mask(bg_size,target_radius),target_radius);
edge_energies_bg_t=edge_energies_bg_t/edge_energy(circular_mask(bg_size,target_radius),target_radius);

% plot the two distributions:
subplot('Position',[0.05 0.1 0.925 0.4])
histogram(edge_energies_bg,50,'LineStyle','none');
hold on
histogram(edge_energies_bg_t,50,'LineStyle','none');
xlim([0 1])
xlabel '(fractional) edge energy'
legend('background','background + target')
legend boxoff
set(gca,'FontSize',13)
mean(edge_energies_bg)
mean(edge_energies_bg_t)
toc




