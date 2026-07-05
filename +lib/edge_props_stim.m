function [grad_m_llr_1,grad_m_llr_2,grad_m_llr_4,grad_m_llr_8,grad_m_llr_16,...
    grad_o_llr_1,grad_o_llr_2,grad_o_llr_4,grad_o_llr_8,grad_o_llr_16,...
    grad_p_llr_1,grad_p_llr_2,grad_p_llr_4,grad_p_llr_8,grad_p_llr_16,...
    npix_llr,ncon_llr,len_llr,len_sum,...
    pos_llr,pos_sum,or_llr,or_sum,curv_llr,curv_sum,...
    ep1_llr,ep2_llr,ep4_llr,ep8_llr,ep16_llr]=edge_props_stim(stim_raw,varargin)

%% parse inputs
parser=inputParser;
parser.KeepUnmatched=true;
addRequired(parser,'stim_raw', @isnumeric);
addParameter(parser,'stim_type','camo', @(x) strcmpi(x,'camo') || strcmpi(x,'tex'));
addParameter(parser,'otf_ppd',0,@isnumeric); % if 0, don't OTF filter
addParameter(parser,'grad_hist_thresh',0, @isnumeric);
addParameter(parser,'pca_coeffs',[], @isnumeric);
addParameter(parser,'grad_mag_bins',[], @isnumeric);
addParameter(parser,'grad_or_bins',[], @isnumeric);
addParameter(parser,'grad_prod_bins',[], @isnumeric);
addParameter(parser,'nbins_grad_or',16, @isnumeric);
addParameter(parser,'edge_pixels',[], @(x)isa(x,'single'));
[~,~,target_normal,bd_strip,~,~]=lib.target_mask();
bd_strip_rep=repmat(bd_strip,[1 1 2]);
addParameter(parser,'target_normal',target_normal, @isnumeric);

parse(parser,stim_raw,varargin{:});
stim_raw=parser.Results.stim_raw;
stim_type=parser.Results.stim_type;
otf_ppd=parser.Results.otf_ppd;

randi(10)

% tiny offset number to get avoid log(LLR)=-inf when LLR=0 (equally likely that same/diff),
% or to set 0*log(0)=0, instead of nan (when there are no texture contours in camo):
epsl=1e-10;

% filter with OTF:
if otf_ppd
    if strcmpi(stim_type,'camo')
        stim=vislab.lib.otf_filter(stim_raw,otf_ppd);
    elseif strcmpi(stim_type,'tex')
        stim(:,:,1)=vislab.lib.otf_filter(stim_raw(:,:,1),otf_ppd);
        stim(:,:,2)=vislab.lib.otf_filter(stim_raw(:,:,2),otf_ppd);
    end
else
    stim=stim_raw;
end
stim_sz=size(stim,1);

grad_hist_thresh=parser.Results.grad_hist_thresh;
pca_coeffs=parser.Results.pca_coeffs;
grad_m_bins=parser.Results.grad_mag_bins;
% grad_mag_bins(:,1)=grad_hist_thresh;
grad_o_bins=parser.Results.grad_or_bins;
grad_p_bins=parser.Results.grad_prod_bins;

% compute gradients at different scales

kernel_sd_list=[1 2 4 8 16]; % steeerable kernel sd
num_scales=5;
kernel_nsd=3;

if strcmpi(stim_type,'camo')
    N_a=nnz(bd_strip);
    N_b=nnz(~bd_strip);

    stim_rep=repmat(stim,3); % tile the stim (to prevent issues at the margins)
elseif strcmpi(stim_type,'tex')
    N_a=stim_sz^2;
    N_b=stim_sz^2;
    % grad_mag_bins{5}=[-inf inf];
    % grad_or_bins{5}=[-inf inf];
    % grad_prod_bins{5}=[-inf inf];
end

