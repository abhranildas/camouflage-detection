function match = check_stage1(old_file, new_file, renames)
% CHECK_STAGE1  Verify a Stage-1 readability edit changed nothing but style.
%   match = check_stage1(old_file, new_file, renames)
%
% Inputs
%   old_file  path to the pre-edit .m file, char/string
%   new_file  path to the post-edit .m file, char/string
%   renames   Nx2 cell array, {new_name, old_name}; pass {} if the edit
%             renamed nothing
% Output
%   match  true iff canon(new_file), with every new name substituted back to
%          its old name, is byte-identical to canon(old_file)
%
% Applies ASSERT_RENAME_BIJECTION first, then reverses the rename map on
% canon(new_file) with a negative-lookahead regex so a short name (e.g.
% "patch") cannot eat a longer one that starts with it (e.g. "patch_size").
%
% See also CANON, ASSERT_RENAME_BIJECTION

if nargin < 3
    renames = {};
end
if ~isempty(renames)
    assert_rename_bijection(renames);
end

c_old = canon(old_file);
c_new = canon(new_file);
for k = 1:size(renames, 1)
    pat = ['(?<![A-Za-z0-9_.])' renames{k, 1} '(?![A-Za-z0-9_])'];
    c_new = regexprep(c_new, pat, renames{k, 2});
end

match = isequal(c_old, c_new);
end
