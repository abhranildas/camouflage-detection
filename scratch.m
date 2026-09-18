% SCRATCH  Scratchpad of ad-hoc analysis cells, run one at a time by hand.
%   Script, no arguments.
%
%   Not a pipeline and not called by anything: a pile of independent cells
%   kept for re-use. Several of them depend on variables (ExpSettings,
%   SubjectExpFile, stims_all, stims_miss, bdry_strip) that this file never
%   creates and never loads, so they only run after a previous manual run has
%   left those in the workspace. Those names are deliberately left as found,
%   since guessing better ones would hide which cells are self-contained.
%
%   The cells, in order:
%     1. filter a stimulus with the eye's OTF, detect edge pixels, split them
%        into boundary and texture contours, and quiver their normals;
%     2. quiver the target-mask normals over a stimulus and plot its edge
%        vector;
%     3. fit an edge-response detection threshold;
%     4. collect the stimuli of the hit trials of an experiment;
%     5. average their gradient magnitudes into a classification image;
%     6. check the Canny detector's thresholds on one stimulus;
%     7. compute edge responses for every stimulus in an experiment;
%     8. fit a psychometric function using the "new edge" measure.
%
%   Inputs
%     none.
%
%   Output
%     none (side effect: figures, and printed fit results in cell 3).
%
%   See also lib.stimulus, lib.edge_props_stim, lib.edge_measures,
%   vislab.lib.otf_filter, experiment.analysis.compute_threshold_edge_response.

%% filter stimulus with OTF/CSF

% generate stimulus
% addpath(genpath('por_sim_tx_synth'))
% input_img='vislab-common/data/natural/foliage.jpg';
% im0=double(im2gray(imread((input_img))));
% Nsc = 4; % Number of scales
% Nor = 4; % Number of orientations
% Na = 9;  % Spatial neighborhood is Na x Na coefficients
% Niter = 25;  % Number of iterations of synthesis loop
% texture=struct;
% texture.type='por_sim';
% texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
% texture.Niter=Niter;
% seed=35096;

% stim=lib.stimulus('seed',seed,'texture',texture,'target_radius',64,'ml_b',0.5,'cont_b',0.15);

texture.type = 'pink_noise';
texture.exponent = 2;
stim = lib.stimulus('seed', 35096, 'texture', texture, 'target_radius', 64, ...
    'ml_b', 0.5, 'cont_b', 0.15);

ppd = 60;  % pixels per degree
stim_otf = vislab.lib.otf_filter(stim, ppd, 4, 555);  % 4 mm pupil, 555 nm

% Then find edges using zero-crossings of a DoG or LoG filter

figure;
imshow(stim);
hold on

% detect edge pixels over entire image:
edge_pixels = lib.detect_edge_pixels(stim_otf);

% separate into boundary and texture edge pixels
% ~4 px thick now, because the LoG kernel is bigger
[~, ~, ~, mask_strip] = lib.target_mask('kernel_size', [2, 2]);
boundary_edge_pixels = single(edge_pixels & mask_strip)';
% nan the non-boundary region, so the densities come out right
boundary_edge_pixels(~mask_strip) = nan;
texture_edge_pixels = single(edge_pixels & (~mask_strip))';
texture_edge_pixels(mask_strip) = nan;

[boundary_contour_props, mean_boundary_contour_props] = ...
    lib.edge_props_stim(stim_otf, 'edge_pixels', boundary_edge_pixels);
[texture_contour_props, mean_texture_contour_props] = ...
    lib.edge_props_stim(stim_otf, 'edge_pixels', texture_edge_pixels);

for i_contour = 1:length(boundary_contour_props)
    contour = boundary_contour_props(i_contour).contour;
    plot(contour(:, 1), contour(:, 2), 'r', 'marker', '.', 'markersize', 1);
    quiver(contour(:, 1), contour(:, 2), ...
        boundary_contour_props(i_contour).target_normal(:, 1), ...
        -boundary_contour_props(i_contour).target_normal(:, 2), 'y');
end

for i_contour = 1:length(texture_contour_props)
    contour = texture_contour_props(i_contour).contour;
    plot(contour(:, 1), contour(:, 2), 'b', 'marker', '.', 'markersize', 1);
    quiver(contour(:, 1), contour(:, 2), edge_vector(:, 1), -edge_vector(:, 2), 'y');
