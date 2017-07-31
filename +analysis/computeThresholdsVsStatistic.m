function thresholds = computeThresholdsVsStatistic(ImgStats, binIndexLevels,  statTypeStr, expTypeStr, targetTypeStr, subjectsStr, bBootstrap, bModel)

%% Compute thresholds for each subject and each bin
for iSubject = 1:size(subjectsStr,1)
    for iBins = 1:size(binIndexLevels,1)
        [thresholds(iSubject,iBins), thresholdsStd(iSubject,iBins)] = ...
            analysis.computeThresholdInBin(binIndexLevels(iBins,:), expTypeStr, ...
                targetTypeStr, subjectsStr(iSubject,:),0,bBootstrap);
    end
end

%% Plot thresholds vs statistics
if(strcmp(statTypeStr, 'contrast'))
    backgroundValues = ImgStats.Settings.binCenters.C(binIndexLevels(:,2));
    xAxisLabel = 'Background Contrast';
elseif(strcmp(statTypeStr, 'similarity'))
    targetIndex = lib.getTargetIndexFromString(ImgStats.Settings, targetTypeStr);
    backgroundValues = ImgStats.Settings.binCenters.Sa(binIndexLevels(:,3), targetIndex)';
    xAxisLabel = 'Background Similarity';
end

figure; hold on;
axis square; box off;
set(gca, 'FontSize', 20);
set(gca,'TickDir','out')
set(gcf,'color','w');
% yLabelVal = 0.5:0.1:1;
% set(gca, 'YTick', yLabelVal);
% set(gca,'YTickLabel',sprintf('%1.1f\n',yLabelVal));
xLabelVal = backgroundValues;
set(gca, 'XTick', backgroundValues);
set(gca,'XTickLabel',sprintf('%.3f\n',xLabelVal));
xlabel(xAxisLabel);
ylabel('Threshold Amplitude');
ylim([0 max(thresholds(:))*1.1]);

for iSubject = 1:size(subjectsStr,1)
    if(bBootstrap)
        errorbar(backgroundValues, thresholds(iSubject,:), thresholdsStd(iSubject,:), '-o', 'MarkerSize', 11, 'MarkerFaceColor', 'auto', 'LineWidth', 2);
    else
        plot(backgroundValues, thresholds(iSubject,:), '-o', 'MarkerSize', 11, 'MarkerFaceColor', 'auto', 'LineWidth', 2);
    end
end

if(bModel)
    bScale = 1;
    tSigma = analysis.computeTemplateResponseSigma(ImgStats, targetTypeStr, bScale);
    eff = 0.0001;
    for bItr = 1:size(binIndexLevels,1)
        modelAmp(bItr) = eff.*tSigma(binIndexLevels(bItr, 1), binIndexLevels(bItr, 2), binIndexLevels(bItr, 3));
    end
    plot(backgroundValues, modelAmp, '-ok', 'MarkerSize', 11, 'MarkerFaceColor', 'k', 'LineWidth', 2);
else
    if(size(thresholds, 1) > 1)
        plot(backgroundValues, mean(thresholds), '-ok', 'MarkerSize', 11, 'MarkerFaceColor', 'k', 'LineWidth', 2);
    end    
end



legend(subjectsStr, 'Location', 'northwest');
legend('boxoff');
