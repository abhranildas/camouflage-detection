function rad = deg2rad(deg)
% DEG2RAD  Converts degrees to radians.
%   rad = lib.deg2rad(deg)
%
%   Output
%     rad - value in radians.
%
%   This shadows the MATLAB builtin DEG2RAD; every call in this repo is
%   qualified (lib.deg2rad), so the shadow is harmless but worth knowing
%   about before "simplifying" a call site to the bare name.
%
%   See also DEG2RAD, lib.GABOR_2D.

    rad = deg./180.*pi;
end
