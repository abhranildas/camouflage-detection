function c = canon(file)
% CANON  Canonical, formatting-blind fingerprint of a .m file.
%   c = canon(file)
%
% Inputs
%   file  path to a .m file, char/string
% Output
%   c  canonical source text, char row: comments stripped, whitespace and
%      bracket spacing normalised, missing `end` supplied
%
% Parses FILE with mtree and prints it back with tree2str. Two files with the
% same canon() are behaviourally identical modulo comments/whitespace/renames.
% Pin the MATLAB version (mtree/tree2str are undocumented) in any commit that
% depends on this.
%
% See also CHECK_STAGE1

c = tree2str(mtree(file, '-file'));
end
