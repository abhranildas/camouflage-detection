% compute efficient-coding histogram bins of gradient magnitude,
% orientation and product, from natural image database

% parameters
% rng(123,'twister');
ppd=106;
m0 = 128; ntype = 3; c0 = 0.25; nbins = 16000;
mxval = 2^14-1; % CPS images are actually 14-bit, even though saved as 16-bit
thresh = 0; %200;
pad_val=128; % pad patches with this mean greylevel value when taking gradients

n_samp = 20;
patch_sz = 64;
num_scales=5;
kernel_sd_list=[1 2 4 8 16]; % steeerable kernel sd
kernel_sd_max=kernel_sd_list(end);
kernel_nsd=3;

max_filter_sz=size(lib.steerable_filter([kernel_sd_max kernel_nsd]),1); % maximum filter size
patch_extra_sz=patch_sz+2*floor(max_filter_sz/2); % extra overflow size for each image patch for filtering
% start and end indices of the larger patch, for the center part:
start_idx=floor((patch_extra_sz-patch_sz)/2)+1;
end_idx=start_idx+patch_sz-1;

% load the PCA coefficients
% load('vislab-common/data/nat_im_eff_coding.mat');

% image size, original and after gradient border crop
img_sz = [2844 4284];
img_sz_crop = img_sz-2*kernel_sd_max*kernel_nsd;

files=dir('vislab-common/data/CPS natural images/*.png');
n_files=10; %numel(files);
n_patches=n_files*n_samp;
num_el=n_files*n_samp*patch_sz^2; % no. of array elements to store

rgb=nan(num_el,3);
grey_values=nan([patch_sz patch_sz n_patches]);
% grad_x=nan([patch_sz patch_sz num_scales n_patches]);
% grad_y=nan([patch_sz patch_sz num_scales n_patches]);
grad=nan([patch_sz patch_sz 2 num_scales n_patches]);
grad_m=nan([patch_sz patch_sz num_scales n_patches]);
grad_o=nan([patch_sz patch_sz num_scales n_patches]);
grad_p=nan([patch_sz patch_sz num_scales n_patches]);

grad_pca=nan([patch_sz patch_sz 2 num_scales n_patches]);
grad_pca_m=nan([patch_sz patch_sz num_scales n_patches]);
grad_pca_o=nan([patch_sz patch_sz num_scales n_patches]);
grad_pca_p=nan([patch_sz patch_sz num_scales n_patches]);


