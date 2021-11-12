figure
errorbar(dur(:,1),dur(:,2),dur(:,3),'-ok', 'linewidth',1, 'markersize',7,'MarkerFaceColor','w')
%xlim([0 .16])
ylim([.3 .52])
set(gca,'XTick',[0 200])
set(gca,'YTick',[0.3 0.5])
xlabel 'contrast'
ylabel 'detection threshold'
set(gca,'TickDir','out')
set(gca,'Fontsize',13)
box off
 