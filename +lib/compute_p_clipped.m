function p_clipped = compute_p_clipped(stim)
% COMPUTE_P_CLIPPED  Fraction of an image's pixels that fall outside [0, 1].
%   p_clipped = lib.compute_p_clipped(stim)
%
%   Counts elements that a display would clip, i.e. that lie below 0 or above
%   1 once luminance is expressed as a fraction of the monitor maximum.
%
%   Inputs
%     stim - numeric array (typically a stimulus image) in normalised
%            luminance units, where the displayable range is [0, 1].
%
%   Output
%     p_clipped - fraction, in [0, 1], of elements outside the displayable
%                 range. A fraction, not a percentage, despite the warning
%                 text printing 100*p_clipped.
%
%   The warning text says "boundary ribbon" whatever it is handed, but the
%   function is a general-purpose clipping fraction and is called on whole
%   stimuli too. The wording sits in a string literal, so correcting it is a
%   change to the syntax tree and is deferred (see B2.14 in the plan).
%
%   The golden-reference field `golden.compute_pClipped` in
%   tools/golden_harness.m keeps its camelCase spelling regardless of this
%   function's own naming — it is a separate, zone-3 frozen struct field
%   serialised into tools/golden_ref.mat, not tied to this file's local
%   variable name.
%
%   See also lib.STIMULUS.

    p_clipped = (sum(stim(:) < 0) + sum(stim(:) > 1)) / numel(stim);
    if p_clipped > 0
        if p_clipped > 0.01
            warning('%.2f%% of boundary ribbon clipped\n', 100*p_clipped);
        else
            %fprintf('%f of boundary ribbon clipped\n', p_clipped);
        end
    end
end