end

%%
target_radius = 64;  % pixels
texture.type = 'pink_noise';  texture.alpha = 2;

% [stim]=lib.stimulus('seed',1,'texture',texture,'target_radius',target_radius,'ml_b',.5,'cont_b',.15);
% [edge_profile,edge_field]=lib.edge_vector(stim,'kernel_size',[1 3]);

[stim, mask, mask_edge, mask_normal] = lib.stimulus('texture', texture, ...
    'target_shape', 1, 'target_radius', target_radius, 'ml_b', .5, 'cont_b', .15);
[edge_profile, edge_field, edge_normal_field] = lib.edge_vector(stim, 'mask', mask, ...
    'mask_edge', mask_edge, 'mask_normal', mask_normal, 'kernel_size', [1, 3]);

vis.show_image(stim)
hold on
[x_grid, y_grid] = meshgrid(1:256);
% quiver(x_grid,y_grid,edge_field(:,:,1),-edge_field(:,:,2),4,'y')
quiver(x_grid, y_grid, mask_normal(:, :, 1), -mask_normal(:, :, 2), 4, 'y')
hold off

figure;
plot(edge_profile)

edge_power = lib.edge_measures(edge_profile);
title(edge_power)

%% test new edge response based fitting
% No semicolon: this cell exists to print the fitted threshold, exponent and sigma.
[threshold, exponent, sigma] = ...
    experiment.analysis.compute_threshold_edge_response('noise_colour/ecc_0', 'optimal', 1, 0)

%% classification image: collect stimuli

hit_idx = find(ExpSettings.bTargetPresent & SubjectExpFile.response);
[trial_idx, level_idx, session_idx] = ind2sub(size(ExpSettings.bTargetPresent), hit_idx);
hit_stimuli = nan(256, 256, length(hit_idx));
% i_contour indexes hit trials here, not contours; the file's other four
% loops index contours, and one token gets one name per file.
for i_contour = 1:length(hit_idx)
    hit_stimuli(:, :, i_contour) = ExpSettings.stimuli(:, :, trial_idx(i_contour), ...
        level_idx(i_contour), session_idx(i_contour));
end
stims_all = cat(3, stims_all, hit_stimuli);

%% classification image
kernel_size = [2, 3];

stim_grad_magnitudes = nan(256, 256, length(hit_idx));
% i_contour indexes stimuli here, not contours -- see the note above.
for i_contour = 1:size(stims_miss, 3)
    stim_grad_magnitudes(:, :, i_contour) = ...
        vecnorm(lib.steerable_grad(stims_miss(:, :, i_contour), kernel_size), 2, 3);
end
classification_image = mean(stim_grad_magnitudes, 3);
figure;
imagesc(classification_image(50:200, 50:200));
colormap gray;
colorbar

%% check Canny thresholds
stim = ExpSettings.stimuli(:, :, 2, 10, 1);
figure;
vis.show_image(stim)

[~, ~, boundary_contours, texture_contours] = lib.edge_measures(stim);
figure;
vis.show_image(stim);
hold on;

for i_contour = 1:length(boundary_contours)
    contour = boundary_contours{i_contour};
    plot(contour(:, 1), contour(:, 2), 'y');
end

for i_contour = 1:length(texture_contours)
    contour = texture_contours{i_contour};
    plot(contour(:, 1), contour(:, 2), 'b');
end

%% compute responses of all images in experiment
stimuli = squeeze(num2cell(ExpSettings.stimuli, [1, 2]));
responses = cellfun(@(stim) lib.new_edge(stim, 'bdry_strip', bdry_strip), stimuli);

figure;
hold on
histogram(responses(ExpSettings.bTargetPresent))
histogram(responses(~ExpSettings.bTargetPresent))

figure;
hold on
plot(responses(ExpSettings.bTargetPresent), ...
    ExpSettings.edgePowers(ExpSettings.bTargetPresent), '.r')
plot(responses(~ExpSettings.bTargetPresent), ...
    ExpSettings.edgePowers(~ExpSettings.bTargetPresent), '.b')

%% fit pmf using new edge
[threshold, sigma, threshold_sd] = ...
    experiment.analysis.computeThreshold_new_edge('natural/foliage', 'neel', true, false);