% i_el=1; % current array element
i_patch=1;
for i_file=1:n_files
    fprintf('%d of %d\n', i_file, n_files);
    % load image
    name=['vislab-common/data/CPS natural images/' files(i_file).name];
    img_rgb=double(imread(name))*255/mxval;
    % make greyscale
    img_grey = mean(img_rgb,3);
    % apply OTF
    img_otf=vislab.lib.otf_filter(img_grey,ppd,4,555);


    % now sample patches
    for i_samp=1:n_samp
        % choose patch location
        patch_x = randi(img_sz_crop(1)-patch_extra_sz);
        patch_y = randi(img_sz_crop(2)-patch_extra_sz);

        % for RGB, select patch of patch_sz
        patch_rgb=img_rgb(patch_x:patch_x+patch_sz-1,patch_y:patch_y+patch_sz-1,:);                
        ptch_rgb = lib.ptch_norm(patch_rgb,m0,c0,ntype); % normalize means of each RGB channel        
        % rgb(i_el:i_el+patch_sz^2-1,:)=reshape(permute(ptch_rgb, [2, 1, 3]), [], 3); % store rgb values

        % for grey values, select patch of patch_sz
        patch_grey=img_otf(patch_x:patch_x+patch_sz-1,patch_y:patch_y+patch_sz-1,:);
        patch_grey=patch_grey/mean(patch_grey(:))*128; % scale patch to a mean of 128
        grey_values(:,:,i_patch)=patch_grey;

        % for gradient, choose larger patch for filter overflow
        patch_grey=img_otf(patch_x:patch_x+patch_extra_sz-1,patch_y:patch_y+patch_extra_sz-1,:);
        patch_grey=patch_grey/mean(patch_grey(:))*128; % scale patch to a mean of 128

        % compute patch gradients
        grad_raw_this=nan([patch_sz patch_sz 2 num_scales]);
        for i_scale=1:num_scales            
            kernel_size=[kernel_sd_list(i_scale) kernel_nsd];

            % compute gradient using raw steerable filter
            grad_this=lib.steerable_grad(patch_grey,'kernel_size',kernel_size);

            % OR compute gradient using custom PCA filter
            % pick out the x and y filters at this scale from the custom filter stack
            % filt=filters(:,:,[i_scale num_scales+i_scale]); 
            % grad_this=lib.steerable_grad(patch_grey,'filter',filt,'kernel_size',kernel_size);

            % crop out center part of this gradient, equal to patch_sz:
            grad_this=grad_this(start_idx:end_idx,start_idx:end_idx,:);

            grad_raw_this(:,:,1,i_scale)=grad_this(:,:,1);
            grad_raw_this(:,:,2,i_scale)=grad_this(:,:,2);

            % magnitude, orientation and product of gradients
            grad_m_this=squeeze(vecnorm(grad_this,2,3));
            grad_o_this=squeeze(cart2pol(grad_raw_this(:,:,1,i_scale),grad_raw_this(:,:,2,i_scale)));
            grad_p_this=grad_m_this.*grad_o_this;

            % threshold the pixels based on gradient magnitude
            % thresh_px=grad_m_this>thresh;

            grad_m(:,:,i_scale,i_patch)=grad_m_this;
            grad_o(:,:,i_scale,i_patch)=grad_o_this;
            grad_p(:,:,i_scale,i_patch)=grad_p_this;

        end

        grad(:,:,:,:,i_patch)=grad_raw_this;


        % compute and store PCA responses of the patch
        grad_raw_this_flat=reshape(permute(grad_raw_this,[1 2 4 3]),patch_sz^2,[]);
        grad_pca_this_flat=grad_raw_this_flat*pca_coeffs;
        grad_pca_this=reshape(grad_pca_this_flat,[patch_sz patch_sz 2 num_scales]);

        grad_pca(:,:,:,:,i_patch)=grad_pca_this;

        % magnitude, orientation and product of PCA gradients
        grad_pca_m_this=squeeze(vecnorm(grad_pca_this,2,3));
        grad_pca_o_this=squeeze(cart2pol(grad_pca_this(:,:,1,:),grad_pca_this(:,:,2,:)));
        grad_pca_p_this=grad_pca_m_this.*grad_pca_o_this;

        grad_pca_m(:,:,:,i_patch)=grad_pca_m_this;
        grad_pca_o(:,:,:,i_patch)=grad_pca_o_this;
        grad_pca_p(:,:,:,i_patch)=grad_pca_p_this;

        i_patch=i_patch+1;
    end
end

%% PCA of gradient filters
grad_flat=reshape(permute(grad,[1 2 5 4 3]),[],num_scales*2);  

[pca_coeffs,scores,~,~,explained]=pca(grad_flat);
figure
imagesc(pca_coeffs); colormap gray

% pca_responses=grad_flat*pca_coeffs;
pca_responses=reshape(permute(grad_pca,[1 2 5 4 3]),[],num_scales*2);  

% show correlations of raw and PCA filter responses
r_raw=corrcoef(grad_flat);
figure; imagesc(r_raw)
axis square
set(gca,'xtick',[],'ytick',[])
c=colorbarpzn(-1,1);
c.Ticks = [-1 0 1];
title 'corr. coeff. of raw filter responses'

r_pca=corrcoef(pca_responses);
figure; imagesc(r_pca)
axis square
set(gca,'xtick',[],'ytick',[])
c=colorbarpzn(-1,1);
c.Ticks = [-1 0 1];
title 'corr. coeff. of PCA filter responses'

% show histograms of PCA responses
% figure; sgtitle('PCA responses')
% for i_scale=1:2*num_scales
%     subplot(2*num_scales,1,i_scale)
%     histogram(scores(:,i_scale),'EdgeColor','none','Normalization','pdf')
%     xlim([-100 100])
%     set(gca,'ytick',[])
% end

%% histogram equalization (efficient coding bins)
n_bins_grad=[16 16 16 16 16];
n_bins_hist=16;
grey_hist_bins=[-inf quantile(grey_values(:),n_bins_hist-1) inf];

