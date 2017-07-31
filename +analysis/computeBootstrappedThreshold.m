function [threshC, threshStdC, threshCDist] = computeBootstrappedThreshold(subjectStr, binIndex, blocks, numBootIter, bPlot)
%COMPUTEBOOTSTRAPPEDTHRESHOLD Computes experimental thresold with bootstrapped distribution
%
% Example: 
%   [threshC, stdC, cDist] = COMPUTEBOOTSTRAPPEDTHRESHOLD('SUB', [5 5 5], 1:2, 100, 1);
%
% Output:
%   threshC:        threshold 
%   threshStdC:     standard deviation of bootstrapped thresholds
%   threshCDist:    distribution of bootstrapped thesholds
%
%   See also FITPSYCHOMETRICFUNCTION.

% v0.1, 1/12/2016, Steve Sebastian <sebastian@utexas.edu>

%% Input handling

if(~exist('bPlot', 'var') || isempty(bPlot))
    bPlot   = 0;
end;

if(~exist('numBootIter', 'var') || isempty(numBootIter))
    numBootIter     = 500;
end;

%% Variable setup

contrast        = [];
correctMat      = [];
threshCDist   = zeros(1, numBootIter);

%% Load data from specified blocks
for blockIndex = 1:length(blocks)
    
    % load in the subject's data
    if(ismac())
        filePath = ['/Users/steve/Dropbox/Research/Jared_Project/exp_out/' subjectStr ...
            '/' num2str(binIndex(1)) num2str(binIndex(2)) num2str(binIndex(3)) ...
            '_' num2str(blocks(blockIndex)) '.mat'];
    else
        filePath = ['C:\Users\sebastian\Dropbox\Research\Jared_Project\exp_out\' subjectStr ...
            '\' num2str(binIndex(1)) num2str(binIndex(2)) num2str(binIndex(3)) ...
            '_' num2str(blocks(blockIndex)) '.mat'];
    end;
    load(filePath);
    
    % get the contrast levels
    contrastBlock = repmat(trialInfo.targetContrast', [1 size(trialInfo.correct, 2)]);
    contrast = [contrast contrastBlock(:)];
    
    correctMat  = [correctMat trialInfo.correct];
end;

% build a row subscript index for indexing into the correct response matrix
rowSub = repmat((1:size(correctMat,1))', [1 size(correctMat, 2)]);


%% Bootstrap the threshold data
for bootIndex = 1:numBootIter
    
    % get the random subscript
    randSub     = randi(size(correctMat,2), size(correctMat));
    
    % convert to index
    randIndex     = sub2ind(size(correctMat), rowSub, randSub);
    
    % sample
    correct     = correctMat(randIndex);
    
	% fit the data with a psychometric function
    [threshCDist(bootIndex), ~] = nm.analysis.fitPsychometric(0.1,2,contrast,correct(:));
    
end;

threshStdC = std(threshCDist);
threshC     = mean(threshCDist);
    
%% plot the distribution of thresholds
if(bPlot)
    figure; hold on;
    
    hist(threshCDist, 20); 
    formatFigure('Contrast Threshold', 'Count', ['L: ' num2str(binIndex(1)) ' C: ' num2str(binIndex(2)) ' S: ' num2str(binIndex(3))], 0, 0, 28, 24);
    axis square;
    
    
end;