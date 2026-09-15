function atf = csf_floating(params, spatial_freq, pupil_diameter, wavelength, ...
    surround_shape_exponent)
% CSF_FLOATING  Amplitude transfer function based on Watson's descriptive OTF.
%   atf = lib.csf_floating(params, spatial_freq, pupil_diameter, wavelength, ...
%       surround_shape_exponent)
%
%   Inputs
%     params                  - 3-element [surround_strength, surround_size,
%                                center_size] fit parameters.
%     spatial_freq            - vector of frequencies, in cycles/deg.
%     pupil_diameter          - pupil diameter, in mm.
%     wavelength              - wavelength, in nm.
%     surround_shape_exponent - surround shape exponent.
%
%   Output
%     atf - amplitude transfer function at each spatial_freq.
%
%   See also lib.WATSON_OTF, lib.CSF_FITTED, lib.CSF_ERR.

    surround_strength = params(1);
    surround_size = params(2);
    center_size = params(3);
    otf = lib.watson_otf(spatial_freq, pupil_diameter, wavelength);   % Watson's OTF
    % ATF
    atf = otf.*(1-surround_strength*exp(-surround_size*spatial_freq.^surround_shape_exponent))...
        .*exp(-center_size*spatial_freq);
end
