% new_psychometric  Explore psychometric-function shape vs. noise SD and bias.
%
%     new_psychometric
%
% Script, no arguments. Plots p_correct = f(stimulus_intensity) for
% several noise SDs (unbiased 2AFC), then for several bias fractions at
% a fixed noise SD (biased 2AFC, decision criterion split
% bias/(1-bias) between the two intervals). The name is a pre-existing,
% not-very-descriptive one -- see 3.1.1's deliberately-not-renamed list.
%
% Inputs: none (all parameters are literals per cell).
% Output: two figures, no files saved.
%
% See also tinker.pink_noise_dist.

%% vary sd
stimulus_intensity = 0:.01:100;

figure; hold on

for noise_sd = [1 2 3]
    p_correct = normcdf(stimulus_intensity/noise_sd);
    plot(stimulus_intensity, p_correct);
end

set(gca, 'xscale', 'log')

%% vary bias

noise_sd = 1;
figure; hold on;
for bias = 0:.05:.5
    p_correct = (normcdf(bias*stimulus_intensity/noise_sd) + ...
        normcdf((1-bias)*stimulus_intensity/noise_sd))/2;
    plot(stimulus_intensity, p_correct, '-k');
end

set(gca, 'xscale', 'log')
