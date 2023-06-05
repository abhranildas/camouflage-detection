function [Zr, R] = radialavg(z,m,xo,yo)
% RADIALAVG	 Radially averaqe 2D square matrix z into m bins
%
% [Zr, R] = RADIALAVG(z,m,xo,yo)
%
% [Zr, R] = RADIALAVG(z,m,xo,yo) computes the average along the radius of a
% unit circle inscribed in the square matrix z. The average is computed in
% M bins. The radial average is computed 1/2 bin beyond the unit circle,
% but all values beyond that (i.e. corners of the matrix z) are excluded
% from the calculation. The radial average is returned in Zr and the
% mid-points of the M bins are returned in vector R. RADIALAVG will fail if
% Not a Number (NaN) values are in the data z; they are not excluded from
% the calculation. If offset values xo,yo are used, the origin (0,0) of the
% unit circle about which the RADIALAVG is computed is offset by xo and yo
% relative to the origin of the unit square of the input z matrix.
%
% Example
%	N=101;
%	[X,Y] = meshgrid(-1:2/(N-1):1);
%	xo = +0.25;
%	yo = -0.25;
%	X = X-xo;
%	Y = Y-yo;
%	z = 1-sqrt(X.^2 + Y.^2);
%	m=(N-1)/2+1;
%	[Zr,R] = radialavg(z,m,xo,yo);
%	figure;plot(R,Zr,'.-');
%
% INPUT
% z = square input matrix to be radially averaged
% m = number of bins in which to compute radial average
% xo = offset of x-origin relative to unit square (DEF: 0)
% yo = offset of y-origin relative to unit square (DEF: 0)
%
% OUTPUT
% Zr = radial average of length m
% R  = m locations of Zr (i.e. midpoints of the m bins)
% 
% See also linspace, meshgrid, accumarray

% (c) 2022 David J. Fischer | fischer@shoutingman.com
% 4/4/14 DJF first working version
% 5/2/14 DJF documentation & radialavg_tester.m to demonstrate use
% radial distances r over grid of z
% 6/20/16 DJF Excludes NaN values
% 6/21/16 DJF Added origin offset
% 1/21/22 DJF Changed to accumarray for averaging,
%             made improvements based on recommendations in comments
%             https://www.mathworks.com/matlabcentral/answers/251714-radial-average-of-2d-matrix

if ~exist('xo','var')
	xo = 0;
end
if ~exist('yo','var')
	yo = 0;
end

% Compute unit circle radial distances
N = size(z,1);
[X,Y] = meshgrid(-1:2/(N-1):1);
X = X-xo;
Y = Y-yo;
r = sqrt(X.^2+Y.^2);

% Compute bin and bin locations
dr = 1/(m-1);
R = (0:dr:1);

% Compute bins of data matrix for averaging by accumarray
bins = round(r/dr)+1;

% reshape matrices to vectors for accumarray operation
bins = reshape(bins,N*N,1);
z = reshape(z,N*N,1);

% Compute radial average (mean)
Zr = accumarray(bins,z,[],@mean);

% Remove average values beyond unit circle & transpose to match format from prior versions
Zr = Zr(1:m)';