% grads=nan([stim_sz stim_sz 2 num_scales 2]); % the last 2 is for region a and b
% for i_scale=1:num_scales
%     kernel_sd=kernel_sd_list(i_scale);
%     if strcmpi(stim_type,'camo')
%         grad=lib.steerable_grad(stim_rep,'kernel_size',[kernel_sd kernel_nsd]);
%         % crop the gradient back to the original stim size:
%         grad_crop=grad(stim_sz+1:2*stim_sz,stim_sz+1:2*stim_sz,:,:);
% 
%         % separate boundary and texture regions:
%         grad_bd=grad_crop;
%         grad_bd(~bd_strip_rep)=nan;
%         grads(:,:,:,i_scale,1)=grad_bd;
%         grad_tx=grad_crop;
%         grad_tx(bd_strip_rep)=nan;
%         grads(:,:,:,i_scale,2)=grad_tx;
%     elseif strcmpi(stim_type,'tex')
%         grads(:,:,:,i_scale,1)=lib.steerable_grad(stim(:,:,1),'kernel_size',[kernel_sd kernel_nsd],varargin{:});
%         grads(:,:,:,i_scale,2)=lib.steerable_grad(stim(:,:,2),'kernel_size',[kernel_sd kernel_nsd],varargin{:});
%     end
% end

grads=nan([stim_sz stim_sz 2 num_scales]); % the last 2 is for region a and b
for i_scale=1:num_scales
    kernel_sd=kernel_sd_list(i_scale);
    if strcmpi(stim_type,'camo')
        grad=lib.steerable_grad(stim_rep,'kernel_size',[kernel_sd kernel_nsd],'normalize',false);
        % crop the gradient back to the original stim size:
        grad_crop=grad(stim_sz+1:2*stim_sz,stim_sz+1:2*stim_sz,:,:);

        grads(:,:,:,i_scale)=grad_crop;
    elseif strcmpi(stim_type,'tex')
        grads(:,:,:,i_scale,1)=lib.steerable_grad(stim(:,:,1),'kernel_size',[kernel_sd kernel_nsd],varargin{:});
        grads(:,:,:,i_scale,2)=lib.steerable_grad(stim(:,:,2),'kernel_size',[kernel_sd kernel_nsd],varargin{:});
    end
end

% apply PCA rotation to gradients
% if ~isempty(pca_coeffs)
%     grads_flat=reshape(permute(grads,[1 2 5 4 3]),stim_sz^2*2,[]);
%     grads_pca_flat=grads_flat*pca_coeffs;
%     grads_pca=permute(reshape(grads_pca_flat,[stim_sz stim_sz 2 2 num_scales]),[1 2 4 5 3]);
%     % grads_pca=permute(grads_pca,[1 2 4 5 3]);
%     grads=grads_pca;
% end

% apply PCA rotation to gradients
if ~isempty(pca_coeffs)
    % 1) Permute so that the "10" feature‑dimension (2 axes × 5 scales) is contiguous and in the order that matches the PCA rows:
    grads_flat = permute(grads, [1 2 4 3]);
    % 2) Collapse the spatial dims into one, and the feature dims into the other:
    grads_flat = reshape(grads_flat, [], 10);
    % 3) Multiply by the PCA coefficient matrix (rows correspond 1→10 as: x‑scale1→5, y‑scale1→5):
    grads_pca_flat = grads_flat * pca_coeffs;
    % 4) Un‑flatten and undo the permute:
    grads_pca = reshape(grads_pca_flat, [256,256,5,2]); 
    grads_pca = ipermute(grads_pca, [1 2 4 3]); 
end


% if ~isempty(pca_coeffs)
%     grads_flat=reshape(grads,stim_sz^2,2*num_scales);
%     grads_pca_flat=grads_flat*pca_coeffs;
%     grads_pca=reshape(grads_pca_flat,[stim_sz stim_sz num_scales 2]);
%     % grads=grads_pca;
% end


% compute gradient magnitude, orientation and product
grad_mags=squeeze(vecnorm(grads,2,3));
grad_ors=squeeze(cart2pol(grads(:,:,1,:,:),grads(:,:,2,:,:)));
grad_prods=grad_mags.*grad_ors;

%% gradient histograms
grad_m_llr=nan(num_scales,1);
grad_o_llr=nan(num_scales,1);
grad_p_llr=nan(num_scales,1);

figure(1)
imshow(stim)

