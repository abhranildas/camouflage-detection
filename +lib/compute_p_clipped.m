function pClipped = compute_p_clipped(stim)
% COMPUTE_P_CLIPPED  Fraction of an image's pixels that fall outside [0, 1].
%   pClipped = lib.compute_p_clipped(stim)
%
%   Counts elements that a display would clip, i.e. that lie below 0 or above
%   1 once luminance is expressed as a fraction of the monitor maximum.
%
%   Inputs
%     stim - numeric array (typically a stimulus image) in normalised
%            luminance units, where the displayable range is [0, 1].
%
%   Output
%     pClipped - fraction, in [0, 1], of elements outside the displayable
%                range. A fraction, not a percentage, despite the warning
%                text printing 100*pClipped.
%
%   The warning text says "boundary ribbon" whatever it is handed, but the
%   function is a general-purpose clipping fraction and is called on whole
%   stimuli too. The wording sits in a string literal, so correcting it is a
%   change to the syntax tree and is deferred (see B2.14 in the plan).
%
%   The name stays camelCase, unlike the rest of snake_case +lib/, because it
%   is the filename; renaming the file is a cross-file change, not Stage 1.
%
%   See also lib.STIMULUS.

    pClipped = (sum(stim(:) < 0) + sum(stim(:) > 1)) / numel(stim);
    if pClipped > 0
        if pClipped > 0.01
            warning('%.2f%% of boundary ribbon clipped\n', 100*pClipped);
        else
            %fprintf('%f of boundary ribbon clipped\n', pClipped);
        end
    end
end
