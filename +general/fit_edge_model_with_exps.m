% FIT_EDGE_MODEL_WITH_EXPS  Fit the edge model to the subjects' data and plot
%   model against human performance, experiment by experiment.
%
%   Script, not a function — run it cell by cell. It is the last step of the
%   live model chain: general.compute_nat_img_eff_coding_bins writes the
%   efficient-coding bins and the PCA rotation, general.compute_edge_props_exp_pca
%   turns an experiment's stimuli into combined edge features, and this script
%   reads those features, computes the model observer's d' at each level with
%   classify_normals, computes each subject's d' from their responses, fits one
%   efficiency scalar relating the two, and reports the variance explained. It
%   produces the paper's model figure.
%
%   Cells
%     1  Model and subject d' per level, per experiment, plus the per-feature
%        d' contribution bars, the efficiency fit, and the variance explained.
%     2  Scatter of model against subject d', to show how proportional they are.
%     3  A separate fit for the all-textures experiment, working in error rates
%        rather than d', using one overall decision boundary per texture.
%     4  Every texture shown with its subject and model accuracy.
%
%   Inputs (all read from disk, nothing is taken from the workspace)
%     exp_files/<exp_path>/exp_settings.mat      - ExpSettings.
%     exp_files/<exp_path>/edge_props_pca.mat    - edge_props, from
%                                                  general.compute_edge_props_exp_pca.
%     exp_files/<exp_path>/subject_out/*.mat     - one SubjectExpFile per subject.
%     exp_files/all/{exp_settings,edge_props,texture_list,subject_out/neel}.mat
%                                                - cells 3 and 4 only.
%
%   Output
%     none saved. Figures only: subject and model accuracy per level, the
%     stacked per-feature d' contribution bars, the d' scatter, the model
%     against subject error-rate plot, and one figure per texture. The
%     variance-explained numbers are printed by the deliberately unsuppressed
%     var_exp lines in cell 1. All d' values are dimensionless, all accuracies
%     and error rates are proportions in [0, 1].
%
%   Known defects on this path, recorded and not fixed here. B1.8: the
%   'eff', 0.34 passed to classify_normals below is silently discarded, because
%   that function sets KeepUnmatched and declares no eff parameter, and the
%   post-hoc rescaling by the fitted efficiency is commented out further down —
%   so the curve plotted as the model is the unattenuated ideal observer.
%   B1.9: the variable named mean_subj_acc is built from dprimes(:, 2), which is
%   the model column, not the subject column, so the headline var_exp is a
%   within-model dispersion ratio and not a goodness of fit; the numel(~isnan(x))
%   on the line below it is a no-op that was meant to be nnz. Both are left
%   exactly as found. **mean_subj_acc and model_acc deliberately keep their
%   original names**: renaming mean_subj_acc to what it actually holds would
%   quietly erase the only evidence for B1.9 in the source. B2.8 affects cell 3,
%   whose exp_files/all/ data no longer matches the struct the code expects.
%
%   The local x is reused as the argument of an anonymous function in cell 3,
%   so it cannot be renamed separately from its plotting role in cell 1; y and
%   dy are kept with it so the plotting triple stays a triple. The local f is
%   assigned live but read only by the commented-out legend below it, so it
%   keeps its name too.
%
%   See also general.COMPUTE_EDGE_PROPS_EXP_PCA, lib.EDGE_FIT_COST,
%   general.COMPUTE_NAT_IMG_EFF_CODING_BINS.

%% Plot subject d's, and model d', scaled to avg. subject d'
% exp_paths={'natural/moth','natural/rock','natural/camo_large','natural/spots','natural/leaf','natural/leather','natural/camo','pink_noise',...
%     'natural/foliage','natural/soil','natural/grass','natural/paper','natural/bark_recast','texture_exponent/ecc_0'}; %
exp_paths = {'pink_noise'};
% exp_paths={'natural/moth','natural/rock','natural/camo_large','natural/spots','natural/leaf','natural/leather','natural/camo','pink_noise',...
%     'natural/foliage','natural/soil','natural/grass','natural/paper','texture_exponent/ecc_0'}; %

nLevels = 10;
% edge_feature_names={'grad_m_comb','grad_o_comb','grad_p_comb','npix_llr','ncon_llr','pos_llr','or_llr','curv_llr',...
%     'ep_comb'};
edge_feature_names = {'grad_m_comb', 'grad_o_comb', 'grad_p_comb'};

n_features = numel(edge_feature_names);

d_primes = cell(length(exp_paths), 2);

n_figs = length(findall(0, 'Type', 'figure'));
% figure;

for i_exp = 1:length(exp_paths)

    % load experiment settings
    load(['exp_files/' exp_paths{i_exp} '/exp_settings.mat']);

    % load edge properties
    load(['exp_files/' exp_paths{i_exp} '/edge_props_pca.mat']);

    % compute model d's:
    % d' contributions from each feature (for bar graphs)
    d_prime_contributions = nan(n_features, nLevels);
    d_primes_model = nan(1, nLevels);
    feature_corrs_blank = nan(n_features, n_features, nLevels);
    feature_corrs_target = nan(n_features, n_features, nLevels);
    for i_level = 1:nLevels
        targets_this_level = ExpSettings.bTargetPresent(:, i_level, :);
        feature_vectors_target = nan(nnz(targets_this_level), numel(edge_feature_names));
        feature_vectors_blank = nan(nnz(~targets_this_level), numel(edge_feature_names));
        for i_feature = 1:numel(edge_feature_names)
            feature_array = edge_props.(edge_feature_names{i_feature});
            feature_this_level = feature_array(:, i_level, :);
            feature_vectors_target(:, i_feature) = feature_this_level(targets_this_level);
            feature_vectors_blank(:, i_feature) = feature_this_level(~targets_this_level);
        end

        % correlation coefficient between features:
        feature_corrs_blank(:, :, i_level) = corrcoef(feature_vectors_blank);
        feature_corrs_target(:, :, i_level) = corrcoef(feature_vectors_target);

        results = classify_normals(feature_vectors_target, feature_vectors_blank, ...
            'input_type', 'samp', 'samp_opt', false, 'd_con', true, 'eff', 0.34, ...
            'plotmode', 0, 'precision', 'basic');
        % d' contributions
        d_prime_contributions(:, i_level) = results.d_con;
        d_primes_model(i_level) = results.norm_d_b;
    end
    d_primes{i_exp, 2} = d_primes_model;

    subj_list = dir(['exp_files/' exp_paths{i_exp} '/subject_out/*.mat']);
    d_primes_subj = nan(length(subj_list), 10);

    figure(n_figs+1)
    subplot(4, 4, i_exp);
    hold on

    % subject data
    for i_subj = 1:length(subj_list)
        % load subject file
        load(['exp_files/' exp_paths{i_exp} '/subject_out/' subj_list(i_subj).name])

        % compute subject d's across blocks
        % by inverting the overall accuracy
        p_correct = mean(SubjectExpFile.correct, [1 3]);
        d_prime_correct = 2*norminv(p_correct);

        % by using hits & false alarms (to correct bias):
        hit_rate = sum(SubjectExpFile.hit, [1 3])./sum(SubjectExpFile.bTargetPresent, [1 3]);
        false_alarm_rate = ...
            sum(SubjectExpFile.falseAlarm, [1 3])./sum(~SubjectExpFile.bTargetPresent, [1 3]);
        d_prime_hit_false_alarm = norminv(hit_rate) - norminv(false_alarm_rate);

        % now combine both
        d_prime_subj = d_prime_hit_false_alarm;
        d_prime_subj(isinf(d_prime_subj)) = d_prime_correct(isinf(d_prime_subj));

        d_primes_subj(i_subj, :) = d_prime_subj;

        % plot subject accuracy:
        x = (1:nLevels)';
        y = normcdf(d_prime_subj/2)';
        % plot subject accuracy errorband:
        dy = std(squeeze(mean(SubjectExpFile.correct)), 0, 2);
        fill([x; flipud(x)], [y-dy; flipud(y+dy)], 'k', 'linestyle', 'none', 'facealpha', .1);
        plot(x, y, '-ok', 'markersize', 4, 'markerfacecolor', 'k');
    end

    d_primes{i_exp, 1} = d_primes_subj;

    % average subject d' in this experiment:
    % averaging acc, then getting d' (so as not to average inf d's).
    % but for the model we are averaging d' directly, so it's not an exact
    % comparison
    avg_subj_acc = mean(normcdf(d_primes_subj/2), 'all');
    avg_subj_d_prime = 2*norminv(avg_subj_acc);
    title(sprintf('%s: %.1f%%', exp_paths{i_exp}, 100*avg_subj_acc), 'interpreter', 'none')

    % plot individual feature contributions to d':
    figure(n_figs+2)
    hold on

    % single color-bar for sum across levels
    d_prime_contributions_total = sum(d_prime_contributions, 2);
    % scale the total height of the bar to the avg. overall d' across levels:
    d_prime_contributions_total = ...
        d_prime_contributions_total/sum(d_prime_contributions_total)*mean(d_primes_model);
    bar_h = bar(i_exp, flip(d_prime_contributions_total), 0.2, 'stacked', 'facecolor', 'flat');

    % bar colours

    % edge power, blue gradient
    % bar_h(1).CData=[0 0 0.44];
    % bar_h(2).CData=[0 0.24 0.54];
    % bar_h(3).CData=[0 0.54 0.84];
    % bar_h(1).CData=[0 0.74 1];
    % bar_h(5).CData=[0 0.9 1];
    %
    % % edge power sums, purple gradient
    % %     b(6).CData=[0 0 0.44];
    % %     b(7).CData=[0 0.24 0.54];
    % %     b(8).CData=[0 0.54 0.84];
    % %     b(9).CData=[0 0.74 1];
    % %     b(10).CData=[0 0.9 1];
    %
    % % curvature, red
    % bar_h(2).CData=[1 0 0];
    %
    % % orientation alignment, yellow
    % bar_h(3).CData=[1 1 0];
    %
    % % position alignment, orange
    % bar_h(4).CData=[1 0.4588 0.0941];
    %
    % % len llr, light green
    % % bar_h(9).CData=[0.66 0.87 0.38];
    %
    % % len sum, green
    % % bar_h(10).CData=[0.4660 0.6740 0.1880];
    %
    % % ncon llr, light green
    % bar_h(5).CData=[0.66 0.87 0.38];
    %
    % % npix llr, green
    % bar_h(6).CData=[0.4660 0.6740 0.1880];
    %
    % % grad prod histogram, dark grey
    bar_h(1).CData = .5*[1 1 1];
    %
    % % grad or histogram, light grey
    bar_h(2).CData = .7*[1 1 1];
    %
    % % grad mag histogram, white
    bar_h(3).CData = [1 1 1];

    % bar_h(1).CData=[1 .5 .5];
    % bar_h(2).CData=.8*bar_h(1).CData;
    % bar_h(3).CData=.6*bar_h(1).CData;
    % bar_h(4).CData=.4*bar_h(1).CData;

    % bar_h(2).CData=[0 1 0];
    % bar_h(6).CData=.8*bar_h(5).CData;
    % bar_h(7).CData=.6*bar_h(5).CData;
    % bar_h(8).CData=.4*bar_h(5).CData;

    % bar_h(3).CData=[.4 .7 1];
    % bar_h(10).CData=.8*bar_h(9).CData;
    % bar_h(11).CData=.6*bar_h(9).CData;
    % bar_h(12).CData=.4*bar_h(9).CData;

    % plot feature correlations
    % blank
%     figure(3); subplot(4,4,i_exp);
%     imagesc(mean(feature_corrs_blank,3)); axis square
%     vislab.lib.colorbarpzn(-1,1,'rev'); colorbar off
%     set(gca,'xtick',[],'ytick',[])
%
%     % target
%     figure(4); subplot(4,4,i_exp);
%     imagesc(mean(feature_corrs_target,3)); axis square
%     vislab.lib.colorbarpzn(-1,1,'rev'); colorbar off
%     set(gca,'xtick',[],'ytick',[])
end

% set bar labels and edge feature legends
figure(n_figs+2)
xticks(1:numel(exp_paths))
xticklabels(exp_paths);
set(gca, 'TickLabelInterpreter', 'none');

f = get(gca, 'Children');
% legend([f(1),f(2),f(3),f(4),f(5),f(6),f(7),f(8),f(9),f(10),f(11),f(12),f(13)],edge_feature_names,'interpreter','none')
legend boxoff

% find efficiency scalar to match model d's to subject d's:
[efficiency_scalar, squared_error] = fmincon(@(s) lib.edge_fit_cost(s, d_primes), 1, -1, 0);

for i_exp = 1:length(exp_paths)
    % scale model d'
    % dprimes{i_exp,2}=dprimes{i_exp,2}*s;

    % plot model d's:
    figure(n_figs+1)
    subplot(4, 4, i_exp);
    plot(normcdf(d_primes{i_exp, 2}/2), '-or', 'markersize', 4, ...
        'markerfacecolor', 'r', 'linewidth', 1)
    set(gca, 'xtick', [], 'ytick', [.5 1], 'tickdir', 'out', 'yticklabels', {'', ''});
    axis([1 10 .4 1])
end

% percent variance of mean subject accuracies explained
mean_subj_acc = cell2mat(cellfun(@(x) mean(normcdf(x/2)), d_primes(:, 2), 'un', 0));
model_acc = normcdf(vertcat(d_primes{:, 2})/2);
var_exp = 1 - rms(mean_subj_acc - model_acc, 'all')^2/var(mean_subj_acc(:))
% var_exp=1-sqerr/numel(vertcat(dprimes{:,2}))

% percent variance of dprimes explained across all subjects
% (this is what the efficiency scalar was optimizing for)
d_primes_subj = vertcat(d_primes{:, 1});
d_primes_subj(isinf(d_primes_subj)) = nan;
var_exp = 1 - squared_error/(var(d_primes_subj, 0, 'all', 'omitnan')*numel(~isnan(d_primes_subj)))

%% scatter plot of model vs subject d' (to see how proportional they are)
figure
for i_exp = 1:length(exp_paths)
    d_primes_subj_this_exp = d_primes{i_exp, 1};
    subplot(4, 4, i_exp); hold on
    for i_subj = 1:size(d_primes_subj_this_exp, 1)
        plot(d_primes{i_exp, 2}, d_primes_subj_this_exp(i_subj, :), '-ok')
    end
    title(sprintf('%s', exp_paths{i_exp}), 'interpreter', 'none')
end

%% fit edge model for all-textures experiment
% load data
load('exp_files/all/exp_settings.mat');
load('exp_files/all/edge_props.mat');
load('exp_files/all/texture_list.mat');
load('exp_files/all/subject_out/neel.mat');

edge_feature_names = {'dens', 'len_llr', 'al_sum', 'curv_sum', ...
    'ep1_sum', 'ep2_sum', 'ep4_sum', 'ep8_sum', 'ep16_sum'};
n_textures = length(texture_list);
n_trials = 40;
n_features = numel(edge_feature_names);
error_rates_model = nan(n_textures, 1);
d_primes_model = nan(n_textures, 1);

error_rates_subj = nan(n_textures, 1);

% first classify target vs blank images for the whole experiment
feature_vectors_target = nan(nnz(ExpSettings.bTargetPresent), n_features);
feature_vectors_blank = nan(nnz(~ExpSettings.bTargetPresent), n_features);

for i_feature = 1:n_features
    feature_array = edge_props.(edge_feature_names{i_feature});
    feature_vectors_target(:, i_feature) = feature_array(ExpSettings.bTargetPresent);
    feature_vectors_blank(:, i_feature) = feature_array(~ExpSettings.bTargetPresent);
end

results = classify_normals(feature_vectors_target, feature_vectors_blank, ...
    'input_type', 'samp', 'd_con', true);

% get the overall sample-optimized boundary
overall_boundary = results.samp_opt_bd;

% now use this overall boundary to classify target vs blank for each texture

for i_texture = 1:n_textures
    this_texture = texture_list(i_texture)
    texture_select = arrayfun(@(x) isequal(x, this_texture), ExpSettings.textures);
    error_rates_subj(i_texture) = mean(~SubjectExpFile.correct(texture_select));

    feature_vectors_target = ...
        nan(nnz(texture_select&ExpSettings.bTargetPresent), n_features);
    feature_vectors_blank = ...
        nan(nnz(texture_select&~ExpSettings.bTargetPresent), n_features);

    for i_feature = 1:n_features
        feature_array = edge_props.(edge_feature_names{i_feature});
        feature_vectors_target(:, i_feature) = ...
            feature_array(texture_select&ExpSettings.bTargetPresent);
        feature_vectors_blank(:, i_feature) = ...
            feature_array(texture_select&~ExpSettings.bTargetPresent);
    end
    results = classify_normals(feature_vectors_target, feature_vectors_blank, ...
        'input_type', 'samp', 'dom', overall_boundary, 'plotmode', 0);
    error_rates_model(i_texture) = results.samp_err;
%     dprimes_model(iTex)=results.samp_d_b;
end

% sd of subj error rate assuming binomial
error_rate_sd_subj = sqrt(error_rates_subj.*(1 - error_rates_subj)/n_trials);

figure
errorbar(error_rates_model, error_rates_subj, error_rate_sd_subj, 'ok')
xlabel 'model error rates'
ylabel 'subject error rates'
set(gca, 'fontsize', 13)

%% show all textures with subject and model accuracy

bg_size = 256;
luminance = 0.5;
contrast = 0.15;
target_radius = 64;

for i_texture_display = 1:length(texture_list)
    i_texture_display
    texture = texture_list(i_texture_display);
    stim = lib.stimulus('texture', texture, 'ml_b', 0.5, 'cont_b', 0.15, ...
        'ml_t', 0.5, 'cont_t', 0.15, 'target_radius', target_radius);
    figure;
    imshow(stim, []);
    title(sprintf('%s %.2f, %.2f', texture.img, ...
        1 - error_rates_subj(i_texture_display), 1 - error_rates_model(i_texture_display)), ...
        'Interpreter', 'none')
end
