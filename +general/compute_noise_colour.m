addpath(genpath('por_sim_tx_synth'))
input_img='vislab_data/bark.png';
im0=double(im2gray(imread(input_img)));
Nsc = 4; % Number of scales
Nor = 4; % Number of orientations
Na = 9;  % Spatial neighborhood is Na x Na coefficients
Niter = 25;	% Number of iterations of synthesis loop
texture=struct;
texture.type='por_sim';
texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
texture.Niter=Niter;

% texture.type='pink_noise';
% texture.alpha=8;

bg_size=256;
n_samp=10;
n_ang=20;

%% estimate noise alpha exponent

stim_f=nan(bg_size,bg_size,n_samp);
tic
parfor i=1:n_samp
    i
    stim=lib.stimulus('texture',texture);
    stim_f(:,:,i)=fft2(stim);
end
toc

mean_f=fftshift(mean(abs(stim_f),3));

figure
subplot(2,1,1);
imagesc(log(mean_f)); axis square

u=-bg_size/2+1:bg_size/2;
v=u';
k=sqrt(u.^2+v.^2);

x=log(k(k~=0)); y=log(mean_f(k~=0));
subplot(2,1,2); plot(x,y,'.')
p=polyfit(x,y,1);
lsline
alpha=abs(p(1));
title(alpha)

% separate by orientation
figure
th=atan(u./v);
[~,~,th_bin]=histcounts(th(:),n_ang);
th_bin=reshape(th_bin,[256 256]);
alpha_ang=nan(1,n_ang);
for i=1:n_ang
    f_slice=log(mean_f);
    f_slice(th_bin~=i)=nan;
    subplot(2,1,1);
    imagesc(f_slice); axis square

    x=log(k(k~=0 & th_bin==i)); y=log(mean_f(k~=0 & th_bin==i));
    subplot(2,1,2); plot(x,y,'.')
    p=polyfit(x,y,1);
    lsline
    alpha_ang(i)=p(1);
    title(alpha_ang(i))
    pause
end
alpha=max(abs(alpha_ang));

alphas=[alphas;alpha]

%% estimate correlation length

c_size=2*bg_size-1;
x=linspace(-c_size/2,c_size/2,c_size);
y=x';
[th,d]=cart2pol(x,y);
% d=sqrt(x.^2+y.^2);

tic
parfor i=1:n_samp
    stim=lib.stimulus('texture',texture,'bg_size',bg_size);
    c=xcorr2(stim);
    c=c/max(c(:));
    c=c>exp(-1);
    F=scatteredInterpolant(c(:),th(:),d(:));
    plot(F(zeros([1 100]), linspace(0,10,100)))
end
toc

figure(1)
subplot(2,1,1);
imagesc(log(mean_f)); axis square


x=log(k(k~=0)); y=log(mean_f(k~=0));
subplot(2,1,2); plot(x,y,'.')
p=polyfit(x,y,1);
lsline
alpha=abs(p(1));
title(alpha)

% % separate by orientation
% figure(2)
% th=atan(u./v);
% [~,~,th_bin]=histcounts(th(:),n_ang);
% th_bin=reshape(th_bin,[256 256]);
% alpha_ang=nan(1,n_ang);
% for i=1:n_ang
%     f_slice=log(mean_f);
%     f_slice(th_bin~=i)=nan;
%     subplot(2,1,1);
%     imagesc(f_slice); axis square
% 
%     x=log(k(k~=0 & th_bin==i)); y=log(mean_f(k~=0 & th_bin==i));
%     subplot(2,1,2); plot(x,y,'.')
%     p=polyfit(x,y,1);
%     lsline
%     alpha_ang(i)=p(1);
%     title(alpha_ang(i))
%     pause
% end
% alpha=max(abs(alpha_ang));

alphas=[alphas;alpha]
