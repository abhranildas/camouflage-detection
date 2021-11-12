luminance=.5; contrast=.15;
figure(1); hold on
blue=[0 0 255]/255; red=[255 0 0]/255;
dur_values=[50 100 200 400 800];
for i=1:numel(dur_values)
    dur=dur_values(i);
    if dur==200
        exp_name=['1fnoise_L' num2str(luminance) '_C' num2str(contrast)];
    else
        exp_name=['1fnoise_L' num2str(luminance) '_C' num2str(contrast) '_T' num2str(dur)];
    end
    [a, aStd, ~,~,~, exp_levels, meanPc, stdPc, x_pmf, y_pmf]=analysis.computeThresholdInBin(exp_name, 'ad',1,1);
    thresholds(i)=a;
    figure(1)
    color=(blue*(numel(dur_values)-i+1)+red*(i-1))/numel(dur_values);
    plot3(dur*ones(1,10),exp_levels,meanPc,'ok', 'MarkerSize', 6, 'MarkerFaceColor', color);
    %errorbar(exp_levels, meanPc, stdPc, 'ok', 'MarkerSize', 7, 'MarkerFaceColor', 'w', 'LineWidth', 1);
    plot3(dur*ones(1,numel(x_pmf)),x_pmf,y_pmf,'Color',color,'LineWidth', 2);    
    plot3(dur*[1 1],a*[1 1],[.5 .7], '--', 'Color',color,'LineWidth', 1);
end

plot3(dur_values,thresholds,0.5*ones(1,numel(dur_values)),'k', 'Marker','x','MarkerSize',8,'LineWidth', 1);

xlim([50 800])
set(gca,'xscale','log')
xlabel({'duration','(ms)'})
set(gca,'xtick',dur_values);

ylabel 'edge strength'
ylim([0 1.5])
set(gca,'ytick',0:.5:1.5);
set(gca,'yticklabel',{'0','','','1.5'});

zlabel 'detection accuracy'
zlim([.5 1])
set(gca,'ztick',.5:.1:1);
set(gca,'zticklabel',{'50%','','','','','100%'});
grid on
set(gca,'FontSize',13)