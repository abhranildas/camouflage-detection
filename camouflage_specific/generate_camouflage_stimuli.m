tic
n_trials=1000;
bg_size=256;                              % background width
target_radius=64;
cont=0.15;                                % image RMS contrast
ml=0.5;                                   % image mean luminance

if exist('seed_energy.mat','file')==2
    load seed_energy.mat
    trial_start=seed_energy(end,1)+1;
else
    seed_energy=[];
    trial_start=1;
end

seed_energy=[seed_energy; zeros(n_trials,4)];

parfor trial_idx=trial_start:trial_start+n_trials-1   
    
    % display image
    % show_image(stim)
    
    % store seed and edge energies for stimulus:
    stim=stimulus_1f(trial_idx,bg_size,target_radius,ml,cont);
    seed_energy(trial_idx,:)=[trial_idx,edge_energy(stim,target_radius,1,3,'mag'),edge_energy(stim,target_radius,1,3,'dir'),edge_energy(stim,target_radius,1,3,'mag+dir')];
end
toc

save seed_energy.mat seed_energy

figure(1)
histogram(seed_energy(:,4))
[~,min_idx]=min(seed_energy(:,4));
[~,max_idx]=max(seed_energy(:,4));
figure(2)
show_image(stimulus_1f(seed_energy(min_idx,1),bg_size,target_radius,ml,cont))
figure(3)
show_image(stimulus_1f(seed_energy(max_idx,1),bg_size,target_radius,ml,cont))

% for i=1:20
%     figure
%     show_image(stimulus_1f(seed_energy(i,1),bg_size,target_radius,ml,cont))
% end
 





