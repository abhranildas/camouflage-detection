%% plot feature distributions for actual and perceived target vs blank

% select=SubjectExpFile.response;
select=ExpSettings.bTargetPresent;

% no. of contours
% figure; hold on;
%
% % boundary
% histogram(num_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(num_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(num_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'no. of contours'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff



% no. density of contour pixels
figure; hold on;

% boundary
histogram(dens_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
histogram(dens_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');

% texture
histogram(dens_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');

xlabel 'no. density of contour pixels'



% contour length
figure; hold on;

% boundary
histogram(length_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
histogram(length_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');

% texture
histogram(length_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');

xlabel 'contour length'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff




% contour edge powers
figure; hold on; grid on

% boundary
plot3(ep1_bd(select),ep2_bd(select),ep4_bd(select),'.r')
plot3(ep1_bd(~select),ep2_bd(~select),ep4_bd(~select),'.b')

% texture
plot3(ep1_tx(:),ep2_tx(:),ep4_tx(:),'.k')

xlabel 'edge power (1px)'; ylabel 'edge power (2px)'; zlabel 'edge power (4px)'




% length-weighted contour edge powers
% figure; hold on; grid on
%
% % boundary
% plot3(ep1w_bd(select),ep2w_bd(select),ep4w_bd(select),'.r')
% plot3(ep1w_bd(~select),ep2w_bd(~select),ep4w_bd(~select),'.b')
%
% % texture
% plot3(ep1w_tx(:),ep2w_tx(:),ep4w_tx(:),'.k')
%
% xlabel 'edge power (1px)'; ylabel 'edge power (2px)'; zlabel 'edge power (4px)'




% % contour edge power (1px)
% figure; hold on;
%
% % boundary
% histogram(ep1_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(ep1_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(ep1_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'edge power (1px)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff
%
%
%
% % contour edge power (2px)
% figure; hold on;
%
% % boundary
% histogram(ep2_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(ep2_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(ep2_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'edge power (2px)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff
%
%
%
% % contour edge power (4px)
% figure; hold on;
%
% % boundary
% histogram(ep4_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
% histogram(ep4_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');
%
% % texture
% histogram(ep4_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');
%
% xlabel 'edge power (4px)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff
%


% curvature
figure; hold on;

% boundary
histogram(curv_bd(select),'facecolor','r','facealpha',.5,'edgecolor','none','normalization','pdf');
histogram(curv_bd(~select),'facecolor','b','facealpha',.5,'edgecolor','none','normalization','pdf');

% texture
histogram(curv_tx(:),'facecolor','k','facealpha',.3,'edgecolor','none','normalization','pdf');

xlabel 'curvature (deg)'
% legend('boundary (response yes)','boundary (response no)','texture'); legend boxoff

%% plot feature distributions block-by-block

cue_tx=ep4_tx;
cue_bd=cues_bd.dens;

select=ExpSettings.bTargetPresent;
% select=SubjectExpFile.response;

% texture cue: all
mean_tx=mean(cue_tx,[1 3]);
sd_tx=std(cue_tx,0,[1 3]);

% boundary cue: target
mean_true_target=nan(1,ExpSettings.nLevels);
sd_true_target=nan(size(mean_true_target));

% boundary cue: blank
mean_true_blank=nan(size(mean_true_target));
sd_true_blank=nan(size(mean_true_target));


for i=1:ExpSettings.nLevels
    cue_thislevel=cue_bd(:,i,:);
    true_thislevel=select(:,i,:);
    
    mean_true_target(i)=mean(cue_thislevel(true_thislevel));
    sd_true_target(i)=std(cue_thislevel(true_thislevel));
    
    mean_true_blank(i)=mean(cue_thislevel(~true_thislevel));
    sd_true_blank(i)=std(cue_thislevel(~true_thislevel));
end

figure; hold on
errorbar(mean_true_target,sd_true_target,'-or')
errorbar(mean_true_blank,sd_true_blank,'-ob')
errorbar(mean_tx,sd_tx,'-ok')
xlim([.5 10.5]); xlabel('level')

%% plot only d' of only bd features block-by-block

cue=cues_bd.dens;
figure; hold on; title 'edge power (4px)'

true_target=ExpSettings.bTargetPresent;

response_target=SubjectExpFile.response;

for i=1:ExpSettings.nLevels
    cue_thislevel=cue(:,i,:);
    true_thislevel=true_target(:,i,:);
    response_thislevel=response_target(:,i,:);
    
    mean_true_target(i)=mean(cue_thislevel(true_thislevel));
    sd_true_target(i)=std(cue_thislevel(true_thislevel));
    
    mean_true_blank(i)=mean(cue_thislevel(~true_thislevel));
    sd_true_blank(i)=std(cue_thislevel(~true_thislevel));

    mean_response_target(i)=mean(cue_thislevel(response_thislevel));
    sd_response_target(i)=std(cue_thislevel(response_thislevel));
    
    mean_response_blank(i)=mean(cue_thislevel(~response_thislevel));
    sd_response_blank(i)=std(cue_thislevel(~response_thislevel));
end

% d'
dprime_true=2*(mean_true_target-mean_true_blank)./(sd_true_target+sd_true_blank);
dprime_response=2*(mean_response_target-mean_response_blank)./(sd_response_target+sd_response_blank);

plot(dprime_true,'-ok','markersize',4,'markerfacecolor','k')
plot(dprime_response,'--ok','markersize',4,'markerfacecolor','k')
legend(sprintf("%.2f", mean(dprime_true)),sprintf("%.2f", mean(dprime_response)))
legend boxoff
axis([1 10 -1 7]); xlabel('level'); ylabel ("d'")
set(gca,'xtick',[1 10])
