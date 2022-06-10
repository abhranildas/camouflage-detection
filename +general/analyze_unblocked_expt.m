load('exp_files/pink_noise/exp_settings.mat','ExpSettings')

load('exp_files/pink_noise_unblocked/subject_out/adriana.mat','SubjectExpFile')
SubjectExpFile_ub=SubjectExpFile;
load('exp_files/pink_noise/subject_out/adriana.mat')

t=reshape(permute(SubjectExpFile.bTargetPresent,[2,1,3]),10,[])';
h=reshape(permute(SubjectExpFile.hit,[2,1,3]),10,[])';
c=reshape(permute(SubjectExpFile.correctRejection,[2,1,3]),10,[])';

t_ub=reshape(permute(SubjectExpFile_ub.bTargetPresent,[2,1,3]),10,[])';
h_ub=reshape(permute(SubjectExpFile_ub.hit,[2,1,3]),10,[])';
c_ub=reshape(permute(SubjectExpFile_ub.correctRejection,[2,1,3]),10,[])';

hr=sum(h)./sum(t);
hr_ub=sum(h_ub)./sum(t_ub);

cr=sum(c)./sum(~t);
cr_ub=sum(c_ub)./sum(~t_ub);

figure; hold on
plot(ExpSettings.edgePowerBlockCenters,hr_ub,'-o','color','b','markerfacecolor','w');
plot(ExpSettings.edgePowerBlockCenters,hr,'-o','color','b','markersize',4,'markerfacecolor','b');
plot(ExpSettings.edgePowerBlockCenters,cr_ub,'-o','color','r','markerfacecolor','w');
plot(ExpSettings.edgePowerBlockCenters,cr,'-o','color','r','markersize',4,'markerfacecolor','r');
legend('hit rate (shuffled)','hit rate (blocked)','correct rejection rate (shuffled)','correct rejection rate (blocked)')
legend boxoff

xlabel('edge power')

d=norminv(hr)-norminv(1-cr);
d_ub=norminv(hr_ub)-norminv(1-mean(cr_ub));

% figure; hold on
% plot(SubjectExpFile.edgePowerBlockCenters,d,'.b');
% plot(SubjectExpFile.edgePowerBlockCenters,d_ub,'or');

n_boot=100;
d_boot=nan(n_boot,10); d_ub_boot=nan(n_boot,10);

for i=1:n_boot
    % blocked experiment
    [t_boot,boot_idx]=datasample(t,30);
    h_boot=h(boot_idx,:);
    c_boot=c(boot_idx,:);
    
    hr_boot=sum(h_boot)./sum(t_boot);
    cr_boot=sum(c_boot)./sum(~t_boot);
    
    d_boot(i,:)=norminv(hr_boot)-norminv(1-cr_boot);
    
    % unblocked experiment
    [t_boot,boot_idx]=datasample(t_ub,30);
    h_boot=h_ub(boot_idx,:);
    c_boot=c_ub(boot_idx,:);
    
    hr_boot=sum(h_boot)./sum(t_boot);
    cr_boot=sum(c_boot)./sum(~t_boot);
    
    d_ub_boot(i,:)=norminv(hr_boot)-norminv(1-mean(cr_boot));
end

d_boot(isinf(d_boot))=nan;
d_ub_boot(isinf(d_ub_boot))=nan;

d(isinf(d))=5; d_ub(isinf(d_ub))=5;

d_std=std(d_boot,'omitnan');
d_std(isnan(d_std))=0;
d_ub_std=std(d_ub_boot,'omitnan');
d_ub_std(isnan(d_ub_std))=0;

figure; hold on
errorbar(ExpSettings.edgePowerBlockCenters,d,d_std,'b','marker','o','markerfacecolor','b');
errorbar(ExpSettings.edgePowerBlockCenters,d_ub,d_ub_std,'r','marker','o','markerfacecolor','r');

title('d prime'); legend('blocked','unblocked')


