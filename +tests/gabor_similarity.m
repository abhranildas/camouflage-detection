function gabor_similarity(testTypeStr, valueRange)
% GABOR_SIMILARITY  Test script that plots the change in similarity over a
%     change in a property of the gabor.
%   tests.gabor_similarity(testTypeStr, valueRange)
%
%   Test types:
%     phase, orientation, frequency, amplitude
%   Example:
%     tests.gabor_similarity('orientation', -90:90)
%
%   Output:
%     none; plots similarity vs. the tested property.
%
%   v1.0, 4/21/2016, Steve Sebastian <sebastian@utexas.edu>

% Generate gabor

gaborParams.std = .14;
gaborParams.sf = 4;
gaborParams.ori = 90;
gaborParams.phase = 0;
gaborParams.pixperdeg = 120;
gaborParams.odd_even = 'odd';
gaborParams.envelope = 'coswin';

[gabor, envelope] = lib.gabor_2d(gaborParams, 0);

% Iterate over values and compute similarity
simArray = zeros(size(valueRange));
ampScale = 1;
for iVal = 1:length(valueRange)
    if(strcmp(testTypeStr, 'orientation'))
        gaborParams.ori = valueRange(iVal);
    elseif(strcmp(testTypeStr, 'phase'))
        gaborParams.phase = valueRange(iVal);
    elseif(strcmp(testTypeStr, 'frequency'))
        gaborParams.sf = valueRange(iVal);
    else
        ampScale = valueRange(iVal);
    end

    thisGabor = ampScale.*lib.gabor_2d(gaborParams, 0);
    % BUG (new, B2-level): stats.computeSceneSimilarityAmplitude does not
    % exist — the file backing it, +stats/_computeSceneSimilarityAmplitude.m,
    % is `_`-prefixed and therefore not reachable under this name. Errors
    % immediately if this script is run with any testTypeStr. Left as found.
    similarityOut = stats.computeSceneSimilarityAmplitude(gabor, thisGabor, envelope, [51 51]);

    simArray(iVal) = similarityOut.Smag;
end

plot(valueRange, simArray, '-', 'LineWidth', 2);
axis square;
box off;
set(gca, 'TickDir', 'out');
set(gcf, 'color', 'w');
set(gca, 'fontsize', 24);
ylim([0 1]);
xlabel(testTypeStr, 'fontsize', 28);
ylabel('Similarity', 'fontsize', 28);
