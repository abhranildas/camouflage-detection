function assert_rename_bijection(renames)
% ASSERT_RENAME_BIJECTION  Guard against a scope-blind rename map giving a false pass.
%   assert_rename_bijection(renames)
%
% Inputs
%   renames  Nx2 cell array, {new_name, old_name}, one row per identifier
% Output
%   none (throws if the map is not a bijection with disjoint domain/range)
%
% The reverse-rename substitution in CHECK_STAGE1 is scope-blind: a map with a
% name on both sides (a->b and b->c) can turn an unrelated change into a false
% "isequal" pass. This must hold before that substitution is trusted.
%
% See also CHECK_STAGE1, CANON

dom = renames(:, 1);
ran = renames(:, 2);
assert(numel(unique(dom)) == numel(dom), 'assert_rename_bijection:dup_new', ...
    'duplicate new name in rename map');
assert(numel(unique(ran)) == numel(ran), 'assert_rename_bijection:dup_old', ...
    'duplicate old name in rename map');
assert(isempty(intersect(dom, ran)), 'assert_rename_bijection:overlap', ...
    'a name appears on both sides of the rename map');
end
