function target_index = getTargetIndexFromString(Settings, target_type_str)
% GETTARGETINDEXFROMSTRING  Returns the target key index given a target string.
%   target_index = lib.getTargetIndexFromString(Settings, target_type_str)
%
%   Output
%     target_index - index of target_type_str within Settings.targetKey, or
%                    -1 if not found.
%
%   v1.0, 1/13/2016, Steve Sebastian <sebastian@utexas.edu>
%
%   See also STRFIND, FIND.

    %% Find the index, return -1 if not found
    index_cell = strfind(Settings.targetKey, target_type_str);
    target_index = find(not(cellfun('isempty', index_cell)));

    if (isempty(target_index))
        target_index = -1;
    end
end
