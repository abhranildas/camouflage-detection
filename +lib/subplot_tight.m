function h = subplot_tight(m, n, p, margins, varargin)
% SUBPLOT_TIGHT  A wrapper for MATLAB's SUBPLOT that lets you set the margins.
%   h = lib.subplot_tight(m, n, p, margins, ...)
%
%   Adds the ability to define the margins between neighbouring subplots.
%   Unfortunately MATLAB's subplot function lacks this functionality, and
%   the margins between subplots can reach 40% of figure area, which is
%   pretty lavish.
%
%   Inputs
%     m, n, p - same as subplot(m, n, p): grid size and panel index/indices.
%     margins - (optional) two-element vector [vertical, horizontal] of
%               margins between neighbouring axes, as a fraction of figure
%               size. Default [0.01, 0.01]. Note this default causes titles,
%               legends and labels to collide with the subplots, while
%               presenting a relatively large axis. For default margins use
%               an empty element, [].
%     ...     - extra arguments, forwarded to subplot.
%
%   Output
%     h - axes handle, if requested (same as subplot).
%
%   Note: if additional elements are used in order to be passed to subplot,
%   the margins parameter must be defined.
%
%   Author and Date:  Nikolay S. 29/03/2011.
%   Last update:      Nikolay S. 21/04/2011 (according to Alan B comment).
%
%   Usage example: h = lib.subplot_tight(2, 3, 1:2, [0.5, 0.2])
%
%   See also SUBPLOT.

    if (nargin < 4) || isempty(margins)
        margins = [0.01, 0.01];   % default margins value- 1% of figure
    end

    if length(margins) == 1
        margins(2) = margins;
    end

    % note n and m are switched as Matlab indexing is column-wise, while
    % subplot indexing is row-wise :(
    [subplot_col, subplot_row] = ind2sub([n, m], p);

    height = (1-(m+1)*margins(1))/m;   % single subplot height
    width = (1-(n+1)*margins(2))/n;    % single subplot width

    % note subplot supports vector p inputs- so a merged subplot of higher
    % dimensions will be created
    % number of column elements in merged subplot
    subplot_cols = 1+max(subplot_col)-min(subplot_col);
    % number of row elements in merged subplot
    subplot_rows = 1+max(subplot_row)-min(subplot_row);

    merged_height = subplot_rows*(height+margins(1)) - margins(1);   % merged subplot height
    merged_width = subplot_cols*(width+margins(2)) - margins(2);     % merged subplot width

    % merged subplot bottom position
    merged_bottom = (m-max(subplot_row))*(height+margins(1)) + margins(1);
    % merged subplot left position
    merged_left = min(subplot_col)*(width+margins(2)) - width;
    pos_vec = [merged_left merged_bottom merged_width merged_height];

    % h_subplot=subplot(m,n,p,varargin{:},'Position',pos_vec);
    % Above line doesn't work as subplot tends to ignore 'position' when same mnp is utilized
    h_subplot = subplot('Position', pos_vec, varargin{:});

    if nargout ~= 0
        h = h_subplot;
    end
end
