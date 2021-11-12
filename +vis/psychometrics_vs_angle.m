luminance=.5; contrast=.15;
figure(1); hold on
blue=[0 0 255]/255; red=[255 0 0]/255;
ppd_values=[60 80 100 120];
for i=1:numel(ppd_values)
    ppd=ppd_values(i);
    if ppd==60
        exp_name=['1fnoise_L' num2str(luminance) '_C' num2str(contrast)];
    else
        exp_name=['1fnoise_L' num2str(luminance) '_C' num2str(contrast) '_D' num2str(ppd)];
    end
    [a, aStd, ~,~,~, exp_levels, meanPc, stdPc, x_pmf, y_pmf]=analysis.computeThresholdInBin(exp_name, 'ad',1,1);
    thresholds(i)=a;
    figure(1)
    color=(blue*(numel(ppd_values)-i+1)+red*(i-1))/numel(ppd_values);
    plot3(64./(ppd*ones(1,10)),exp_levels,meanPc,'ok', 'MarkerSize', 6, 'MarkerFaceColor', color);
    %errorbar(exp_levels, meanPc, stdPc, 'ok', 'MarkerSize', 7, 'MarkerFaceColor', 'w', 'LineWidth', 1);
    plot3(64/ppd*ones(1,numel(x_pmf)),x_pmf,y_pmf,'Color',color,'LineWidth', 2);    
    plot3(64/ppd*[1 1],a*[1 1],[.5 .7], '--', 'Color',color,'LineWidth', 1);
end

plot3(64./ppd_values,thresholds,0.5*ones(1,numel(ppd_values)),'k', 'Marker','x','MarkerSize',8,'LineWidth', 1);

xlim([.5 1.1])
xlabel({'visual angle','(deg)'})

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