function [haar, envelope] = haar2D(Parameters)
%% haar2D.m
%
%       [gabor, envelope] = gabor2D(X,Y,Parameters)
%
%  Create gabor with the given parameters. Parameters is a struct with the
%  following fields:
%       Parameters.pixperdeg    
%       Parameters.size       (deg) (default: 6*std)
%       Parameters.dc         DC value (default: 0)
%       Parameters.contrast   Michelson contrast (default (100%): 1)
%       Parameters.type       Type of Haar (default: Horizontal)
%
%  October 2, 2015, R. Calen Walshe <calen.walshe@utexas.edu>
%/

%% Check input
if (nargin < 1)
    Parameters.pixperdeg    = 60;
    Parameters.size         = .35;
    Parameters.dc           = 0;
    Parameters.type         = 'vertical';
    Parameters.contrast     = 1;
else
    HAAR_PARAMS     = {'pixperdeg','size','dc','contrast','type'};
    param_fields    = fieldnames(Parameters);
    has_params      = ismember(HAAR_PARAMS, param_fields);
    if(any(~has_params))
        error('Poorly specified haar parameter set');
    end    
end

%% Create Haar grid XX and YY and transform it
sizeRadPx   = floor(Parameters.size/2*Parameters.pixperdeg);
r           = Parameters.size/2; %radius of Haar

X = (-sizeRadPx:sizeRadPx) / Parameters.pixperdeg;
Y = (sizeRadPx:-1:-sizeRadPx) / Parameters.pixperdeg;

[XX YY]     = meshgrid(X,Y);
haarGrid    = XX.^2 + YY.^2 < r^2;

% amplitude depends on requested contrast
% but when dc == 0, contrast is undefined, so use unity amplitude
if (Parameters.dc ~= 0)
    amp = Parameters.dc * Parameters.contrast;
else
    amp = 1;
end

switch Parameters.type
    case('horizontal')
        haar    = [repmat(amp,sizeRadPx,2*sizeRadPx+1);repmat(Parameters.dc,1,2*sizeRadPx+1);repmat(-amp,sizeRadPx,2*sizeRadPx+1)];
    case('vertical')
        haar    = [repmat(amp,2*sizeRadPx+1,sizeRadPx),repmat(Parameters.dc,2*sizeRadPx+1,1),repmat(-amp,2*sizeRadPx+1,sizeRadPx)]; % vertical edge haar        
    case('bowtie')
        hwR   = YY./XX;    
        angleMat = atan2(YY,XX);
        angleMat(isnan(angleMat(:))) = 0; % middle pixel is NaN. We want it to be 0.
        
        haar = ones(sizeRadPx*2 + 1) * Parameters.dc;
        
        haar(angleMat > 0 & angleMat < pi/2)  = amp;
        haar(angleMat > pi/2 & angleMat < pi) = -amp;
        haar(angleMat < 0 & angleMat > -pi/2) = -amp;
        haar(angleMat < -pi/2 & angleMat > -pi) = amp;        
    otherwise
        error('Haar type error');
end

haar            = haarGrid .* haar;
haar(haar == 0) = Parameters.dc; % make the surround mean luminance.

%%Envelope
X = (-sizeRadPx*3:sizeRadPx*3) / Parameters.pixperdeg;
Y = (-sizeRadPx*3:sizeRadPx*3) / Parameters.pixperdeg;

[XX YY]     = meshgrid(X,Y);
envelope    = haarGrid;
