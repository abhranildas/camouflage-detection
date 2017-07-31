load seed_energy.mat    % load stimuli. column 1: seeds, column 2: edge energies

bg_size=256;        % background width
target_radius=64;                        
cont=0.05;          % image RMS contrast
ml=0.5;             % image mean luminance

n_bins=50;      % # of equal-width edge-energy bins to break the stimuli into
n_samples=1;    % # of stimuli to show from each edge energy bin
p_target=0;    % prob. of target present in stimulus
energy_type=4;  % 2: mag, 3: dir, 4: mag+dir

% break the loaded stimuli into edge energy bins and get bin edges
[energy_histcounts,energy_edges]=histcounts(seed_energy(:,energy_type),n_bins);

figure(1)
ax_hist=subplot('Position',[.05 .75 .9 .2]);
h=histogram(seed_energy(:,energy_type),n_bins);
xlim([energy_edges(1) energy_edges(end)])
xlabel 'edge energy'
set(gca,'YTick',[]);
ax_stim=subplot('Position',[.05 .05 .9 .55]);
h_marker=plot([energy_edges(1) energy_edges(2)],[0 0],'r','LineWidth',2);

% show some samples from each bin, in order, upon click/keypress:
for bin=1:length(energy_edges)-1
    stim_idcs=seed_energy((energy_edges(bin)<=seed_energy(:,energy_type)) & (seed_energy(:,energy_type)<energy_edges(bin+1)));
    i=1;
    %stim_idx=stim_idx(1:n_samples)'; % truncate to 5 samples from each energy bin, transpose to allow iteration
    while i<=min(n_samples,energy_histcounts(bin))
        subplot(ax_hist)
        delete(h_marker)
        hold on
        h_marker=plot([energy_edges(bin) energy_edges(bin+1)],[0 0],'r','LineWidth',2);
        subplot(ax_stim)
        if rand(1)<p_target  %with target probability,         
            % show target + background
            show_image(stimulus_1f(seed_energy(stim_idcs(i),1),bg_size,target_radius,ml,cont))
        else
            % show background only
            show_image(stimulus_1f('rand',bg_size,target_radius,ml,cont))
        end
        title(seed_energy(stim_idcs(i),1))
        %pause(1)
        waitforbuttonpress;
        i=i+1;
    end
end