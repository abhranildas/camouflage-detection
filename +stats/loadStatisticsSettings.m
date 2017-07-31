function Settings = loadStatisticsSettings(typeStr)
%LOADSTATISTICSSETTINGS Returns structure with experimental values (e.g. targets)
% 
% Example: 
% 	Settings = LOADSTATISTICSSETTINGS('fovea')
%
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>

%%

if(strcmp(typeStr,'fovea'))

	% Target set up
	gaborParams.std        = .14;
	gaborParams.sf         = 4;
	gaborParams.ori        = 90;
	gaborParams.phase      = 0;
	gaborParams.pixperdeg  = 120;
	gaborParams.odd_even   = 'odd';
	gaborParams.envelope   = 'coswin';

	dogParams.stdSurround  = .14;
	dogParams.stdCenter    = 0.07;
	dogParams.pixperdeg    = 120;
	dogParams.envelope     = 'coswin';

	[gabor, envelope] = lib.gabor2D(gaborParams, 0);
	[dog, ~] =  lib.differenceOfGaussians2D(dogParams, 0);

	gabor = gabor./max(gabor(:));
	dog = dog./max(dog(:));

	targets(:,:,1) = gabor;
	targets(:,:,2) = dog;

	targetKey = {{'gabor', 'dog'}};

	% Statistic parameters
	surroundSizePix = 513;
	targetSizePix = size(gabor,1);
	spacingPix = 10;
	imgSizePix = [2844 4284];

	pixelMax = 2^14-1;

	% Binning parameters
    nBins = 10;
	[binEdges.L, binCenters.L]  = stats.computeBinSpacing(8, 62, nBins);
	[binEdges.C, binCenters.C]  = stats.computeBinSpacing(0.05, 0.36, nBins);
	[binEdges.Sa(:,1), binCenters.Sa(:,1)] = stats.computeBinSpacing(0.08, 0.64, nBins);
	[binEdges.Sa(:,2), binCenters.Sa(:,2)] = stats.computeBinSpacing(0.25, 0.75, nBins);
    [binEdges.Sa(:,3), binCenters.Sa(:,3)] = stats.computeBinSpacing(0.2, 0.6, nBins);
    
    [binEdges.Ss(:,1), binCenters.Ss(:,1)] = stats.computeBinSpacing(0.05, 0.3, nBins);
    [binEdges.Ss(:,2), binCenters.Ss(:,2)] = stats.computeBinSpacing(0.05, 0.4, nBins);
    [binEdges.Ss(:,3), binCenters.Ss(:,3)] = stats.computeBinSpacing(0.05, 0.3, nBins);
    
    imgFilePath = 'D:\sebastian\natural_images\images_stats';
    imgFilePathExperiment = 'D:\Sebastian\natural_images\images_pht';
    
	Settings = struct('imgFilePath', imgFilePath, 'imgFilePathExperiment', imgFilePathExperiment, 'targets', targets, 'targetKey', targetKey, 'envelope', envelope, 'gaborParams', gaborParams, 'dogParams', dogParams, ...
					  'surroundSizePix', surroundSizePix, 'targetSizePix', targetSizePix, 'spacingPix', spacingPix, ...
					  'imgSizePix', imgSizePix, 'pixelMax', pixelMax, 'binEdges', binEdges, 'binCenters', binCenters);

