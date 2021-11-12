function [dPrime_theo,dPrime_approx,dPrime_meas,opt_pc_theo,opt_crit_theo]=dPrime(values_a,values_b,bPlot,resolution)

% means and standard deviations:
mu_a=mean(values_a); sd_a=std(values_a); mu_b=mean(values_b); sd_b=std(values_b);

% THEORETICAL d' FROM PERCENT CORRECT

% point of crossing in-between two separated Gaussians
% see
% https://stats.stackexchange.com/questions/103800/calculate-probability-area-under-the-overlapping-area-of-two-normal-distributi
opt_crit_theo=(mu_b*sd_a^2-sd_b*(mu_a*sd_b+sd_a*sqrt((mu_a-mu_b)^2+2*(sd_a^2-sd_b^2)*log(sd_a/sd_b))))/(sd_a^2-sd_b^2);

% theoretical percent correct
opt_pc_theo=(normcdf(opt_crit_theo,mu_a,sd_a)+1-normcdf(opt_crit_theo,mu_b,sd_b))/2;

% theoretical d'
dPrime_theo=2*norminv(opt_pc_theo);

% approximate d'
dPrime_approx=abs(mu_b-mu_a)/sqrt(mean([sd_a^2 sd_b^2]));

% find optimal criterion and % correct by explicit search:
if ~exist('resolution','var')
    resolution=100;
end

values_min=min([values_a(:);values_b(:)]);
values_max=max([values_a(:);values_b(:)]);
values_range=values_max-values_min;

crit=values_min:values_range/resolution:values_max;
acc=zeros(1,numel(crit));
for i=1:numel(crit)
    acc(i)=lib.discrim_accuracy(values_a,values_b,crit(i));
end
[opt_pc_meas,opt_idx]=max(acc);
opt_crit_meas=crit(opt_idx);

% measured dPrime from measured percent correct:
dPrime_meas=2*norminv(opt_pc_meas);

% plot:
if bPlot
    figure
    histogram(values_a,resolution,'Normalization','pdf','facecolor',[0 0 1], 'facealpha',0.5,'LineStyle','none');
    hold on
    histogram(values_b,resolution,'Normalization','pdf','facecolor',[1 0 0], 'facealpha',0.5,'LineStyle','none');
    %xlabel('edge strength')
    message = sprintf("%.2f%% correct \n d'_t = %.2f \n d'_m = %.2f",[100*opt_pc_meas,dPrime_theo,dPrime_meas]);
    text(.7,.77,message,'Units','Normalized','FontName','FixedWidth','FontWeight','Bold')
    %legend(message)    
    set(gca,'ytick',[])
    set(gca,'fontsize',13)
    plot(opt_crit_meas*[1 1],ylim,'k')
end