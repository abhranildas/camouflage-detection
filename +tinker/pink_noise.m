%% 2D pink noise

bg_size=200;
fil1f = zeros(bg_size);
for n=1:bg_size
    for j=1:bg_size
        z=norm([n-bg_size/2-1,j-bg_size/2-1]);
        if z  % leave fft origin at 0
            fil1f(n,j) = 1/z;
        end
    end
end
% white noise image:
wn = normrnd(0,1,bg_size);

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
img_1f_manual=zeros(bg_size);

figure;
subplot(1,2,1);
imagesc(img_1f); colormap gray; axis image;

subplot(1,2,2);
for u=1:bg_size
    u
    imagesc(img_1f_manual); colormap gray; axis image; drawnow
    for v=1:bg_size
        cos_amp=real(wnf(u,v));
        sin_amp=imag(wnf(u,v));
        for n=1:bg_size
            for j=1:bg_size
                img_1f_manual(n,j)=img_1f_manual(n,j)+...
                    cos_amp*cos(2*pi/bg_size*((u-1)*j+(v-1)*n))+...
                    sin_amp*sin(2*pi/bg_size*((u-1)*j+(v-1)*n));
            end
        end
    end
end

%% Verify convolution theorem
img=colored_noise(1000,2,-1);
img_f=fft2(img);
img_corr=xcorr2(img);

img_corr_f=fft2(img_corr);
figure; surf(abs(fftshift(img_corr_f)));

img_f_2=abs(img_f).^2;
figure; surf(abs(fftshift(img_f_2)));


[Zr, R] = lib.radialavg(img_corr,100);
figure;
plot(log(R),log(Zr))

%% 1D pink noise: distribution
dim=1;
N=1e3;
log_kmin=-2;
log_kmax=2;
d_logk=.01;
klist=10.^(log_kmin:d_logk:log_kmax);
kmin=10^log_kmin; kmax=10^log_kmax;
n_ensemble=1e2;

% ensemble sampling
pink_noise_1d=zeros(n_ensemble,N);
for n=1:n_ensemble
    r_num=tinker.pink_noise_1D(N,klist);
    pink_noise_1d(n,:)=r_num;
end

% theory
[f_z,z]=tinker.pink_noise_dist(dim,klist);

% compare sampling vs theory
figure
histogram(pink_noise_1d(:),1000,'Normalization','pdf','EdgeColor','none'); hold on
plot(z,f_z,'r-','LineWidth',1); hold off

legend('sampled','theory');
legend boxoff
set(gca,'fontsize',13)

%% 1D pink noise: autocorrelation

% ensemble sampling
d=0:N-2;
autocorrs=zeros(n_ensemble,numel(d));
figure; hold on
for n=1:n_ensemble
    for lag=d
        corr=corrcoef(pink_noise_1d(n,1:end-lag),pink_noise_1d(n,1+lag:end));
        autocorrs(n,lag+1)=corr(1,2);
    end
    %autocorrs(n,:)=autocorr(ys(n,:),'NumLags',len-2);
    plot(d*kmin,autocorrs(n,:),'Color',[0 0 0 .01])
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
N=100;
log_kmin=-1;
log_kmax=1;
d_logk=.1;
klist=10.^(log_kmin:d_logk:log_kmax);
kmin=10^log_kmin; kmax=10^log_kmax;
d_alph=.1; % spacing of component wave orientations

% ensemble sampling
img_ensemble=zeros(N,N,n_ensemble);
for n=1:n_ensemble
    n
    img_ensemble(:,:,n)=tinker.pink_noise_square_manual(N,klist,d_alph);
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
d=0:N-2;
autocorrs=zeros(numel(d),numel(d),n_ensemble);
figure; hold on
for n=1:n_ensemble
    n
    for lag_x=d
        for shift_y=d
            corr1=img_ensemble(1:end-lag_x,1:end-shift_y,n);
            corr2=img_ensemble(1+lag_x:end,1+shift_y:end,n);
            corr=corrcoef(corr1(:),corr2(:));
            autocorrs(lag_x+1,shift_y+1,n)=corr(1,2);
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

%% check pink noise point value distribution parameters
pink_noise_sample=lib.create_pink_noise_line(1e4,1);
var(pink_noise_sample)

%% 1D pink noise: autocorrelation (corrected)

N=5e3;
n_ensemble=500;

% generate pink noise
pink_noise_1d=zeros(n_ensemble,N);
for n=1:n_ensemble
    pink_noise_sample=lib.create_pink_noise_line(N,1);
    pink_noise_1d(n,:)=pink_noise_sample;
end

% autocorrelation coefficient
d=0:N-2;
autocorrs=zeros(n_ensemble,numel(d));

