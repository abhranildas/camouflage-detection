% plot_contour_props  Plot contour-level edge-property distributions
%     (density, length, edge power, curvature) for target vs. blank
%     boundary contours and for texture contours, then d' vs. level.
%
%     plot_contour_props
%
% Script, not a function — run it cell by cell. Expects `ExpSettings`,
% `SubjectExpFile`, and a family of undefined-here workspace variables
% (`dens_bd`/`dens_tx`, `length_bd`/`length_tx`, `ep1_bd`/`ep2_bd`/
% `ep4_bd`/`ep1_tx`/`ep2_tx`/`ep4_tx`, `curv_bd`/`curv_tx`, `cues_bd`) —
% per-contour edge-property arrays this repo never assigns anywhere
% (B3.11).
%
% Inputs: the workspace variables above; nothing from disk.
% Output: several figures (histograms, a 3-D edge-power scatter, and a
%     d' vs. level plot). Nothing is saved to disk.
%
% See also general.compute_edge_group_measures, general.compute_avg_acc_for_texture.

%% plot feature distributions for actual and perceived target vs blank

% select=SubjectExpFile.response;
target_present_mask = ExpSettings.bTargetPresent;

% no. of contours
% figure; hold on;
%
% % boundary
% histogram(num_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(num_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(num_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'no. of contours'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff



% no. density of contour pixels
figure; hold on;

% boundary
histogram(dens_bd(target_present_mask), 'facecolor', 'r', 'facealpha', .5, ...
    'edgecolor', 'none', 'normalization', 'pdf');
histogram(dens_bd(~target_present_mask), 'facecolor', 'b', 'facealpha', .5, ...
    'edgecolor', 'none', 'normalization', 'pdf');

% texture
histogram(dens_tx(:), 'facecolor', 'k', 'facealpha', .3, 'edgecolor', 'none', ...
    'normalization', 'pdf');

xlabel 'no. density of contour pixels'



% contour length
figure; hold on;

% boundary
histogram(length_bd(target_present_mask), 'facecolor', 'r', 'facealpha', .5, ...
    'edgecolor', 'none', 'normalization', 'pdf');
histogram(length_bd(~target_present_mask), 'facecolor', 'b', 'facealpha', .5, ...
    'edgecolor', 'none', 'normalization', 'pdf');

% texture
histogram(length_tx(:), 'facecolor', 'k', 'facealpha', .3, 'edgecolor', 'none', ...
    'normalization', 'pdf');

xlabel 'contour length'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff




% contour edge powers
figure; hold on; grid on

% boundary
plot3(ep1_bd(target_present_mask), ep2_bd(target_present_mask), ...
    ep4_bd(target_present_mask), '.r')
plot3(ep1_bd(~target_present_mask), ep2_bd(~target_present_mask), ...
    ep4_bd(~target_present_mask), '.b')

% texture
plot3(ep1_tx(:), ep2_tx(:), ep4_tx(:), '.k')

xlabel 'edge power (1px)'; ylabel 'edge power (2px)'; zlabel 'edge power (4px)'




% length-weighted contour edge powers
% figure; hold on; grid on
%
% % boundary
% plot3(ep1w_bd(select),ep2w_bd(select),ep4w_bd(select),'.r')
% plot3(ep1w_bd(~select),ep2w_bd(~select),ep4w_bd(~select),'.b')
%
% % texture
% plot3(ep1w_tx(:),ep2w_tx(:),ep4w_tx(:),'.k')
%
% xlabel 'edge power (1px)'; ylabel 'edge power (2px)'; zlabel 'edge power (4px)'




% % contour edge power (1px)
% figure; hold on;
%
% % boundary
% histogram(ep1_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(ep1_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(ep1_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'edge power (1px)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff
%
%
%
% % contour edge power (2px)
% figure; hold on;
%
% % boundary
% histogram(ep2_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(ep2_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(ep2_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'edge power (2px)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff
%
%
%
% % contour edge power (4px)
% figure; hold on;
%
% % boundary
% histogram(ep4_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(ep4_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(ep4_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'edge power (4px)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff
%


% curvature
figure; hold on;

% boundary
histogram(curv_bd(target_present_mask), 'facecolor', 'r', 'facealpha', .5, ...
    'edgecolor', 'none', 'normalization', 'pdf');
histogram(curv_bd(~target_present_mask), 'facecolor', 'b', 'facealpha', .5, ...
    'edgecolor', 'none', 'normalization', 'pdf');

% texture
histogram(curv_tx(:), 'facecolor', 'k', 'facealpha', .3, 'edgecolor', 'none', ...
    'normalization', 'pdf');

xlabel 'curvature (deg)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff

%% plot feature distributions block-by-block

cue_tx = ep4_tx;
cue_bd = cues_bd.dens;

target_present_mask = ExpSettings.bTargetPresent;
% select=SubjectExpFile.response;

% texture cue: all
mean_tx = mean(cue_tx, [1 3]);
sd_tx = std(cue_tx, 0, [1 3]);

% boundary cue: target
mean_true_target = nan(1, ExpSettings.nLevels);
sd_true_target = nan(size(mean_true_target));

% boundary cue: blank
mean_true_blank = nan(size(mean_true_target));
sd_true_blank = nan(size(mean_true_target));


for i_level = 1:ExpSettings.nLevels
    cue_this_level = cue_bd(:, i_level, :);
    true_this_level = target_present_mask(:, i_level, :);

    mean_true_target(i_level) = mean(cue_this_level(true_this_level));
    sd_true_target(i_level) = std(cue_this_level(true_this_level));

    mean_true_blank(i_level) = mean(cue_this_level(~true_this_level));
    sd_true_blank(i_level) = std(cue_this_level(~true_this_level));
end

figure; hold on
errorbar(mean_true_target, sd_true_target, '-or')
errorbar(mean_true_blank, sd_true_blank, '-ob')
errorbar(mean_tx, sd_tx, '-ok')
xlim([.5 10.5]); xlabel('level')

%% plot only d' of only bd features block-by-block

cue = cues_bd.dens;
figure; hold on; title 'edge power (4px)'

true_target = ExpSettings.bTargetPresent;

response_target = SubjectExpFile.response;

for i_level = 1:ExpSettings.nLevels
    cue_this_level = cue(:, i_level, :);
    true_this_level = true_target(:, i_level, :);
    response_this_level = response_target(:, i_level, :);

    mean_true_target(i_level) = mean(cue_this_level(true_this_level));
    sd_true_target(i_level) = std(cue_this_level(true_this_level));

    mean_true_blank(i_level) = mean(cue_this_level(~true_this_level));
    sd_true_blank(i_level) = std(cue_this_level(~true_this_level));

    mean_response_target(i_level) = mean(cue_this_level(response_this_level));
    sd_response_target(i_level) = std(cue_this_level(response_this_level));

    mean_response_blank(i_level) = mean(cue_this_level(~response_this_level));
    sd_response_blank(i_level) = std(cue_this_level(~response_this_level));
end

% d'
d_prime_true = 2*(mean_true_target-mean_true_blank)./(sd_true_target+sd_true_blank);
d_prime_response = 2*(mean_response_target-mean_response_blank)./ ...
    (sd_response_target+sd_response_blank);

plot(d_prime_true, '-ok', 'markersize', 4, 'markerfacecolor', 'k')
plot(d_prime_response, '--ok', 'markersize', 4, 'markerfacecolor', 'k')
legend(sprintf("%.2f", mean(d_prime_true)), sprintf("%.2f", mean(d_prime_response)))
legend boxoff
axis([1 10 -1 7]); xlabel('level'); ylabel ("d'")
set(gca, 'xtick', [1 10])
