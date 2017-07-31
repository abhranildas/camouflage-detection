figure(1)
histogram(seed_energy(:,2),'Normalization','pdf','LineStyle','none','FaceColor','r','FaceAlpha',.7)
hold on
histogram(seed_energy(:,5),'Normalization','pdf','LineStyle','none','FaceColor',[0 .45 .74],'FaceAlpha',.7)
xlabel 'edge energy (magnitude)'
set(gca,'FontSize',13)

figure(2)
histogram(seed_energy(:,3),'Normalization','pdf','LineStyle','none','FaceColor','r','FaceAlpha',.7)
hold on
histogram(seed_energy(:,6),'Normalization','pdf','LineStyle','none','FaceColor',[0 .45 .74],'FaceAlpha',.7)
xlabel 'edge energy (direction)'
set(gca,'FontSize',13)

figure(3)
histogram(seed_energy(:,4),'Normalization','pdf','LineStyle','none','FaceColor','r','FaceAlpha',.7)
hold on
histogram(seed_energy(:,7),'Normalization','pdf','LineStyle','none','FaceColor',[0 .45 .74],'FaceAlpha',.7)
xlabel 'edge energy (magnitude + direction)'
set(gca,'FontSize',13)

figure(4)
scatter(seed_energy(:,2),seed_energy(:,3),'Marker','o','SizeData',5,'MarkerFaceColor',[0 .45 .74],'MarkerFaceAlpha',.01,'MarkerEdgeAlpha',0)