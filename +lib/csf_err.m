function log_sq_error = csf_err(params, spatial_freq, pupil_diameter, wavelength, ...
    surround_shape_exponent, human_atf)
% CSF_ERR  Sum of squared log errors between the fitted and human ATF.
%   log_sq_error = lib.csf_err(params, spatial_freq, pupil_diameter, wavelength, ...
%       surround_shape_exponent, human_atf)
%
%   ATF based on Watson's descriptive OTF.
%
%   Inputs
%     params                  - 3-element [surround_strength, surround_size,
%                                center_size] fit parameters.
%     spatial_freq            - vector of frequencies, in cycles/deg.
%     pupil_diameter          - pupil diameter, in mm.
%     wavelength              - wavelength, in nm.
%     surround_shape_exponent - surround shape exponent.
%     human_atf               - human ATF values to fit against.
%
%   Output
%     log_sq_error - sum of squared log(model) - log(human_atf) residuals.
%
%   See also lib.CSF_FLOATING, lib.CSF_FITTED.

    atf = lib.csf_floating(params, spatial_freq, pupil_diameter, wavelength, ...
        surround_shape_exponent);
    atf = atf/max(atf);
    %   sz = size(z);
    %   for i = 1:sz(2)
    %     if z(i) <= 0
    %       z(i) = 10^-20;
    %     end
    %   end
    log_sq_error = sum((log(atf)-log(human_atf)).^2);
end