grad_m_flat=reshape(permute(grad_m,[1 2 4 3]),[],size(grad_m,3));
grad_o_flat=reshape(permute(grad_o,[1 2 4 3]),[],size(grad_m,3));
grad_p_flat=reshape(permute(grad_p,[1 2 4 3]),[],size(grad_m,3));

grad_pca_m_flat=reshape(permute(grad_pca_m,[1 2 4 3]),[],size(grad_m,3));
grad_pca_o_flat=reshape(permute(grad_pca_o,[1 2 4 3]),[],size(grad_m,3));
grad_pca_p_flat=reshape(permute(grad_pca_p,[1 2 4 3]),[],size(grad_m,3));

figure(4); sgtitle('gradient magnitude');
figure(5); sgtitle('gradient orientation');
figure(6); sgtitle('gradient product');
for i_scale=1:num_scales
    grad_m_bins(i_scale,:)=[-inf quantile(grad_m_flat(:,i_scale),n_bins_grad(i_scale)-1) inf];
    grad_o_bins(i_scale,:)=[-inf quantile(grad_o_flat(:,i_scale),n_bins_grad(i_scale)-1) inf];
    grad_p_bins(i_scale,:)=[-inf quantile(grad_p_flat(:,i_scale),n_bins_grad(i_scale)-1) inf];
    
    grad_pca_m_bins(i_scale,:)=[-inf quantile(grad_pca_m_flat(:,i_scale),n_bins_grad(i_scale)-1) inf];
    grad_pca_o_bins(i_scale,:)=[-inf quantile(grad_pca_o_flat(:,i_scale),n_bins_grad(i_scale)-1) inf];
    grad_pca_p_bins(i_scale,:)=[-inf quantile(grad_pca_p_flat(:,i_scale),n_bins_grad(i_scale)-1) inf];

    figure(4);
    subplot(num_scales,2,2*i_scale-1)
    histogram(grad_m_flat(:,i_scale),'EdgeColor','none','Normalization','pdf')
    xline(grad_m_bins(i_scale,:))
    xlim([0 grad_m_bins(i_scale,end-1)])

    subplot(num_scales,2,2*i_scale)
    histogram(grad_pca_m_flat(:,i_scale),'EdgeColor','none','Normalization','pdf')
    xline(grad_pca_m_bins(i_scale,:))
    xlim([0 grad_pca_m_bins(i_scale,end-1)])

    figure(5);
    subplot(num_scales,2,2*i_scale-1)
    histogram(grad_o_flat(:,i_scale),'EdgeColor','none','Normalization','pdf')
    xline(grad_o_bins(i_scale,:))
    xlim([-pi pi])

    subplot(num_scales,2,2*i_scale)
    histogram(grad_pca_o_flat(:,i_scale),'EdgeColor','none','Normalization','pdf')
    xline(grad_pca_o_bins(i_scale,:))
    xlim([-pi pi])

    figure(6);
    subplot(num_scales,2,2*i_scale-1)
    histogram(grad_p_flat(:,i_scale),'EdgeColor','none','Normalization','pdf')
    xline(grad_p_bins(i_scale,:))
    xlim(grad_p_bins(i_scale,[2 end-1]))

    subplot(num_scales,2,2*i_scale)
    histogram(grad_pca_p_flat(:,i_scale),'EdgeColor','none','Normalization','pdf')
    xline(grad_pca_p_bins(i_scale,:))
    xlim(grad_pca_p_bins(i_scale,[2 end-1]))

end

%% save efficient-coding bins and PCA coeffs and filters
save('vislab-common/data/nat_im_eff_coding.mat','grey_hist_bins',...
    'grad_m_bins','grad_o_bins','grad_p_bins',...
    'grad_pca_m_bins','grad_pca_o_bins','grad_pca_p_bins',...
    'pca_coeffs')