for i_scale=1:num_scales
    % gradient magnitude:

    % set gradients lower than threshold to 0:
    % grad_mag(grad_mag<grad_hist_thresh)=0;

    grad_mag_a=grad_mags(:,:,i_scale,1);
    grad_mag_b=grad_mags(:,:,i_scale,2);

    % number of gradient elements in each region at this scale
    % N_a=nnz(~isnan(grad_mag_a));
    % N_b=nnz(~isnan(grad_mag_b));

    % gradient magnitude histograms
    grad_m_hist_a=histcounts(grad_mag_a(:),grad_m_bins(i_scale,:));
    grad_m_hist_b=histcounts(grad_mag_b(:),grad_m_bins(i_scale,:));

    % multinomial LLR for gradient magnitude histograms being different vs same:

    % first compute the terms for each bin:
    term_a=grad_m_hist_a.*log(grad_m_hist_a/N_a);
    term_a(~grad_m_hist_a)=0; % if p=0, set p ln(p) to 0

    term_b=grad_m_hist_b.*log(grad_m_hist_b/N_b);
    term_b(~grad_m_hist_b)=0; % if p=0, set p ln(p) to 0

    term_tot=(grad_m_hist_a+grad_m_hist_b).*log((grad_m_hist_a+grad_m_hist_b)/(N_a+N_b));
    term_tot(~(grad_m_hist_a+grad_m_hist_b))=0; % if p=0, set p ln(p) to 0

    term_llr=term_a+term_b-term_tot;
    grad_m_llr(i_scale)=log(sum(term_llr)+epsl); % take log of LLR because it's always positive

    % plot figure
    figure(2)
    subplot(num_scales,1,i_scale)
    bar([grad_m_hist_b/N_b;grad_m_hist_a/N_a]')
    title(sprintf('LLR = %.1f',grad_m_llr(i_scale)))

    % gradient orientation:

    grad_or_a=grad_ors(:,:,i_scale,1);
    grad_or_b=grad_ors(:,:,i_scale,2);

    % gradient orientation histograms
    grad_o_hist_a=histcounts(grad_or_a(:),grad_o_bins(i_scale,:));
    grad_o_hist_b=histcounts(grad_or_b(:),grad_o_bins(i_scale,:));

    % multinomial LLR for gradient magnitude histograms being different vs same:
    % first compute the terms for each bin:
    term_a=grad_o_hist_a.*log(grad_o_hist_a/N_a);
    term_a(~grad_o_hist_a)=0; % if p=0, set p ln(p) to 0

    term_b=grad_o_hist_b.*log(grad_o_hist_b/N_b);
    term_b(~grad_o_hist_b)=0; % if p=0, set p ln(p) to 0

    term_tot=(grad_o_hist_a+grad_o_hist_b).*log((grad_o_hist_a+grad_o_hist_b)/(N_a+N_b));
    term_tot(~(grad_o_hist_a+grad_o_hist_b))=0; % if p=0, set p ln(p) to 0

    term_llr=term_a+term_b-term_tot;
    grad_o_llr(i_scale)=log(sum(term_llr)+epsl); % take log of LLR because it's always positive

    % plot figure
    figure(3)
    subplot(num_scales,1,i_scale)
    bar([grad_o_hist_b/N_b;grad_o_hist_a/N_a]')
    title(sprintf('LLR = %.1f',grad_o_llr(i_scale)))

    % product of gradient magnitude and orientation:

    grad_prod_a=grad_prods(:,:,i_scale,1);
    grad_prod_b=grad_prods(:,:,i_scale,2);

    % gradient product histograms
    grad_p_hist_a=histcounts(grad_prod_a(:),grad_p_bins(i_scale,:));
    grad_p_hist_b=histcounts(grad_prod_b(:),grad_p_bins(i_scale,:));

    % multinomial LLR for gradient magnitude histograms being different vs same:
    % first compute the terms for each bin:
    term_a=grad_p_hist_a.*log(grad_p_hist_a/N_a);
    term_a(~grad_p_hist_a)=0; % if p=0, set p ln(p) to 0

    term_b=grad_p_hist_b.*log(grad_p_hist_b/N_b);
    term_b(~grad_p_hist_b)=0; % if p=0, set p ln(p) to 0

    term_tot=(grad_p_hist_a+grad_p_hist_b).*log((grad_p_hist_a+grad_p_hist_b)/(N_a+N_b));
    term_tot(~(grad_p_hist_a+grad_p_hist_b))=0; % if p=0, set p ln(p) to 0

    term_llr=term_a+term_b-term_tot;
    grad_p_llr(i_scale)=log(sum(term_llr)+epsl); % take log of LLR because it's always positive

    % plot figure
    figure(4)
    subplot(num_scales,1,i_scale)
    bar([grad_p_hist_b/N_b;grad_p_hist_a/N_a]')
    title(sprintf('LLR = %.1f',grad_p_llr(i_scale)))

end

grad_m_llr_1=grad_m_llr(1);
grad_m_llr_2=grad_m_llr(2);
grad_m_llr_4=grad_m_llr(3);
grad_m_llr_8=grad_m_llr(4);
grad_m_llr_16=grad_m_llr(5);

grad_o_llr_1=grad_o_llr(1);
grad_o_llr_2=grad_o_llr(2);
grad_o_llr_4=grad_o_llr(3);
grad_o_llr_8=grad_o_llr(4);
grad_o_llr_16=grad_o_llr(5);

grad_p_llr_1=grad_p_llr(1);
grad_p_llr_2=grad_p_llr(2);
grad_p_llr_4=grad_p_llr(3);
grad_p_llr_8=grad_p_llr(4);
grad_p_llr_16=grad_p_llr(5);

%% edge contour properties
% 
% % detect edge pixels, and separate into a and b regions
% % for camo, a is boundary and b is texture
% if any(strcmpi(parser.UsingDefaults,'edge_pixels'))
%     if strcmpi(stim_type,'camo')
%         edge_pixels=single(lib.detect_edge_pixels(stim));        
%         edge_pixels_a=single(edge_pixels&bd_strip);
%         edge_pixels_a(~bd_strip)=nan; % nan the non-boundary region to compute densities correctly
%         edge_pixels_b=single(edge_pixels&(~bd_strip));
%         edge_pixels_b(bd_strip)=nan;
%     elseif strcmpi(stim_type,'tex')
%         edge_pixels_a=single(lib.detect_edge_pixels(stim(:,:,1)));
%         edge_pixels_b=single(lib.detect_edge_pixels(stim(:,:,2)));
%     end
% else
%     edge_pixels=single(parser.Results.edge_pixels);
% end
% 
% %% contour type (check if more edge pixels are within boundary strip, or outside)
% 
% % trace contours in regions a and b
% contours_a=lib.trace_contours(edge_pixels_a);
% contours_b=lib.trace_contours(edge_pixels_b);
% 
% % concatenate all contours into one cell
% edge_contours=vertcat(contours_a,contours_b);
% % but label them as regions 1/2. true means region 1, false means region 2.
% [edge_contours{1:numel(contours_a), 2}] = deal(true);
% [edge_contours{numel(contours_a)+1:end, 2}] = deal(false);
% 
% % compute properties of each contour and append them to a struct
% contour_props=struct('contour',{},'type',{},'len',{},'pos',{},'ep1',{},'ep2',{},...
% 'ep4',{},'ep8',{},'ep16',{},'or',{},'curv',{});
% %% contour coordinates
% for i=1:size(edge_contours,1)
%     contour=edge_contours{i};
%     contour_props(i).contour=contour;    
%     contour_linear_indices=sub2ind(size(stim),contour(:,2),contour(:,1));
% 
%     % contour type
%     contour_type=edge_contours{i,2};
%     contour_props(i).type=contour_type;
% 
%     %% contour length
%     % contour_lengths=vecnorm(diff(contour),2,2);
%     % contour_length=sum(contour_lengths);
%     % contour_props(i).len=contour_length;
% 
%     % instead of actual length, use number of contour pixels since it works
%     % better with other likelihood measures
%     contour_length=size(contour,1);
%     contour_props(i).len=contour_length;
% 
%     %% contour position (how close is each contour pixel to true target boundary)
% 
%     % distance of each contour pixel from true target boundary:
%     pos_dev=abs(vecnorm(contour-target_center,2,2)-target_radius);
% 
%     % sum them over the contour:
%     contour_props(i).pos=sum(pos_dev);
% 
%     %% contour tangent (deactivated for now)
%     %         contour_tangent=nan(size(contour));
%     %         % these are choppy 1-point central differences. Could make them
%     %         % smoother with n-point central differences:
%     %         contour_tangent(:,1)=gradient(contour(:,1));
%     %         contour_tangent(:,2)=-gradient(contour(:,2));
%     %         contour_tangent=contour_tangent./vecnorm(contour_tangent,2,2);
%     %         contour_tangent(isnan(contour_tangent))=0;
%     %         contour_props(i).tangent=contour_tangent;
% 
%     %     contour_normal=[contour_tangent(:,2) -contour_tangent(:,1)];
%     %     contour_props.contour_normal=contour_normal;
% 
%     %% absolute orientation (deactivated because not used in camouflage)
%     % contour_displacement=contour(end,:)-contour(1,:);
%     % contour_orientation=atan2(contour_displacement(2),contour_displacement(1));
%     % contour_props(i).or=contour_orientation;
% 
%     %% total edge power at different scales along contour
%     i_reg=2-contour_type; % contour type 0/1 (bd/tx) goes to region 1/2 resp.
%     % now pick out the gradients of the right region
%     grad_1px_x=grads(:,:,1,1,i_reg); grad_1px_y=grads(:,:,2,1,i_reg);
%     grad_2px_x=grads(:,:,1,2,i_reg); grad_2px_y=grads(:,:,2,2,i_reg);
%     grad_4px_x=grads(:,:,1,3,i_reg); grad_4px_y=grads(:,:,2,3,i_reg);
%     grad_8px_x=grads(:,:,1,4,i_reg); grad_8px_y=grads(:,:,2,4,i_reg);
%     grad_16px_x=grads(:,:,1,5,i_reg); grad_16px_y=grads(:,:,2,5,i_reg);
% 
%     edge_vector_1px=[grad_1px_x(contour_linear_indices),grad_1px_y(contour_linear_indices)];
%     edge_vector_2px=[grad_2px_x(contour_linear_indices),grad_2px_y(contour_linear_indices)];
%     edge_vector_4px=[grad_4px_x(contour_linear_indices),grad_4px_y(contour_linear_indices)];
%     edge_vector_8px=[grad_8px_x(contour_linear_indices),grad_8px_y(contour_linear_indices)];
%     edge_vector_16px=[grad_16px_x(contour_linear_indices),grad_16px_y(contour_linear_indices)];
%     %         contour_props(i).edge_vector=edge_vector_4px;
% 
%     % edge power is the sum squared magnitude, i.e. mean squared magnitude * length:
%     % omit nan so that ep's are computed even for contours that are partially in the cropped
%     % border for larger scale gradients
%     ep1=mean(vecnorm(edge_vector_1px,2,2).^2,'omitnan');
%     ep2=mean(vecnorm(edge_vector_2px,2,2).^2,'omitnan');
%     ep4=mean(vecnorm(edge_vector_4px,2,2).^2,'omitnan');
%     ep8=mean(vecnorm(edge_vector_8px,2,2).^2,'omitnan');
%     ep16=mean(vecnorm(edge_vector_16px,2,2).^2,'omitnan');
% 
%     contour_props(i).ep1=ep1*contour_length;
%     contour_props(i).ep2=ep2*contour_length;
%     contour_props(i).ep4=ep4*contour_length;
%     contour_props(i).ep8=ep8*contour_length;
%     contour_props(i).ep16=ep16*contour_length;
% 
%     %% orientation
%     % alignment of 4px contour gradient with the target boundary
%     % 4px seemed best
% 
%     target_normal_x=target_normal(:,:,1);
%     target_normal_y=target_normal(:,:,2);
%     contour_target_normal=[target_normal_x(contour_linear_indices),target_normal_y(contour_linear_indices)];
%     %         contour_props(i).target_normal=contour_target_normal;
%     % cosine alignment:
%     cos_dev=abs(dot(contour_target_normal',edge_vector_4px'))./vecnorm(edge_vector_4px');
%     contour_props(i).or=sum(cos_dev);
% 
%     %% curvature
%     % SD of curvature (deg) of edge vector at 1px
%     theta=cart2pol(edge_vector_1px(:,1),edge_vector_1px(:,2));
%     edge_vector_curvature=angdiff(theta);
%     contour_props(i).curv=rad2deg(std(edge_vector_curvature))^2*contour_length;
% end
% 
% % break the contour props struct into bd and tx contours
% contour_props_a=contour_props(1:numel(contours_a));
% contour_props_b=contour_props(numel(contours_a)+1:end);
% 
% % if either of the list contained no contours, create placeholder features
% % so that mean is 0, not NaN.
% if ~numel(contours_a)
%     contour_props_a=struct('contour',[],'type',true,'len',0,'pos',0,'ep1',0,'ep2',0,...
% 'ep4',0,'ep8',0,'ep16',0,'or',0,'curv',0);
% end
% 
% if ~numel(contours_b)
%     contour_props_b=struct('contour',[],'type',true,'len',0,'pos',0,'ep1',0,'ep2',0,...
% 'ep4',0,'ep8',0,'ep16',0,'or',0,'curv',0);
% end
% 
% 
% %% summary of contour features over the image
% % lengths=vertcat(contour_props.len);
% % orientations=vertcat(contour_props.or);
% % curv=vertcat(contour_props.curv);
% % ep1=vertcat(contour_props.ep1);
% % ep2=vertcat(contour_props.ep2);
% % ep4=vertcat(contour_props.ep4);
% % ep8=vertcat(contour_props.ep8);
% % ep16=vertcat(contour_props.ep16);
% 
% % contour_props_summary=struct;
% 
% % num=numel(bd_contour_props);
% % contour_props_summary.num=num;
% % dens=nnz(bd_pixels==1)/nnz(~isnan(bd_pixels));
% % contour_props_summary.dens=nnz(bd_pixels==1)/nnz(~isnan(bd_pixels));
% 
% % LLR based on number of edge pixels
% M_bd=nnz(~isnan(edge_pixels_a));
% m_bd=nnz(edge_pixels_a==1);
% mbar_bd=M_bd-m_bd;
% 
% M_tx=nnz(~isnan(edge_pixels_b));
% m_tx=nnz(edge_pixels_b==1);
% mbar_tx=M_tx-m_tx;
% 
% npix_llr=log(m_bd*log(m_bd) + m_tx*log(m_tx) - (m_bd+m_tx)*log(m_bd+m_tx)...
% + mbar_bd*log(mbar_bd) + mbar_tx*log(mbar_tx) - (mbar_bd+mbar_tx)*log(mbar_bd+mbar_tx)...
% - M_bd*log(M_bd) - M_tx*log(M_tx) + (M_bd+M_tx)*log(M_bd+M_tx)+epsl);
% 
% 
% len_sum=sum([contour_props_a.len]); 
% % contour_props_summary.len_mean=mean([bd_contour_props.len]); 
% 
% % length-weighted mean of absolute orientations (deactivated because unused in camo)
% % contour_props_summary.or_mean=orientation_stats(orientations,lengths);
% 
% % sum of orientation alignments
% or_sum=sum([contour_props_a.or]);
% 
% % mean and sum of contour curvatures
% curv_sum=sum([contour_props_a.curv]);
% % contour_props_summary.curv_mean=mean([bd_contour_props.curv]);
% 
% % sum of total edge powers
% ep1_sum=sum([contour_props_a.ep1]);
% ep2_sum=sum([contour_props_a.ep2]);
% ep4_sum=sum([contour_props_a.ep4]);
% ep8_sum=sum([contour_props_a.ep8]);
% ep16_sum=sum([contour_props_a.ep16]);
% 
% % mean of total edge powers
% % contour_props_summary.ep1_mean=mean([bd_contour_props.ep1]);
% % contour_props_summary.ep2_mean=mean([bd_contour_props.ep2]);
% % contour_props_summary.ep4_mean=mean([bd_contour_props.ep4]);
% % contour_props_summary.ep8_mean=mean([bd_contour_props.ep8]);
% % contour_props_summary.ep16_mean=mean([bd_contour_props.ep16]);
% 
% n_a=numel(contours_a);
% n_b=numel(contours_b);
% n_contours=n_a+n_b;
% 
% % LLR based on number of contours
% ncon_llr=log((n_a-1)*log(n_a-1) + (n_b-1)*log(n_b-1) + (n_a+n_b-2)*log((m_bd+m_tx)/(n_a+n_b-2))+epsl);
% 
% % same/diff LLR of exponential position alignment distributions of boundary and
% % texture regions
% pos_llr=log(n_contours*log(mean([contour_props.pos]))-...
%     n_a*log(mean([contour_props_a.pos]))-n_b*log(mean([contour_props_b.pos]))+epsl);
% 
% % sum of position alignments ADDED LOG
% pos_sum=log(sum([contour_props_a.pos]));
% 
% % same/diff LLR of exponential length distributions of boundary and
% % texture regions
% len_llr=log(n_contours*log(mean([contour_props.len]))-...
%     n_a*log(mean([contour_props_a.len]))-n_b*log(mean([contour_props_b.len]))+epsl);
% 
% % same/diff LLR of exponential orientation alignment distributions of boundary and
% % texture regions
% or=[contour_props.or]'; or=or(~isnan(or));
% or_a=[contour_props_a.or]'; or_a=or_a(~isnan(or_a));
% or_b=[contour_props_b.or]'; or_b=or_b(~isnan(or_b));
% or_llr=log(numel(or)*log(mean(or))-numel(or_a)*log(mean(or_a))-numel(or_b)*log(mean(or_b))+epsl);
% 
% % same/diff LLR of exponential curvature distributions of boundary and
% % texture regions
% 
% curv_llr=log(n_contours*log(mean([contour_props.curv])+epsl)-...
%     n_a*log(mean([contour_props_a.curv])+epsl)-n_b*log(mean([contour_props_b.curv])+epsl)+epsl);
% 
% % same/diff LLR of exponential edge power distributions of boundary and
% % texture regions
% ep1=[contour_props.ep1]'; ep1=ep1(~isnan(ep1));
% ep1_a=[contour_props_a.ep1]'; ep1_a=ep1_a(~isnan(ep1_a));
% ep1_b=[contour_props_b.ep1]'; ep1_b=ep1_b(~isnan(ep1_b));
% ep1_llr=log(numel(ep1)*log(mean(ep1))-numel(ep1_a)*log(mean(ep1_a))-numel(ep1_b)*log(mean(ep1_b))+epsl);
% 
% ep2=[contour_props.ep2]'; ep2=ep2(~isnan(ep2));
% ep2_a=[contour_props_a.ep2]'; ep2_a=ep2_a(~isnan(ep2_a));
% ep2_b=[contour_props_b.ep2]'; ep2_b=ep2_b(~isnan(ep2_b));
% ep2_llr=log(numel(ep2)*log(mean(ep2))-numel(ep2_a)*log(mean(ep2_a))-numel(ep2_b)*log(mean(ep2_b))+epsl);
% 
% ep4=[contour_props.ep4]'; ep4=ep4(~isnan(ep4));
% ep4_a=[contour_props_a.ep4]'; ep4_a=ep4_a(~isnan(ep4_a));
% ep4_b=[contour_props_b.ep4]'; ep4_b=ep4_b(~isnan(ep4_b));
% ep4_llr=log(numel(ep4)*log(mean(ep4))-numel(ep4_a)*log(mean(ep4_a))-numel(ep4_b)*log(mean(ep4_b))+epsl);
% 
% ep8=[contour_props.ep8]'; ep8=ep8(~isnan(ep8));
% ep8_a=[contour_props_a.ep8]'; ep8_a=ep8_a(~isnan(ep8_a));
% ep8_b=[contour_props_b.ep8]'; ep8_b=ep8_b(~isnan(ep8_b));
% ep8_llr=log(numel(ep8)*log(mean(ep8))-numel(ep8_a)*log(mean(ep8_a))-numel(ep8_b)*log(mean(ep8_b))+epsl);
% 
% ep16=[contour_props.ep16]'; ep16=ep16(~isnan(ep16));
% ep16_a=[contour_props_a.ep16]'; ep16_a=ep16_a(~isnan(ep16_a));
% ep16_b=[contour_props_b.ep16]'; ep16_b=ep16_b(~isnan(ep16_b));
% ep16_llr=log(numel(ep16)*log(mean(ep16))-numel(ep16_a)*log(mean(ep16_a))-numel(ep16_b)*log(mean(ep16_b))+epsl);
% 
