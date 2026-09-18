function imageOut = gamma_correct(imageIn, gammaValue, bitDepthOut)
% GAMMA_CORRECT  Gamma-compress a normalised image and quantise it to pixel values.
%   imageOut = experiment.gamma_correct(imageIn, gammaValue, bitDepthOut)
%
%   Applies the inverse of the display gamma, so that a monitor with that
%   gamma renders the image's normalised luminances linearly, then scales to
%   the full integer range of the output bit depth and rounds.
%
%   Inputs
%     imageIn     - image in normalised luminance units, in [0, 1].
%     gammaValue  - display gamma exponent, dimensionless (2.089 for the
%                   monitor this experiment was run on).
%     bitDepthOut - output bit depth, in bits (8 for that monitor).
%
%   Output
%     imageOut - image in integer pixel values, in [0, 2^bitDepthOut - 1].
%                Rounded, but left as a double rather than cast to an
%                integer type; callers that need uint8 cast it themselves.
%
%   The operation is gamma *compression*, despite the name. The repo holds
%   three separate implementations of it — this one, lib.gammaCorrect, and
%   the shared vislab.lib.gamma_compress — which S3.14 consolidates.
%
%   See also experiment.LOAD_STIMULI_CAMOUFLAGE, experiment.LOAD_CURRENT_SESSION.

    maxPixelValOut = 2^bitDepthOut - 1;

    %% Gamma correct
    imageOut = imageIn.^(1/gammaValue);
    imageOut = maxPixelValOut*imageOut;
    imageOut = round(imageOut);
end
