% fit_csf  Fit Watson's descriptive ATF to measured human contrast
%     sensitivity data, then plot the resulting spatial CSF filter.
%
%     fit_csf
%
% Script, no arguments. Fits the 3-parameter ATF (surround strength,
% surround size, center size; surround shape exponent fixed at 2, pupil
% diameter 4 mm, wavelength 555 nm) to eleven measured human CSF points
% via `lib.csf_err`/`lib.csf_floating`, by minimising the summed squared
% log error with `fmincon`. Note `lib.csf_fitted` hardcodes its own
% already-fitted parameter values rather than reading this script's
% `fitted_params` — this script's own fit is for the log-log overlay plot
% only.
%
% Inputs: none from disk; `spatial_freq_data`/`human_atf_data` below are
%     literal.
% Output: two figures — the log-log CSF fit overlay, and a 1-D slice of
%     `lib.csf_spatial_filter`'s 256x256 spatial-domain filter at row 128.
%     Nothing is saved to disk.
%
% See also lib.csf_err, lib.csf_fitted, lib.csf_spatial_filter.

%
% ATF includes Watson OTF, aperture, generalized-Gaussian surround and
% center
% p(1) = a   surround strength
% p(2) = b   surround size
% p(3) = c   center size
% p(4) = s   scalar
% u = vector of frequencies c/deg
% d = pupil diameter mm
% w = wavelength nm
% n = surround shape exponent
% z0 = human atf values
%
spatial_freq_data = [0.1, 1.12, 2, 2.83, 4, 5.66, 8, 11.3, 16, 22.6, 30];
human_atf_data = [0.25, 0.518, 0.714, 0.905, 1.0, 0.768, 0.546, 0.327, 0.155, 0.0713, 0.0289];
loglog(spatial_freq_data, human_atf_data, 'o'); hold on;
%
initial_params = [0.85; 0.1; 0.065];
surround_shape_exponent = 2;
pupil_diameter = 4;
wavelength = 555;
objective = @(params) lib.csf_err(params, spatial_freq_data, pupil_diameter, wavelength, ...
    surround_shape_exponent, human_atf_data);
fitted_params = fmincon(objective, initial_params, [], [], [], [], [0; 0; 0], [1; 1; 1]);
spatial_freq = linspace(min(spatial_freq_data), max(spatial_freq_data), 1e3);
atf = lib.csf_fitted(spatial_freq);
atf = atf/max(atf);
% err = 20*sqrt(atf_err(p_fit,u0,d,w,n,z0)/11);
% err0 = 20*sqrt(atf_err(p0,u0,d,w,n,z0)/11);
loglog(spatial_freq, atf, '-');

%% plot CSF spatial filter
ppd = 60;
csf_kernel = lib.csf_spatial_filter(ppd);
plot(csf_kernel(128, :))
xlim(128+50*[-1 1]); ylim([-.01 .08])
set(gca, 'xtick', [], 'ytick', [])
