%% 2D pink noise

size=200;
fil1f = zeros(size);
for n=1:size
    for j=1:size
        z=norm([n-size/2-1,j-size/2-1]);
        if z  % leave fft origin at 0
            fil1f(n,j) = 1/z;
        end
    end
end
% white noise image:
wn = normrnd(0,1,size);

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
wnf = fftshift(fft2(wn));

% multiply with 1/f filter
wnf = fil1f.*wnf;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
wnf=ifftshift(wnf);

% either use inverse fourier transform:
img_1f = ifft2(wnf);

% or do it manually as a learning tool:
img_1f_manual=zeros(size);

figure;
subplot(1,2,1);
imagesc(img_1f); colormap gray; axis image;

subplot(1,2,2);
for u=1:size
    u
    imagesc(img_1f_manual); colormap gray; axis image; drawnow
    for v=1:size
        cos_amp=real(wnf(u,v));
        sin_amp=imag(wnf(u,v));
        for n=1:size
            for j=1:size                
                img_1f_manual(n,j)=img_1f_manual(n,j)+...
                    cos_amp*cos(2*pi/size*((u-1)*j+(v-1)*n))+...
                    sin_amp*sin(2*pi/size*((u-1)*j+(v-1)*n));
            end
        end
    end
end
        
%% Verify convolution theorem
img=experiment.pink_noise_square(1000);
img_f=fft2(img);
img_corr=xcorr2(img);

img_corr_f=fft2(img_corr);
figure; surf(abs(fftshift(img_corr_f)));

img_f_2=img_f.*img_f;
figure; surf(abs(fftshift(img_f_2)));


[Zr, R] = radialavg(img_corr,100);
figure;
plot(log(R),log(Zr))

%% 1D pink noise: distribution
dim=1;
len=1e3;
log_kmin=-2;
log_kmax=2;
d_logk=.01;
klist=10.^(log_kmin:d_logk:log_kmax);
kmin=10^log_kmin; kmax=10^log_kmax;
n_ensemble=1e2;

% ensemble sampling
ys=zeros(n_ensemble,len);
for n=1:n_ensemble
    r_num=tinker.pink_noise_1D(len,klist);
    ys(n,:)=r_num;
end

% theory
[f_z,z]=tinker.pink_noise_dist(dim,klist);

% compare sampling vs theory
figure
histogram(ys(:),1000,'Normalization','pdf','EdgeColor','none'); hold on
plot(z,f_z,'r-','LineWidth',1); hold off

legend('sampled','theory');
legend boxoff
set(gca,'fontsize',13)

%% 1D pink noise: autocorrelation

% ensemble sampling
d=0:len-2;
autocorrs=zeros(n_ensemble,numel(d));
figure; hold on
for n=1:n_ensemble
    for lag=d
        corr=corrcoef(ys(n,1:end-lag),ys(n,1+lag:end));
        autocorrs(n,lag+1)=corr(1,2);
    end
    %autocorrs(n,:)=autocorr(ys(n,:),'NumLags',len-2);
    plot(d*kmin,autocorrs(n,:),'Color',[0 0 0 .1])
end

h_mean=plot(d*kmin,mean(autocorrs),'-k','LineWidth',1);

% analytical: discrete sum
r_num=zeros(size(d));
for k=klist
    r_num=r_num+cos(k*d)/k;
end

r=r_num/sum(1./klist);

h_anal_disc=plot(d*kmin,r,'r-','LineWidth',1);

% analytical: continuous integral from kmin to kmax
r_cont=(cosint(d*kmax)-cosint(d*kmin))/log(kmax/kmin);
r_cont(1)=1;
h_anal_cont=plot(d*kmin,r_cont,'-b','LineWidth',1);

xlabel ('d (in units of \lambda_{max})')
ylabel('correlation coefficient r(d)')
set(gca,'fontsize',13)
legend([h_mean, h_anal_disc, h_anal_cont],{'sample mean (discrete)','analytical (discrete)','analytical (continuous)'});
legend boxoff

%% 2D pink noise: distribution
dim=2;
len=100;
log_kmin=-1;
log_kmax=1;
d_logk=.1;
klist=10.^(log_kmin:d_logk:log_kmax);
kmin=10^log_kmin; kmax=10^log_kmax;
d_alph=.1; % spacing of component wave orientations

% ensemble sampling
img_ensemble=zeros(len,len,n_ensemble);
for n=1:n_ensemble
    n
    img_ensemble(:,:,n)=tinker.pink_noise_square_manual(len,klist,d_alph);
end

% theory
[f_z,z]=tinker.pink_noise_dist(dim,klist,d_alph);

% compare sampling vs theory
figure
histogram(img_ensemble(:),1000,'Normalization','pdf','EdgeColor','none'); hold on
plot(z,f_z,'r-'); hold off
legend('sampled','theory'); legend boxoff
set(gca,'fontsize',13)
box off
title 'distribution of 2D pink noise values'

%% 2D pink noise: autocorrelation

% ensemble sampling
d=0:len-2;
autocorrs=zeros(numel(d),numel(d),n_ensemble);
figure; hold on
for n=1:n_ensemble
    n
    for lag_x=d
        for lag_y=d
            corr1=img_ensemble(1:end-lag_x,1:end-lag_y,n);
            corr2=img_ensemble(1+lag_x:end,1+lag_y:end,n);
            corr=corrcoef(corr1(:),corr2(:));
            autocorrs(lag_x+1,lag_y+1,n)=corr(1,2);
        end
    end
    plot(d*kmin,autocorrs(1,:,n),'Color',[0 0 0 .1])
end
h_mean=plot(d*kmin,mean(autocorrs(1,:,:),3),'-k','LineWidth',1);

% analytical: discrete sum
r_num=zeros(size(d));
for k=klist
    r_num=r_num+besselj(0,k*d)/k^2;
end
r=r_num/sum(klist.^(-2));
h_anal_disc=plot(d*kmin,r,'r-','LineWidth',1);

% analytical: continuous integral from kmin to kmax
r_cont=(hypergeom(-1/2, [1/2 1], -d.^2*kmin^2/4)/kmin...
       -hypergeom(-1/2, [1/2 1], -d.^2*kmax^2/4)/kmax)/...
       (1/kmin-1/kmax);
h_anal_cont=plot(d*kmin,r_cont,'-b','LineWidth',1);

xlabel ('d (in units of \lambda_{max})')
ylabel('correlation coefficient r(d)')
set(gca,'fontsize',13)
legend([h_mean, h_anal_disc, h_anal_cont],{'sample mean (discrete)','analytical (discrete)','analytical (continuous)'});
legend boxoff

% plot sample mean autocorrelation in both x,y
autocorrs_mean=mean(autocorrs,3);
autocorrs_mean=[fliplr(autocorrs_mean), autocorrs_mean];
autocorrs_mean=[flipud(autocorrs_mean); autocorrs_mean];
figure; surf(autocorrs_mean,'LineStyle','none');
zlabel 'r(d)'
set(gca,'fontsize',13)