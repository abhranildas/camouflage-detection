function [threshold, threshold_sd, threshold_dist] = compute_bootstrapped_threshold(subject_str, ...
    bin_index, blocks, n_boot_iter, b_plot)
%COMPUTE_BOOTSTRAPPED_THRESHOLD  Computes experimental threshold with bootstrapped distribution.
%
%   [threshold, threshold_sd, threshold_dist] = ...
%       experiment.analysis.COMPUTE_BOOTSTRAPPED_THRESHOLD(subject_str, ...
%       bin_index, blocks, n_boot_iter, b_plot)
%
% Loads one or more of a subject's saved block files (from a hardcoded,
% machine-specific path — B2.11, pre-existing, not fixed here) and
% bootstraps a contrast threshold by resampling trials within each column
% of the pooled correct-response matrix. The fit itself is delegated to
% nm.analysis.fitPsychometric, which does not resolve to anything in this
% repo or a sibling one (B2.9, pre-existing, not fixed here).
%
% Inputs
%   subject_str   subject identifier, names the loaded block file's folder
%   bin_index     [luminance, contrast, similarity] bin index, 1x3
%   blocks       block numbers to pool, e.g. 1:2
%   n_boot_iter    number of bootstrap iterations (default 500)
%   b_plot        true to plot the bootstrapped threshold distribution
%                (default false)
%
% Output
%   threshold        mean bootstrapped contrast threshold
%   threshold_sd     standard deviation of bootstrapped thresholds
%   threshold_dist    1 x n_boot_iter distribution of bootstrapped thresholds
%
% Example:
%   [threshold, threshold_sd, threshold_dist] = ...
%       COMPUTE_BOOTSTRAPPED_THRESHOLD('SUB', [5 5 5], 1:2, 100, 1);
%
%   See also NM.ANALYSIS.FITPSYCHOMETRIC.

% v0.1, 1/12/2016, Steve Sebastian <sebastian@utexas.edu>

%% Input handling

if(~exist('b_plot', 'var') || isempty(b_plot))
    b_plot = 0;
end;

if(~exist('n_boot_iter', 'var') || isempty(n_boot_iter))
    n_boot_iter = 500;
end;

%% Variable setup

contrast = [];
correct_mat = [];
threshold_dist = zeros(1, n_boot_iter);

%% Load data from specified blocks
for i_block = 1:length(blocks)

    % load in the subject's data
    if(ismac())
        file_path = ['/Users/steve/Dropbox/Research/Jared_Project/exp_out/' subject_str ...
            '/' num2str(bin_index(1)) num2str(bin_index(2)) num2str(bin_index(3)) ...
            '_' num2str(blocks(i_block)) '.mat'];
    else
        file_path = ['C:\Users\sebastian\Dropbox\Research\Jared_Project\exp_out\' subject_str ...
            '\' num2str(bin_index(1)) num2str(bin_index(2)) num2str(bin_index(3)) ...
            '_' num2str(blocks(i_block)) '.mat'];
    end;
    load(file_path);

    % get the contrast levels
    contrast_block = repmat(trial_info.targetContrast', [1 size(trial_info.correct, 2)]);
    contrast = [contrast contrast_block(:)];

    correct_mat = [correct_mat trial_info.correct];
end;

% build a row subscript index for indexing into the correct response matrix
row_sub = repmat((1:size(correct_mat, 1))', [1 size(correct_mat, 2)]);

%% Bootstrap the threshold data
for i_boot = 1:n_boot_iter

    % get the random subscript
    rand_sub = randi(size(correct_mat, 2), size(correct_mat));

    % convert to index
    rand_index = sub2ind(size(correct_mat), row_sub, rand_sub);

    % sample
    correct = correct_mat(rand_index);

    % fit the data with a psychometric function
    [threshold_dist(i_boot), ~] = nm.analysis.fitPsychometric(0.1, 2, contrast, correct(:));

end;

threshold_sd = std(threshold_dist);
threshold = mean(threshold_dist);

%% plot the distribution of thresholds
if(b_plot)
    figure; hold on;

    hist(threshold_dist, 20);
    formatFigure('Contrast Threshold', 'Count', ...
        ['L: ' num2str(bin_index(1)) ' C: ' num2str(bin_index(2)) ' S: ' num2str(bin_index(3))], ...
        0, 0, 28, 24);
    axis square;

end;
end
