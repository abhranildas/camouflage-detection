function pink_noise_signal = pink_noise_line(n_samples, k_list)
% pink_noise_line  Synthesize a 1-D pink-noise (1/f) sample.
%
%     pink_noise_signal = pink_noise_line(n_samples, k_list)
%
% Sums sinusoids at each frequency in k_list, with amplitude 1/sqrt(k)
% and an independent uniform random phase, to build a signal with a 1/f
% amplitude spectrum. A frequency of 0 in k_list contributes zero
% amplitude.
%
% Inputs
%     n_samples - number of samples in the output signal.
%     k_list (cycles per signal) - frequencies to sum over.
% Output
%     pink_noise_signal - the synthesized 1-D pink-noise signal, 1 x
%         n_samples.
%
% See also tinker.pink_noise_dist, tinker.pink_noise_line_dist,
% lib.create_pink_noise_line.

sample_index = 0:n_samples-1;
pink_noise_signal = zeros(1, n_samples);
for k = k_list
    phase = unifrnd(-pi, pi);
    if ~k
        amplitude = 0;
    else
        amplitude = 1/sqrt(k);
    end
    component = amplitude * sin(k*sample_index+phase);
    pink_noise_signal = pink_noise_signal+component;
end
