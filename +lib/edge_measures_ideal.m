function [edge_power, edge_amplitude_spectrum, edge_power_spectrum, edge_phase_spectrum] = ...
    edge_measures_ideal(edge_vector)
% EDGE_MEASURES_IDEAL  Power and spectrum of a dimensionless edge vector.
%   edge_power = lib.edge_measures_ideal(edge_vector)
%   [edge_power, edge_as, edge_ps, edge_phase] = lib.edge_measures_ideal(edge_vector)
%
%   Summarises the edge vector returned by lib.edge_vector_ideal: its mean
%   square (the edge power the paper reports), and its one-sided discrete
%   Fourier spectrum around the boundary.
%
%   Inputs
%     edge_vector - 1 x n_edge dimensionless edge, uniformly sampled in the
%                   boundary parameter theta over (-pi, pi], as returned by
%                   lib.edge_vector_ideal.
%
%   Outputs
%     edge_power              - mean(edge_vector.^2), dimensionless.
%     edge_amplitude_spectrum - one-sided DFT magnitude, length
%                               ceil((n_edge+1)/2). Index 1 is DC; the unit of
%                               the frequency axis is cycles around the
%                               boundary.
%     edge_power_spectrum     - one-sided power spectrum, scaled so that the
%                               non-DC, non-Nyquist bins are doubled.
%     edge_phase_spectrum     - phase of the same one-sided DFT, in radians.
%
%   The input was called "edge" before this pass, shadowing the Image
%   Processing Toolbox EDGE; the new name is local only.
%
%   See also lib.EDGE_VECTOR_IDEAL, lib.EDGE, FFT.

    n_edge = length(edge_vector);

    edge_power = mean(edge_vector.^2);

    % edge amplitude and phase spectra:
    edge_dft = fft(edge_vector);
    edge_dft = edge_dft(1:ceil((n_edge + 1)/2));  % remove repeated part
    edge_amplitude_spectrum = abs(edge_dft);
    edge_power_spectrum = edge_amplitude_spectrum.^2/n_edge;
    edge_power_spectrum(2:end-1) = 2*edge_power_spectrum(2:end-1);
    edge_phase_spectrum = angle(edge_dft);
end
