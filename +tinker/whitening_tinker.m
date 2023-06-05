len=100;
fil_whiten=[1 1:len/2 len/2-1: -1:1]; % whitening filter
fil_pinken=1./fil_whiten;  % pinkening filter

%y=[normrnd(0,1,[1 len/2]),zeros(1,len/2)];
x_white_noise=normrnd(0,1,[1 len]);

% x_white_noise_left=x_white_noise;
% x_white_noise_left(len/2+1:end)=0;
% 
% x_white_noise_right=x_white_noise;
% x_white_noise_right(1:len/2)=0;

x_delta=[1,zeros(1,len-1)];

x_pink_irf=tinker.filter(x_delta,fil_pinken);
x_white_irf=tinker.filter(x_delta,fil_whiten);

x_pink_noise=tinker.filter(x_white_noise,fil_pinken);

% x_pink_noise_left=x_pink_noise;
% x_pink_noise_left(len/2+1:end)=0;
% 
% x_pink_noise_right=x_pink_noise;
% x_pink_noise_right(1:len/2)=0;
% 
% x_whitened_left=tinker.filter(x_pink_noise_left,fil_whiten);
% x_whitened_right=tinker.filter(x_pink_noise_right,fil_whiten);

x_whitened=tinker.filter(x_pink_noise,fil_whiten);

% analytical result
x_irf_anal=zeros(1,len);
k=1:len/2;
for n=1:len
    x_irf_anal(n)=(1+2*(-1)^n/len+sum(2*cos(2*(n-1)*k*pi/len)./k))/len;
end

figure(1)
stem(x_delta);
figure(2)
plot(x_pink_irf);
hold on
plot(x_irf_anal);
hold off;

crop_mask=[ones(1,len/2) zeros(1,len/2)];

%% pinkening IRF (corrected)
len=5e3;

% create 1/sqrt(f) Fourier filter.
fil_1f = ones(1,len);
for i=1:len
    z=sqrt(norm(i-len/2-1));
    if z  % leave fft origin at 1
        fil_1f(i) = z^(-1);
    end
end

% delta function:
delta=[1,zeros(1,len-1)];

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
delta_f = fftshift(fft(delta));

% multiply with 1/f filter
delta_f_fil = fil_1f.*delta_f;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
pinken_irf = ifft(ifftshift(delta_f_fil));

figure; hold on
stem(fftshift(delta),'marker','none','color','k');
plot(fftshift(pinken_irf),'b')
xlim(251+150*[-1 1]); ylim([0 .15])
set(gca,'xtick',[101 251 401],'xticklabels',{'-150','0','150'},'ytick',[0 .15],'fontsize',13)

%% whitening IRF (corrected)
len=500;

% create sqrt(f) Fourier filter.
fil_1f = ones(1,len);
for i=1:len
    z=sqrt(norm(i-len/2-1));
    if z  % leave fft origin at 1
        fil_1f(i) = z;
    end
end

% delta function:
delta=[1,zeros(1,len-1)];

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
delta_f = fftshift(fft(delta));

% multiply with 1/f filter
delta_f_fil = fil_1f.*delta_f;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
whiten_irf = ifft(ifftshift(delta_f_fil));

figure; hold on
stem(fftshift(delta),'marker','none','color','k');
plot(fftshift(whiten_irf),'b')
xlim(251+10*[-1 1]); ylim([-3 12])
set(gca,'xtick',[241 251 261],'xticklabels',{'-10','0','10'},'ytick',[0 10],'fontsize',13)

%% checking theoretical form of pinkening IRF
N=100;
x=1:N;
delta=[1,zeros(1,N-1)];
delta_f=fft(delta);

fil_1f = ones(1,N);
for i=1:N
    z=sqrt(norm(i-N/2-1));
    if z  % leave fft origin at 1
        fil_1f(i) = 1/z;
    end
end

a=fftshift(fil_1f);
delta_f=delta_f.*a;
f_numeric=ifft(delta_f);

% f=cos(0*x*2*pi/N);
% f=exp(1i*0*x*2*pi/N);
f=1+cos(pi*(x-1))/sqrt(N/2);
for k=1:N/2-1
    f=f+2*cos(2*pi*k*(x-1)/N)/sqrt(k);
%     f=f+exp(1i*(k-1)*x*2*pi/N);
end
f=f/N;

figure; plot(f_numeric); hold on; plot(f,'o');
[sum(f) sum(f.^2)]

%% continuous analytical whitening filter
k_max=2;
x=-10:.01:10;
f=(exp(-2*pi*1i*k_max*x).*(1+2*pi*1i*k_max*x)-1)./(4*pi^2*x.^2);
plot(f)