for n=1:n_ensemble
    for lag=d
        corr=corrcoef(pink_noise_1d(n,:),circshift(pink_noise_1d(n,:),-lag));
        autocorrs(n,lag+1)=corr(1,2);
    end
    %autocorrs(n,:)=autocorr(ys(n,:),'NumLags',len-2);
end

figure; hold on
h_samp=plot(d/N,autocorrs(n,:),'Color',[0 0 0 .1]);
for n=2:10
    plot(d/N,autocorrs(n,:),'Color',[0 0 0 .1])
end

h_mean=plot(d/N,mean(autocorrs),'-k','LineWidth',1);

% analytical: discrete sum
r_num=zeros(size(d));
klist=1:N/2;
for k=klist
    r_num=r_num+cos(2*pi*k*d/N)/k;
end

r=r_num/sum(1./klist);

h_anal_disc=plot(d/N,r,'r-','LineWidth',1);

% analytical: continuous integral from kmin to kmax
r_cont=(cosint(2*pi*d*max(klist)/N)-cosint(2*pi*d*min(klist)/N))/log(max(klist)/min(klist));
r_cont(1)=1;
h_anal_cont=plot(d/N,r_cont,'-b','LineWidth',1);

xlim([-.01 .5]); ylim([-.4 1.1])
xlabel ('d (in units of longest wavelength)')
ylabel('autocorrelation coefficient r(d)')
set(gca,'fontsize',13)
legend([h_samp, h_mean, h_anal_disc, h_anal_cont],{'sample','sample mean','theory','theory (continuous frequencies)'});
legend boxoff

%% 2D pink noise: autocorrelation (corrected)

N=1e2;
n_ensemble=100;

% autocorrelation coefficient
autocorrs=nan(N,N,n_ensemble);

parfor n=1:n_ensemble
    n
    pink_noise_2d=colored_noise(N,2,-1);
    % compute autocorr by squaring the FFT
    autocorr=ifft2(abs(fft2(pink_noise_2d)).^2);
    autocorr=fftshift(autocorr/autocorr(1,1));
    autocorrs(:,:,n)=autocorr;
end

mean_autocorr=mean(autocorrs,3);
surf(mean_autocorr,'edgecolor','none');

% theoretical 2d autocorr
[u,v]=meshgrid(1:N/2);
[x,y]=meshgrid(-N/2:N/2);

autocorr_theo=nan(size(x));
for row=1:size(autocorr_theo,1)
    for col=1:size(autocorr_theo,2)
        [row, col]
        autocorr_theo(row,col)=sum(sum(cos(u*x(row,col)+v*y(row,col))./(u.^2+v.^2)));
    end
end

figure;
surf(autocorr_theo,'edgecolor','none');

autocorr=lib.radialavg(autocorr,N/2+1);
autocorrs(n,:)=autocorr(2:end)/autocorr(2);

d=0:N/2-1;
figure; hold on
h_samp=plot(d/N,autocorrs(1,:),'Color',[0 0 0 .1]);
for n=2:n_ensemble
    plot(d/N,autocorrs(n,:),'Color',[0 0 0 .1])
end

mean_autocorr=mean(autocorrs,1);
h_mean=plot(d/N,mean_autocorr,'-k','LineWidth',1);

% analytical: discrete sum
r_num=zeros(size(d));
klist=1:N/2;
for k=klist
    r_num=r_num+besselj(0,2*pi*k*d/N)/k;
end

r=r_num/sum(klist.^(-1));

h_anal_disc=plot(d/N,r,'r-','LineWidth',1);

% analytical: continuous integral from kmin to kmax
% r_cont=(hypergeom(-1/2, [1/2 1], -d.^2*pi^2*min(klist)^2/N^2)/min(klist)...
%     -hypergeom(-1/2, [1/2 1], -d.^2*pi^2*max(klist)^2/N^2)/max(klist))/...
%     (1/min(klist)-1/max(klist));
% h_anal_cont=plot(d/N,r_cont,'-b','LineWidth',1);

xlim([-.01 .5]); ylim([-.4 1.1])
xlabel ('d (in units of longest wavelength)')
ylabel('autocorrelation coefficient r(d)')
set(gca,'fontsize',13)
legend([h_samp, h_mean, h_anal_disc],{'sample','sample mean','theory'});
legend boxoff

%% properties of Bessel J
x=linspace(-100,100,1e3);
f1=cos(x);
f2=besselj(0,x);
figure; hold on
plot(x,f1)
plot(x,f2)

%% test properties of filtered noise

wn=normrnd(0,1,100);
wn_f=fft2(wn);
wn_amp=abs(wn_f);
% histogram(wn_amp.^2);
hold off
histogram(real(wn_f))
hold on
histogram(imag(wn_f))
[var(real(wn_f(:))) var(imag(wn_f(:)))]