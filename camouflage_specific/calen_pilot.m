%% Generate 1/f stimuli with and without target
tic
n_trials=1000;                           % number of stimuli to generate for either distribution
bg_size=256;                              % background size
target_radius=64;                        
ml_i=128;                                   % initial luminance
cont_i=0.15;                                % initial contrast

% initiate stimuli arrays
stimuli_b=zeros(bg_size,bg_size,n_trials);
stimuli_b_t=zeros(bg_size,bg_size,n_trials);

parfor trial=1:n_trials
	% generate and store stimuli
    stimuli_b(:,:,trial)=stimulus_1f(trial,bg_size,0,ml_i,cont_i); % bg only
    stimuli_b_t(:,:,trial)=stimulus_1f(trial,bg_size,target_radius,ml_i,cont_i,ml_i,cont_i); % bg + target
end
toc

save('calen_stimuli.mat','target_radius','stimuli_b','stimuli_b_t','ml_i','cont_i')
%% Plot edge energy distributions after varying ml and contrast of target and bg 

load calen_stimuli

ml_b=128;    % set new background luminance
cont_b=.15;  % set new background contrast
ml_t=128;   % set new target luminance
cont_t=.3;  % set new target contrast

plot_edge_energy_dists(stimuli_b,stimuli_b_t,target_radius,ml_i,cont_i,ml_b,cont_b,ml_t,cont_t)