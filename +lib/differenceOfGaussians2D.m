function [dog, envelope] = differenceOfGaussians2D(Parameters, bPlot)
%DIFFERENCEOFGAUSSIANS2D Create D.O.G. with the given parameters 
%
%   Parameters is a struct with the following fields:
%       Parameters.stdCenter  (scalar or [X,Y])
%       Paramsters.stdSurround
%       Parameters.pixperdeg    
%       Parameters.size       (deg) (default: 6*std)
%       Parameters.offset     (deg) (scalar or [X,Y], default: 0)
%       Parameters.envelope   ('gau'/'coswin', default: 'coswin')
%       Parameters.dc         DC value (default: 0)
%
% Example: 
%   [dog, envelope] = lib.DIFFERENCEOFGAUSSIANS2D(DogParams, 1);
% 
% Output:
%   dog:        difference of guassians
%   envelope:   envelope of the D.O.G.
%
%   See also GABOR2D.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%% Check input
GABOR_PARAMS = {'stdCenter','stdSurround','pixperdeg','sizeCenter','sizeSurround','offset','envelope','dc','contrast'};
param_fields = fieldnames(Parameters);
has_params   = ismember(GABOR_PARAMS, param_fields);

% optional parameters
for ff = GABOR_PARAMS(~has_params),
    switch (ff{1})
        case 'envelope'
            Parameters.envelope = 'coswin';
        case 'offset'
            Parameters.offset   = [0, 0];
        case 'dc'
            Parameters.dc       = 0;
        case 'contrast'
            Parameters.contrast = 1;
        case 'sizeSurround'
            Parameters.sizeSurround     = 6*Parameters.stdSurround;
        case 'sizeCenter'
            Parameters.sizeCenter       = 6*Parameters.stdCenter;
        case {'stdCenter','stdSurround','pixperdeg'}
            error('Insufficient gabor parameters.');            
    end
end

%% Center
% create coordinate mesh
envelopeRadius = floor(Parameters.sizeCenter/2 * Parameters.pixperdeg);
X = (-envelopeRadius:envelopeRadius) / Parameters.pixperdeg;

Y = (-envelopeRadius:envelopeRadius) / Parameters.pixperdeg;
[XX,YY] = meshgrid(X - Parameters.offset(1), Y - Parameters.offset(2));

rhos = (XX).^2 + (YY).^2;
GaborSD  = geomean(Parameters.stdCenter);
switch (Parameters.envelope)
    case 'gau'
        center = exp(-rhos/(2*GaborSD^2));
    case 'coswin'
        center = lib.cosWindow2(numel(X), 1, 0);
    otherwise
        center = ones(size(rhos));
end

%% Surround

% create coordinate mesh
envelopeRadius = floor(Parameters.sizeSurround/2 * Parameters.pixperdeg);
X = (-envelopeRadius:envelopeRadius) / Parameters.pixperdeg;

Y = (-envelopeRadius:envelopeRadius) / Parameters.pixperdeg;
[XX,YY] = meshgrid(X - Parameters.offset(1), Y - Parameters.offset(2));

rhos = (XX).^2 + (YY).^2;
GaborSD  = geomean(Parameters.stdSurround);
switch (Parameters.envelope)
    case 'gau'
        surround = exp(-rhos/(2*GaborSD^2));
    case 'coswin'
        surround = lib.cosWindow2(numel(X), 1, 0);
    otherwise
        surround = ones(size(rhos));
end

surround    = surround./(sum(surround(:)));
center      = center./(sum(center(:)));

center = lib.embedImageinCenter(zeros(size(surround)), center, 1);
dog = center - surround;
envelope = surround;

if(nargin >= 2 && bPlot)
    figure; subplot(1,2,1);
    imagesc(dog); axis square;  colormap gray;
    set(gca, 'XTick', []);
	set(gca, 'YTick', []);
    set(gca,'fontsize',14);
    xlabel('X');
    ylabel('Y');
    
    subplot(1,2,2);
    plot(1:size(dog,1), dog(ceil(size(dog,1)/2), 1:size(dog,1)), '-k', 'LineWidth', 2);
    set(gca, 'TickDir', 'out' );
    set(gcf,'color','w');
    set(gca,'fontsize',14);
    xlim([0 size(dog,1)]);
    xlabel('X');
    ylabel('Amplitude');
    axis square; box off;
end;
