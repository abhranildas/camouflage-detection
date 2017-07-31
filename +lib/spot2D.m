function spot = spot2D(stimulusParams)
% SPOT2D Create a pedestal stimulus. ------
%                                   |  __  | 
%                                   | |  | |
%                                   |  --  |
%                                    ------
% R. Calen Walshe 02/12/2016 (calen.walshe@utexas.edu)

if nargin < 1
    stimulusParams.pixperdeg = 60;
    stimulusParams.size        = .35;
    stimulusParams.dc          = 0;    
    stimulusParams.contrast    = 1;
    stimulusParams.type        = 'spot';
end


if (stimulusParams.dc ~= 0)
    amp = stimulusParams.dc * stimulusParams.contrast;
else
    amp = 1;
end

paramNames      =  {'pixperdeg','size','dc','contrast','type'};
param_fields    = fieldnames(stimulusParams);
has_params      = ismember(paramNames,param_fields);
if(any(~has_params))
    error('Poorly specified haar parameter set');
end    

spotRadPx       = floor((stimulusParams.size/2)*stimulusParams.pixperdeg);

interiorRadDeg  = stimulusParams.size/2 * 1/sqrt(2);

[XX, YY] = meshgrid(-spotRadPx:spotRadPx);

dGrid       = sqrt(XX.^2 + YY.^2) ./ stimulusParams.pixperdeg;
envelope    = dGrid < stimulusParams.size/2;

spot                         = ones(size(dGrid)) * -amp;
spot(dGrid >= interiorRadDeg) = amp;
spot                         = spot .* envelope;


nInner = size(spot(dGrid < interiorRadDeg),1); % Number of pixels in the inner region
nOuter = size(spot(dGrid(envelope) > interiorRadDeg),1); % Number of pixels in the outer region.

spot(dGrid < interiorRadDeg) = spot(dGrid < interiorRadDeg) * nOuter/nInner; % Scale the magnitude of the inner region. Region under the target envelope integrates to 0.

end
