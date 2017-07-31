function [cT, cTStd] = computeThresholdInBin(binIndex, expTypeStr, targetTypeStr, subjectStr, bPlot, bBootstrap)


% Load in subject experiment file
load(['./experiment_files/subject_out/' expTypeStr '/' targetTypeStr '/' subjectStr '.mat']);

expBinIndex = find(SubjectExpFile.binIndex(:,1) == binIndex(1) & SubjectExpFile.binIndex(:,2) == binIndex(2) & SubjectExpFile.binIndex(:,3) == binIndex(3));

nTrials = size(SubjectExpFile.correct, 1);
targetLvls = SubjectExpFile.targetAmplitude(1,:,1,expBinIndex);
nLevels = length(targetLvls);

completedBinIndex = SubjectExpFile.levelCompleted(:,expBinIndex) == nLevels;

if(sum(completedBinIndex) == 0)
    error(['Error: Needed ' num2str(nLevels) ' levels to fit psychometric function.']);
end

expLvls = [];
expCorrect = [];

if(bPlot)
    disp(['Sessions used: ' num2str(sum(completedBinIndex))]);
end

for cItr = 1:length(completedBinIndex)
    if(completedBinIndex(cItr))
        expLvls    = [expLvls; SubjectExpFile.targetAmplitude(:,:,cItr,expBinIndex)];
        expCorrect = [expCorrect; SubjectExpFile.correct(:,:,cItr,expBinIndex)];
    end
end

[cT, b] = analysis.fitPsychometric(0.02, 2, expLvls, expCorrect);

%% Figure properties
if(bPlot)
    figure; hold on; 
    ylim([0.5 1]);
    xLimFactor = -1*diff(targetLvls);
    xlim([targetLvls(end)-xLimFactor(2), targetLvls(1)+xLimFactor(1)]);
    axis square; box off;
    set(gca, 'FontSize', 20);
    set(gca,'TickDir','out')
    set(gcf,'color','w');
    yLabelVal = 0.5:0.1:1;
    set(gca, 'YTick', yLabelVal);
    set(gca,'YTickLabel',sprintf('%1.1f\n',yLabelVal));
    xLabelVal = targetLvls;
    set(gca, 'XTick', fliplr(xLabelVal));
    set(gca,'XTickLabel',sprintf('%.3f\n',fliplr(xLabelVal)));
    x = 0:0.0001:(targetLvls(1)+0.2);
    y =  normcdf(0.5.*(x./cT).^b);
    plot(x, y, 'k-', 'LineWidth', 2);
    xlabel('Target Amplitude');
    ylabel('Proportion Correct');
end

%% Fit psychometric function
cTStd = 0;
if(bBootstrap)
   nBootItr = 100;
   for iBoot= 1:nBootItr
       correctBoot = datasample(expCorrect, nTrials, 'Replace', true);
       percentCorrect(:,iBoot) = mean(correctBoot);
       cTBoot(iBoot) = analysis.fitPsychometric(0.05, 2, SubjectExpFile.targetAmplitude(:,:,1,expBinIndex), correctBoot);
   end
   cTStd = std(cTBoot);
   meanPc = mean(percentCorrect,2);
   stdPc = std(percentCorrect, 0, 2);
   if(bPlot)
        errorbar(targetLvls, meanPc, stdPc, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'auto', 'LineWidth', 2);
   end
else
    percentCorrect = mean(expCorrect);
    if(bPlot)
        plot(targetLvls, percentCorrect, 'o', 'MarkerSize', 10, 'LineWidth', 2);
    end
end


