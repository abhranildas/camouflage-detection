function gabor_similarity(test_type_str, value_range)
% GABOR_SIMILARITY  Test script that plots the change in similarity over a
%     change in a property of the gabor.
%   tests.gabor_similarity(test_type_str, value_range)
%
%   Test types:
%     phase, orientation, frequency, amplitude
%   Example:
%     tests.gabor_similarity('orientation', -90:90)
%
%   Output:
%     none; plots similarity vs. the tested property.
%
%   v1.0, 4/21/2016, Steve Sebastian <sebastian@utexas.edu>

% Generate gabor

gabor_params.std = .14;
gabor_params.sf = 4;
gabor_params.ori = 90;
gabor_params.phase = 0;
gabor_params.pixperdeg = 120;
gabor_params.odd_even = 'odd';
gabor_params.envelope = 'coswin';

[gabor, envelope] = lib.gabor_2d(gabor_params, 0);

% Iterate over values and compute similarity
sim_array = zeros(size(value_range));
amp_scale = 1;
for i_val = 1:length(value_range)
    if(strcmp(test_type_str, 'orientation'))
        gabor_params.ori = value_range(i_val);
    elseif(strcmp(test_type_str, 'phase'))
        gabor_params.phase = value_range(i_val);
    elseif(strcmp(test_type_str, 'frequency'))
        gabor_params.sf = value_range(i_val);
    else
        amp_scale = value_range(i_val);
    end

    this_gabor = amp_scale.*lib.gabor_2d(gabor_params, 0);
    % BUG (new, B2-level): stats.computeSceneSimilarityAmplitude does not
    % exist — the file backing it, +stats/_computeSceneSimilarityAmplitude.m,
    % is `_`-prefixed and therefore not reachable under this name. Errors
    % immediately if this script is run with any test_type_str. Left as found.
    similarity_out = stats.computeSceneSimilarityAmplitude(gabor, this_gabor, envelope, [51 51]);

    sim_array(i_val) = similarity_out.Smag;
end

plot(value_range, sim_array, '-', 'LineWidth', 2);
axis square;
box off;
set(gca, 'TickDir', 'out');
set(gcf, 'color', 'w');
set(gca, 'fontsize', 24);
ylim([0 1]);
xlabel(test_type_str, 'fontsize', 28);
ylabel('Similarity', 'fontsize', 28);
