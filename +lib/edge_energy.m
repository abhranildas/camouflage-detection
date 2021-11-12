function e=edge_energy(stim,target_radius,target_loc,kernel_size,type)
% Calculates edge energy of the target against the background.

% Default parameters
if ~exist('target_loc','var')
    target_loc='center';
end

if ~exist('type','var')
    type='grad_by_norm';
end

if ~exist('kernel_size','var')
    kernel_size=[1 3];
end

% calculate stimulus gradient using steerable filter:
stim_grad=lib.steerable_grad(stim,kernel_size);

% create target mask
[~,mask_edge,mask_normal]=lib.circular_mask(size(stim,1),target_radius,target_loc);

edge_grad=mask_edge.*stim_grad;
[~,edge_mag]=cart2pol(edge_grad(:,:,1),edge_grad(:,:,2));

% 1. mag: sum gradient magnitudes
if strcmp(type,'mag')
    e=sum(edge_mag(:));
    return
end

% 2. cos: sum (cos of angle bw gradients & normals)
if strcmp(type,'cos')
    % normalize gradient vectors:
    norm3=dsp.Normalizer('Method','2-norm','Dimension','Custom','CustomDimension',3);
    stim_grad=norm3(stim_grad);
end

edge_normal=mask_normal(:,:,1).*stim_grad(:,:,1)+mask_normal(:,:,2).*stim_grad(:,:,2);

% 3. normal: sum normal gradient magnitudes
if strcmp(type,'normal')||strcmp(type,'cos')
    e=sum(abs(edge_normal(:)));
    return
end

% 4. perp_ratio: log (sum normal gradient magnitudes) / (sum tangent gradient magnitudes)
if strcmp(type,'perp_ratio')
    mask_tangent=[];
    mask_tangent(:,:,1)=mask_normal(:,:,2);
    mask_tangent(:,:,2)=-mask_normal(:,:,1);
    grad_tangent=mask_tangent(:,:,1).*stim_grad(:,:,1)+mask_tangent(:,:,2).*stim_grad(:,:,2);
    e=log(sum(abs(edge_normal(:)))/sum(abs(grad_tangent(:))));
    return
end

% 5. grad_by_lum: sum (normal gradient magnitudes / local luminance)
if strcmp(type,'grad_by_lum')
    averaging_filter=lib.create_averaging_filter(kernel_size);
    e=sum(sum(abs(edge_normal)./conv2(stim,averaging_filter,'same')));
    return
end

% 6. grad_by_norm: (sum normal gradient magnitudes)/(sum gradient magnitudes)
if strcmp(type,'grad_by_norm')
    e=sum(abs(edge_normal(:)))/lib.edge_energy(stim,target_radius,target_loc,kernel_size,'mag')-2/pi;
    return
end

% 7. grad_by_sd: (sum normal gradient magnitudes) / global luminance*contrast
if strcmp(type,'grad_by_sd') 
    e=sum(abs(edge_normal(:)))/std(stim(:));
    return
end

if strcmp(type,'rms')
    e=rms(edge_normal(:))/rms(edge_mag(:));
    %e=rms(edge_normal(:));
    return
end

