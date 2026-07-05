function img_temp=mismatch_template(bg_size,target_radius,k_idx,phi_b,phi_t)
% creates the template that's created by whitening a target and background
% consisting a single plane wave of the same frequency, but different
% phases.

% background
y_k_b=zeros(1,bg_size-1);
y_k_b(k_idx)=exp(1i*phi_b);
y_k_b(end-k_idx+1)=exp(-1i*phi_b);
y_k_b=[0,y_k_b];

img_k_b=zeros(bg_size);
img_k_b(1,:)=y_k_b;
img_b=ifft2(img_k_b);

% target
y_k_t=zeros(1,bg_size-1);
y_k_t(k_idx)=exp(1i*phi_t);
y_k_t(end-k_idx+1)=exp(-1i*phi_t);
y_k_t=[0,y_k_t];

img_k_t=zeros(bg_size);
img_k_t(1,:)=y_k_t;
img_t=ifft2(img_k_t);

mask=lib.circular_mask(bg_size,target_radius);

img=img_b;
img(mask)=img_t(mask);

img_b_whitened=lib.whiten_pink_noise_square(img_b);
img_t_whitened=lib.whiten_pink_noise_square(img_t);
img_b_t_whitened=img_b_whitened;
img_b_t_whitened(mask)=img_t_whitened(mask);

img_whitened=lib.whiten_pink_noise_square(img);
img_temp=img_whitened-img_b_t_whitened;