%% compute PCA filters
% (these are not truly PCA filters, since due to the normalization by SD, it's not a linear operation)

% stack all the raw steerable filters
x_filters=nan([max_filter_sz max_filter_sz num_scales]);
y_filters=nan([max_filter_sz max_filter_sz num_scales]);
for i_scale=1:num_scales
    filt=lib.steerable_filter([kernel_sd_list(i_scale) kernel_nsd]);
    padsize=(max_filter_sz-size(filt,1))/2;
    filt=padarray(filt,[padsize,padsize], 0, 'both');
    x_filters(:,:,i_scale)=filt(:,:,1);
    y_filters(:,:,i_scale)=filt(:,:,2);
end
filters=cat(3,x_filters,y_filters);

% compute PCA filters
filters_flat=reshape(filters,[],size(filters,3));
filters_pca_flat=filters_flat*pca_coeffs;
filters_pca=reshape(filters_pca_flat,size(filters));

% flip and re-order some of them as needed
filters_pca=filters_pca(:,:,[10 8 6 4 2 9 7 5 3 1]);
filters_pca(:,:,2)=-filters_pca(:,:,2);
filters_pca(:,:,3)=-filters_pca(:,:,3);
filters_pca(:,:,7)=-filters_pca(:,:,7);
filters_pca(:,:,8)=-filters_pca(:,:,8);

% filters_pca=nan([max_filter_sz max_filter_sz 2*num_scales]);
figure
for i_scale=1:2*num_scales
    % filters_pca(:,:,i_scale)=sum(filters.*reshape(pca_coeffs(:,i_scale),[1 1 10]),3);
    subplot(2*num_scales,1,i_scale); imagesc(filters_pca(:,:,i_scale));
    axis square
    colormap gray
    set(gca,'xtick',[],'ytick',[])
end


%% PCA of RGB
% PCA to get transformation matrix
coeff = pca(rgb);

% transform from rgb to abr
abr=rgb*coeff;

% cumulative channel responses
[Na,ea] = histcounts(abr(:,1),nbins,'Normalization','cdf');
[Nb,eb] = histcounts(abr(:,2),nbins,'Normalization','cdf');
[Nr,er] = histcounts(abr(:,3),nbins,'Normalization','cdf');

% NEEDS TO BE REWRITTEN NOW THAT GM ETC HAVE 5 SCALES
% save("cdfs.mat","ea","Na","eb","Nb","er","Nr","egm","Ngm","coeff");

% plot RGB histograms
figure;
subplot(3,1,1);
histogram(rgb(:,1),FaceColor='red',EdgeColor = 'none');
axis([0 255 0 inf]);
title 'red'
subplot(3,1,2);
histogram(rgb(:,2),FaceColor='green',EdgeColor = 'none');
axis([0 255 0 inf]);
title 'green'
subplot(3,1,3);
histogram(rgb(:,3),FaceColor = 'blue',EdgeColor = 'none');
axis([0 255 0 inf]);
title 'blue'

% plot ABR histograms
figure;
subplot(3,1,1);
histogram(abr(:,1),FaceColor='black',EdgeColor='none');
axis([0 511 0 inf]);
title 'A'
subplot(3,1,2);
histogram(abr(:,2),FaceColor='blue',EdgeColor='none');
axis([-128 128 0 inf]);
title 'B'
subplot(3,1,3);
histogram(abr(:,3),FaceColor = 'red',EdgeColor = 'none');
axis([-128 128 0 inf]);
title 'R'


% plot gradient histograms
figure;
subplot(3,1,1);
histogram(grad_m,EdgeColor='none');
xline(grad_m_bins)
title 'grad magnitude'
subplot(3,1,2);
histogram(grad_o,EdgeColor='none');
xline(grad_o_bins)
xlim([-pi pi]);
title 'grad orientation'
subplot(3,1,3);
histogram(grad_p,EdgeColor='none');
xline(grad_p_bins)
title 'grad product'


% illustrate histogram equalization
figure; hold on
plot(ea(1:end-1),Na,'-r')
axis([0 500 0 1.02])
cdf_array=linspace(0,1,15);
for i=1:numel(cdf_array)
    idx=find(Na>cdf_array(i),1);
    plot([ea(idx) ea(idx)],[0 Na(idx)],'-k')
    plot([0 ea(idx)],[Na(idx) Na(idx)],'-k')
end
xlabel('$x$','Interpreter','latex')
ylabel cdf
set(gca,'xtick',[],'ytick',[0 1],'fontsize',13)