%% whitening a sine
k_idx=1; % index of the sinusoid frequency
phi=0; % phase of the sinusoid

y_k=zeros(1,len-1);
y_k(k_idx)=exp(1i*phi);
y_k(end-k_idx+1)=exp(-1i*phi);
y_k=[0,y_k];
%y_x=ifft(y_k);

%plot(y_x)
%y_whitened=cconv(y_x,x_whiten_one_irf,length(y_x));
%hold on; plot(y_whitened); hold off

%% whitening a single plane wave mismatch stimulus.
bg_size=256;
target_radius=64;
ml=.5;
cont=.15;

k_idx=1; % index of the sinusoid frequency
phi_b=.5; % phase of the sinusoid
phi_t=.7; % phase of the sinusoid

img_temp=lib.mismatch_template(bg_size,target_radius,k_idx,phi_b,phi_t);
figure; imagesc(img_temp); axis square; colormap gray; set(gca,'xtick',[]); set(gca,'ytick',[]);

%% matched mismatch-template detector
texture_params.type='pink_noise';

n_samp=1e2;
temp_response=nan(n_samp,3);

parfor seed=1:n_samp
    seed    
    % blank
    img_pink_b=lib.stimulus(texture_params,seed,bg_size,0,'center',0,ml,cont,'match','match');
    img_whitened_b=lib.whiten_pink_noise_square(img_pink_b);    
    
    % target
    img_pink_t=lib.stimulus(texture_params,seed,bg_size,target_radius,'center',0,ml,cont,'match','match');
    img_whitened_t=lib.whiten_pink_noise_square(img_pink_t);   

    temp_response(seed,:)=[seed dot(img_temp(:),img_whitened_b(:)) dot(img_temp(:),img_whitened_t(:))];
end

%% whitening one frequency component

% 1-frequency whitening filter
k_idx=3; % index of the frequency
fil_whiten_one=ones(1,len);
fil_whiten_one(k_idx+1)=k_idx;
fil_whiten_one(end-k_idx+1)=k_idx;

% IRF
x_whiten_one_irf=tinker.filter(x_delta,fil_whiten_one);

x_white_noise_left=normrnd(0,1,[1 len]);
x_pink_noise_left=tinker.filter(x_white_noise_left,fil_pinken);

x_white_noise_right=normrnd(0,1,[1 len]);
x_pink_noise_right=tinker.filter(x_white_noise_right,fil_pinken);

x_white_noise=[x_white_noise_left(1:len/2),x_white_noise_right(len/2+1:end)];

x_pink_noise=[x_pink_noise_left(1:len/2) x_pink_noise_right(len/2+1:end)];

subplot(3,1,1)
plot(x_pink_noise)

x_whitened=tinker.filter(x_pink_noise,fil_whiten);

subplot(3,1,2)
plot(x_white_noise);
hold on
plot(x_whitened);
hold off

subplot(3,1,3)
plot(x_whitened-x_white_noise);


x_whitened_one=cconv(x_pink_noise,x_whiten_one_irf,length(x_pink_noise));
hold on;
plot(x_whitened_one)
figure
plot(x_whitened_one-x_pink_noise)
%% examples of whitened stimuli
x_white_noise_left=normrnd(0,1,[1 len]);
x_pink_noise_left=tinker.filter(x_white_noise_left,fil_pinken);

x_white_noise_right=normrnd(0,1,[1 len]);
x_pink_noise_right=tinker.filter(x_white_noise_right,fil_pinken);

x_pink_noise_stim=[x_pink_noise_left(1:len/2) x_pink_noise_right(len/2+1:end)];

plot(x_pink_noise_stim); hold on;
x_whitened_stim=tinker.filter(x_pink_noise_stim,fil_whiten);
plot(x_whitened_stim); hold off;

%% whitening edges between all phase pairs
len=100;
k=1;
x=1:len/2;
n_phases=10;
plot_idx=1;

figure;
for phase_a=linspace(0,2*pi,n_phases)
    for phase_b=linspace(0,2*pi,n_phases)
        f_a=sin(k*x+phase_a);
        f_b=sin(k*x+phase_b);
        f=[f_a,f_b];
        f_whitened=cconv(f,x_white_irf,len);
        subplot(n_phases,n_phases,plot_idx)
        plot(f,'Color',[.5 .5 .5])
        hold on
        plot(f_whitened-len*k*f/(2*pi),'b')        
        ylim([-2 2])
        xlim([30 70])
        %plot([50 50],ylim,'k')
        hold off
        set(gca,'xtick',[])
        set(gca,'ytick',[])   
        axis off
        %title(sprintf('%d %d',round(rad2deg([phase_a+k*len/2,phase_b]))))
        plot_idx=plot_idx+1;
    end
end
