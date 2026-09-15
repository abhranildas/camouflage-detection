function atf = csf_fitted(spatial_freq)
% CSF_FITTED  Amplitude transfer function at the fitted CSF parameters.
%   atf = lib.csf_fitted(spatial_freq)
%
%   Inputs
%     spatial_freq - vector of frequencies, in cycles/deg.
%
%   Output
%     atf - amplitude transfer function at each spatial_freq, at a fixed set
%           of previously-fitted parameters (pupil_diameter = 4 mm,
%           wavelength = 555 nm, surround_shape_exponent = 2).
%
%   See also lib.CSF_FLOATING, lib.CSF_ERR.

    surround_shape_exponent = 2;
    pupil_diameter = 4;
    wavelength = 555;
    surround_strength = 0.8563;
    surround_size = 0.1516;
    center_size = 0.0651;
    params = [surround_strength surround_size center_size];

    atf = lib.csf_floating(params, spatial_freq, pupil_diameter, wavelength, ...
        surround_shape_exponent);
end