elseif(strcmp(typeStr, 'periphery'))
    
	% Target set up
    stimulusParams.pixperdeg    = 60;
    stimulusParams.size         = .34;
    stimulusParams.dc           = 0;
    stimulusParams.contrast     = 1;

    stimulusParams.type     = 'vertical';   
	[vertical, envelope]    = lib.haar2D(stimulusParams);
 
    stimulusParams.type     = 'horizontal';
    [horizontal, envelope]  = lib.haar2D(stimulusParams);
    
    stimulusParams.type     = 'bowtie';
    [bowtiehaar, envelope]  = lib.haar2D(stimulusParams);
    
    stimulusParams.type     = 'bowtie';
    [bowtiehaar, envelope]  = lib.haar2D(stimulusParams);
    
    stimulusParams.type     = 'spot';
    tWin                    = envelope;
    spot                    = lib.spot2D(stimulusParams);
	
    vertical    = vertical./max(vertical(:));
    horizontal  = horizontal./max(horizontal(:));
    bowtiehaar  = bowtiehaar./max(bowtiehaar(:));
    spot        = spot./max(spot(:));
        
	targets(:,:,1)  = vertical;
    targets(:,:,2)  = horizontal;
    targets(:,:,3)  = bowtiehaar;
    targets(:,:,4)  = spot;
    
	targetKey = {{'vertical','horizontal','bowtie','spot'}};
    
	% Statistic parameters
	surroundSizePix = 241;
	targetSizePix = size(targets(:,:,1));
	spacingPix = 10;
	imgSizePix = [2844 4284];

	pixelMax = 2^14-1;

	% Binning parameters
    nBins = 10;
	[binEdges.L, binCenters.L]  = stats.computeBinSpacing(2.47, 70.92, nBins);
	[binEdges.C, binCenters.C]  = stats.computeBinSpacing(0.02, 0.96, nBins);
	[binEdges.Sa(:,1), binCenters.Sa(:,1)] = stats.computeBinSpacing(0.41, 0.85, nBins);
	[binEdges.Sa(:,2), binCenters.Sa(:,2)] = stats.computeBinSpacing(0.43, 0.86, nBins);
	[binEdges.Sa(:,3), binCenters.Sa(:,3)] = stats.computeBinSpacing(0.53, 0.75, nBins);
	[binEdges.Sa(:,4), binCenters.Sa(:,4)] = stats.computeBinSpacing(0.69, 0.85, nBins);
    
    imgFilePath = '~/occluding/natural_images/pixel_space/';

	Settings = struct('imgFilePath', imgFilePath, 'targets', targets, 'targetKey', targetKey, 'envelope', envelope, 'stimulusParams', stimulusParams,...
                      'surroundSizePix', surroundSizePix, 'targetSizePix', targetSizePix, 'spacingPix', spacingPix, ...
					  'imgSizePix', imgSizePix, 'pixelMax', pixelMax, 'binEdges', binEdges, 'binCenters', binCenters);
                  
elseif(strcmp(typeStr, 'periphery_model'))
    % Images doubled from periphery to accomodate RV1 code that did retinal
    % blurring at 120 ppd. 
    
	% Target set up
    stimulusParams.pixperdeg    = 2*60;
    stimulusParams.size         = .34;
    stimulusParams.dc           = 0;
    stimulusParams.contrast     = 1;

    stimulusParams.type     = 'vertical';   
	[vertical, envelope]    = lib.haar2D(stimulusParams);
 
    stimulusParams.type     = 'horizontal';
    [horizontal, envelope]  = lib.haar2D(stimulusParams);
    
    stimulusParams.type     = 'bowtie';
    [bowtiehaar, envelope]  = lib.haar2D(stimulusParams);
    
    stimulusParams.type     = 'bowtie';
    [bowtiehaar, envelope]  = lib.haar2D(stimulusParams);
    
    stimulusParams.type     = 'spot';
    tWin                    = envelope;
    spot                    = lib.spot2D(stimulusParams);
	
    vertical    = vertical./max(vertical(:));
    horizontal  = horizontal./max(horizontal(:));
    bowtiehaar  = bowtiehaar./max(bowtiehaar(:));
    spot        = spot./max(spot(:));
        
	targets(:,:,1)  = vertical;
    targets(:,:,2)  = horizontal;
    targets(:,:,3)  = bowtiehaar;
    targets(:,:,4)  = spot;
    
	targetKey = {{'vertical','horizontal','bowtie','spot'}};
    
	% Statistic parameters
	surroundSizePix = 2*241;
	targetSizePix = size(targets(:,:,1));
	spacingPix = 2*10;
	imgSizePix = [2*2844 2*4284];

	pixelMax = 2^14-1;

	% Binning parameters
    nBins = 10;
	[binEdges.L, binCenters.L]  = stats.computeBinSpacing(2.47, 70.92, nBins);
	[binEdges.C, binCenters.C]  = stats.computeBinSpacing(0.02, 0.96, nBins);
	[binEdges.Sa(:,1), binCenters.Sa(:,1)] = stats.computeBinSpacing(0.41, 0.85, nBins);
	[binEdges.Sa(:,2), binCenters.Sa(:,2)] = stats.computeBinSpacing(0.43, 0.86, nBins);
	[binEdges.Sa(:,3), binCenters.Sa(:,3)] = stats.computeBinSpacing(0.53, 0.75, nBins);
	[binEdges.Sa(:,4), binCenters.Sa(:,4)] = stats.computeBinSpacing(0.69, 0.85, nBins);
    
    imgFilePath = '~/occluding/natural_images/pixel_space/';

	Settings = struct('imgFilePath', imgFilePath, 'targets', targets, 'targetKey', targetKey, 'envelope', envelope, 'stimulusParams', stimulusParams,...
                      'surroundSizePix', surroundSizePix, 'targetSizePix', targetSizePix, 'spacingPix', spacingPix, ...
					  'imgSizePix', imgSizePix, 'pixelMax', pixelMax, 'binEdges', binEdges, 'binCenters', binCenters);                  
    
else
	error('Error: Unsupported experiment type')
end
