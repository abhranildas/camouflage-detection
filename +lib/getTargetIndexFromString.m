function tIndex = getTargetIndexFromString(Settings, targetTypeStr)
%GETTARGETINDEXFROMSTRING Returns the target key index given a target string
% 
% Example: 
%	Settings = stats.LOADEXPERIMENTSETTINGS('fovea');
%   tIndex = lib.GETTARGETINDEXFROMSTRING(Settings, gabor); 
%
% Output:
% 	tIndex 	target Index
%
% v1.0, 1/13/2016, Steve Sebastian <sebastian@utexas.edu>

%% Find the index, return -1 if not found
indexCell = strfind(Settings.targetKey, targetTypeStr);
tIndex = find(not(cellfun('isempty', indexCell)));

if(isempty(tIndex))
	tIndex = -1;
end