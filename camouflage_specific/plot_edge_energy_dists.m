load seed_energy

%% magnitude
figure(1)
histogram(seed_energy(:,2),'Normalization','pdf','LineStyle','none','FaceColor','r','FaceAlpha',.7)
hold on
histogram(seed_energy(:,5),'Normalization','pdf','LineStyle','none','FaceColor',[0 .45 .74],'FaceAlpha',.7)
xlim([40 130])
set(gca,'XTick',[40 80 120])
xlabel 'edge energy (magnitude)'
ylabel 'probability density'
set(gca,'FontSize',13)

%% direction
figure(2)
histogram(seed_energy(:,3),'Normalization','pdf','LineStyle','none','FaceColor','r','FaceAlpha',.7)
hold on
histogram(seed_energy(:,6),'Normalization','pdf','LineStyle','none','FaceColor',[0 .45 .74],'FaceAlpha',.7)
xlim([275 450])
set(gca,'XTick',[300 350 400 450])
xlabel 'edge energy (direction)'
ylabel 'probability density'
set(gca,'FontSize',13)

%% magnitude+direction
figure(3)
histogram(seed_energy(:,4),'Normalization','pdf','LineStyle','none','FaceColor','r','FaceAlpha',.7)
hold on
histogram(seed_energy(:,7),'Normalization','pdf','LineStyle','none','FaceColor',[0 .45 .74],'FaceAlpha',.7)
xlim([20 120])
xlabel 'edge energy (magnitude + direction)'
ylabel 'probability density'
set(gca,'FontSize',13)

%% magnitude, direction
figure(4)
scatter(seed_energy(:,2),seed_energy(:,3),'Marker','o','SizeData',5,'MarkerFaceColor','r','MarkerFaceAlpha',.01,'MarkerEdgeColor','none')
hold on
scatter(seed_energy(:,5),seed_energy(:,6),'Marker','o','SizeData',5,'MarkerFaceColor',[0 .45 .74],'MarkerFaceAlpha',.01,'MarkerEdgeColor','none')
xlim([20 150])
set(gca,'XTick',[50 100 150])
xlabel 'edge energy (magnitude)'
ylim([275 450])
set(gca,'YTick',[300 350 400 450])
ylabel 'edge energy (direction)'
set(gca,'FontSize',13)

%% direction, magnitude+direction
figure(5)
scatter(seed_energy(:,3),seed_energy(:,4),'Marker','o','SizeData',5,'MarkerFaceColor','r','MarkerFaceAlpha',.01,'MarkerEdgeColor','none')
hold on
scatter(seed_energy(:,6),seed_energy(:,7),'Marker','o','SizeData',5,'MarkerFaceColor',[0 .45 .74],'MarkerFaceAlpha',.01,'MarkerEdgeColor','none')
xlim([275 450])
set(gca,'XTick',[300 350 400 450])
xlabel 'edge energy (direction)'
ylim([20 150])
set(gca,'YTick',[50 100 150])
ylabel 'edge energy (magnitude + direction)'
set(gca,'FontSize',13)

%% magnitude+direction, magnitude
figure(6)
scatter(seed_energy(:,4),seed_energy(:,2),'Marker','o','SizeData',5,'MarkerFaceColor','r','MarkerFaceAlpha',.01,'MarkerEdgeColor','none')
hold on
scatter(seed_energy(:,7),seed_energy(:,5),'Marker','o','SizeData',5,'MarkerFaceColor',[0 .45 .74],'MarkerFaceAlpha',.01,'MarkerEdgeColor','none')
hline = refline([1 0]);
hline.Color = 'k';
xlim([20 150])
set(gca,'XTick',[50 100 150])
xlabel 'edge energy (magnitude + direction)'
ylim([20 150])
set(gca,'YTick',[50 100 150])
ylabel 'edge energy (magnitude)'
axis image
set(gca,'FontSize',13)

%% magnitude, direction, magnitude+direction
figure(7)
scatter3(seed_energy(:,5),seed_energy(:,6),seed_energy(:,7),'Marker','o','SizeData',10,'MarkerFaceColor',[0 .45 .74],'MarkerFaceAlpha',.03,'MarkerEdgeColor','none')
hold on
scatter3(seed_energy(:,2),seed_energy(:,3),seed_energy(:,4),'Marker','o','SizeData',10,'MarkerFaceColor','r','MarkerFaceAlpha',.03,'MarkerEdgeColor','none')
xlim([40 160])
set(gca,'XTick',[40 80 120])
xlabel 'mag'
ylim([275 450])
set(gca,'YTick',[300 350 400 450])
ylabel 'dir'
zlim([20 120])
set(gca,'ZTick',[40 80 120])
zlabel 'mag + dir'
set(gca,'FontSize',13)

set(gcf,'color','w');
set(gcf, 'visible','off')
f=getframe(gcf);
[im,map]=rgb2ind(f.cdata,256,'nodither');
k=1;
for az=0:.5:10
    az
    view([az,30])
    f=getframe(gcf);
    im(:,:,1,k)=rgb2ind(f.cdata,map,'nodither');
    k=k+1;
end
imwrite(im,map,'scatter3_mag_dir_mag+dir.gif','DelayTime',0.03,'LoopCount',inf);