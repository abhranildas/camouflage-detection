function [gabor, envelope, sinusoid] = gabor2D(Parameters, bPlot)
%GABOR2D Create a gabor with the given parameters.
%
% Parameters is a struct with the following fields:
%       Parameters.std        (scalar or [X,Y])
%       Parameters.sf         (cpd)
%       Parameters.ori        (deg)
%       Parameters.phase      (deg)
%       Parameters.pixperdeg    
%       Parameters.size       (deg) (default: 6*std)
%       Parameters.offset     (deg) (scalar or [X,Y], default: 0)
%       Parameters.odd_even   ('odd'/'even', default: 'odd')
%       Parameters.envelope   ('gau'/'coswin', default: 'coswin')
%       Parameters.dc         DC value (default: 0)
%       Parameters.contrast   Michelson contrast (default (100%): 1)
%
% Example:
%   [gabor, envelope, sinusoid] = gabor2D(X,Y,Parameters)
%
% Output:
%   gabor:      gabor target
%   envelope:   envelope of the gabor
%   sinusoid:   sinusoid of the gabor
%
%   See also DIFFERENCEOFGAUSSIANS2D.
%
%
%  v2.0, July 2, 2015, Yoon Bai, Steve Sebastian, and Spencer Chen <spencer.chen@utexas.edu>


%% Check input
GABOR_PARAMS = {'std','sf','ori','pixperdeg','size','phase','odd_even','envelope','offset','dc','contrast'};
param_fields = fieldnames(Parameters);
has_params   = ismember(GABOR_PARAMS, param_fields);

% optional parameters
for ff = GABOR_PARAMS(~has_params),
    switch (ff{1})
        case 'odd_even'
            Parameters.odd_even = 'odd';
        case 'envelope'
            Parameters.envelope = 'coswin';
        case 'offset'
            Parameters.offset   = 0;
        case 'dc'
            Parameters.dc       = 0;
        case 'contrast'
            Parameters.contrast = 1;
        case 'size'
            Parameters.size     = 6*Parameters.std;
        case {'std','sf','ori','phase','pixperdeg'}
            error('Insufficient gabor parameters.');            
    end
end

% scalar std means both X and Y are the same
if (numel(Parameters.std) == 1)
    Parameters.std = [Parameters.std Parameters.std];
end

% scalar std means both X and Y are the same
if (numel(Parameters.offset) == 1)
    Parameters.offset = [Parameters.offset Parameters.offset];
end

Parameters.sf    = 2*pi*Parameters.sf;
Parameters.ori   = lib.deg2rad(Parameters.ori);
Parameters.phase = lib.deg2rad(Parameters.phase);

%% Create Gabor grid XX and YY and transform it

% create coordinate mesh
envelopeRadius = floor(Parameters.size/2 * Parameters.pixperdeg);
X = (-envelopeRadius:envelopeRadius) / Parameters.pixperdeg;
Y = (-envelopeRadius:envelopeRadius) / Parameters.pixperdeg;

[XX,YY] = meshgrid(X - Parameters.offset(1), Y - Parameters.offset(2));

% rotate coordinate mesh
RXX = XX*cos(Parameters.ori) - YY*sin(Parameters.ori);
RYY = XX*sin(Parameters.ori) + YY*cos(Parameters.ori);

% change coordinate aspect ratio
GaborAR = Parameters.std(2) / Parameters.std(1);
ry = sqrt(1/GaborAR);
rx = GaborAR * ry;
rhos = (rx*RXX).^2 + (ry*RYY).^2;

% envelop
GaborSD  = geomean(Parameters.std);
switch (Parameters.envelope)
    case 'gau'
        envelope = exp(-rhos/(2*GaborSD^2));
    case 'coswin'
        envelope = lib.cosWindow2(numel(X), 1, 0);
    otherwise
        envelope = ones(size(rhos));
end

% sinusoid
switch (Parameters.odd_even)
    case 'odd'
        sinusoid = cos(Parameters.sf*RXX - Parameters.phase);
    case 'even'
        sinusoid = sin(Parameters.sf*RXX - Parameters.phase);
    otherwise
        sinusoid = ones(size(RXX));
end

% amplitude depends on requested contrast
% but when dc == 0, contrast is undefined, so use unity amplitude
if (Parameters.dc ~= 0)
    amp = Parameters.dc * Parameters.contrast;
else
    amp = 1;
end

% output
gabor    = envelope .* sinusoid * amp + Parameters.dc;


%%
if(nargin >= 2 && bPlot)
    imagesc(gabor, [0 255]); 
    colormap(gray);
end;