function image_out = gamma_correct(image_in, gamma_value, bit_depth_out)
% GAMMA_CORRECT  Gamma-compress a normalised image and quantise it to pixel values.
%   image_out = experiment.gamma_correct(image_in, gamma_value, bit_depth_out)
%
%   Applies the inverse of the display gamma, so that a monitor with that
%   gamma renders the image's normalised luminances linearly, then scales to
%   the full integer range of the output bit depth and rounds.
%
%   Inputs
%     image_in      - image in normalised luminance units, in [0, 1].
%     gamma_value   - display gamma exponent, dimensionless (2.089 for the
%                     monitor this experiment was run on).
%     bit_depth_out - output bit depth, in bits (8 for that monitor).
%
%   Output
%     image_out - image in integer pixel values, in [0, 2^bit_depth_out - 1].
%                 Rounded, but left as a double rather than cast to an
%                 integer type; callers that need uint8 cast it themselves.
%
%   The operation is gamma *compression*, despite the name. The repo holds
%   three separate implementations of it — this one, lib.gammaCorrect, and
%   the shared vislab.lib.gamma_compress — which S3.14 consolidates.
%
%   See also experiment.LOAD_STIMULI_CAMOUFLAGE, experiment.LOAD_CURRENT_SESSION.

    max_pixel_val_out = 2^bit_depth_out - 1;

    %% Gamma correct
    image_out = image_in.^(1/gamma_value);
    image_out = max_pixel_val_out*image_out;
    image_out = round(image_out);
end
