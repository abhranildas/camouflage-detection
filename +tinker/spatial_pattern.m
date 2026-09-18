function pattern = spatial_pattern(dim, beta)
% spatial_pattern  Generate 1/f^beta spatial noise via a random-phase spectrum.
%
%     pattern = spatial_pattern(dim, beta)
%
% Builds a power spectrum |freq|^beta over the requested grid, assigns
% each frequency component an independent uniform random phase, and
% inverse Fourier transforms. By the central limit theorem, the value at
% each pixel is approximately normally distributed once the grid is at
% least 10x10 (1/f noise is scale-invariant: there is no spatial scale at
% which the variance plateaus, so the process is non-stationary). The
% output is periodic; double the grid and use only the first quadrant if
% that is not wanted. Setting one component of dim to 1 gives a 1-D time
% series instead of a 2-D pattern.
%
% Inputs
%     dim - 2-element vector, [rows, cols] size of the output grid.
%     beta - spectral exponent: spectral density S(freq) = N*freq^beta (N
%         a normalizing constant). beta = 0 is white noise, beta = -1 is
%         pink noise, beta = -2 is Brownian noise. Fractal dimension D =
%         (6+beta)/2.
% Output
%     pattern - dim(1) x dim(2) array, the synthesized 1/f^beta pattern
%         (complex-valued; the caller decides whether to take
%         real(pattern), as the commented-out line at the end of this
%         function once did).
%
% Method briefly described in Lennon, J.L. "Red-shifts and red herrings
% in geographical ecology", Ecography, Vol. 23, p101-113 (2000).
%
% Written by Jon Yearsley, 1 May 2004 (j.yearsley@macaulay.ac.uk).
% power_spectrum corrected to be (freq_u.^2 + freq_v.^2).^(beta/2), 2/10/05.
%
% See also lib.create_pink_noise_square, tinker.pink_noise.

% Generate the grid of frequencies. freq_u is the set of frequencies along the
% first dimension
% First quadrant are positive frequencies.  Zero frequency is at freq_u(1,1).
freq_u = [(0:floor(dim(1)/2)) -(ceil(dim(1)/2)-1:-1:1)]'/dim(1);
% Reproduce these frequencies along ever row
freq_u = repmat(freq_u, 1, dim(2));
% freq_v is the set of frequencies along the second dimension.  For a square
% region it will be the transpose of freq_u
freq_v = [(0:floor(dim(2)/2)) -(ceil(dim(2)/2)-1:-1:1)]/dim(2);
% Reproduce these frequencies along ever column
freq_v = repmat(freq_v, dim(1), 1);

% Generate the power spectrum
power_spectrum = (freq_u.^2 + freq_v.^2).^(beta/2);

% Set any infinities to zero
power_spectrum(power_spectrum == inf) = 0;

% Generate a grid of random phase shifts
phase = rand(dim);

% Inverse Fourier transform to obtain the the spatial pattern
pattern = ifft2(power_spectrum.^0.5 .* exp(2i*pi*phase));

% Pick just the real component
% pattern = real(pattern);
