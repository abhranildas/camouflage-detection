function gaborSimilarity(testTypeStr, valueRange)
%%GABORSIMILARITY Test script that plots the change in similarity over a
%%change in a property of the gavor
%
% Test types:
%   phase, orientation, frequency, amplitude
% Example:
%   StatsOut = tests.GABORSIMILARITY('orientation', -90:90)
%
% Output:
%   None
%
% v1.0, 4/21/2016, Steve Sebastian <sebastian@utexas.edu>

% Generate gabor

gaborParams.std        = .14;
gaborParams.sf         = 4;
gaborParams.ori        = 90;
gaborParams.phase      = 0;
gaborParams.pixperdeg  = 120;
gaborParams.odd_even   = 'odd';
gaborParams.envelope   = 'coswin';

[gabor, envelope] = lib.gabor2D(gaborParams, 0);

% Iterate over values and compute similarity
simArray = zeros(size(valueRange));
a = 1;
for vItr = 1:length(valueRange)
    if(strcmp(testTypeStr, 'orientation'))
        gaborParams.ori = valueRange(vItr);
    elseif(strcmp(testTypeStr, 'phase'))
        gaborParams.phase = valueRange(vItr);
    elseif(strcmp(testTypeStr, 'frequency'))
        gaborParams.sf = valueRange(vItr);
    else
        a = valueRange(vItr);
    end
    
    thisGabor = a.*lib.gabor2D(gaborParams, 0);
    sOut = stats.computeSceneSimilarityAmplitude(gabor, thisGabor, envelope, [51 51]);
    
    simArray(vItr) = sOut.Smag;
end

plot(valueRange, simArray, '-', 'LineWidth', 2);
axis square;
box off;
set(gca, 'TickDir', 'out' );
set(gcf,'color','w');
set(gca,'fontsize',24);
ylim([0 1]);
xlabel(testTypeStr, 'fontsize', 28);
ylabel('Similarity', 'fontsize', 28);
    