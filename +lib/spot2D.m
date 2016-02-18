function spot = spot2D(stimulusParams, tWin)
% SPOT2D Create a pedestal stimulus. /----\
%                                   |  __  | 
%                                   | |__| |
%                                    \____/                 
% R. Calen Walshe 02/12/2016 (calen.walshe@utexas.edu)

paramNames      =  {'pixperdeg','size','dc','contrast','type'};
param_fields    = fieldnames(stimulusParams);
has_params      = ismember(paramNames,param_fields);
if(any(~has_params))
    error('Poorly specified haar parameter set');
end    

spotRadPx      = floor((stimulusParams.size*stimulusParams.pixperdeg)/2);
widthIntDeg    = spotRadPx/stimulusParams.pixperdeg * .75;

[XX, YY] = meshgrid(-spotRadPx:spotRadPx);

dGrid = sqrt(XX.^2 + YY.^2) ./ stimulusParams.pixperdeg;

spot = zeros(size(dGrid));

spot(dGrid > widthIntDeg) = -1;
spot(dGrid < widthIntDeg) = 1;

spot = (spot - mean(spot(tWin(:)))) .* tWin;

end