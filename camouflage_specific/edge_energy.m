function e=edge_energy(stim,target_radius,steerable_kernel_sd,steerable_kernel_nsd,type)
% calculates edge energy around the circular target boundary.

% calculate stimulus gradient using steerable filter:
stim_grad=steerable_grad(stim,steerable_kernel_sd,steerable_kernel_nsd);

if strcmp(type,'dir')
    % normalize gradient vectors:
    norm3=dsp.Normalizer('Method','2-norm','Dimension','Custom','CustomDimension',3);
    stim_grad=norm3(stim_grad);
end

% calculate edge energy over boundary:
[~,mask_edge,mask_normal]=circular_mask(size(stim,1),target_radius);
if strcmp(type,'mag')
    % sum gradient magnitudes:
    edge_grad=mask_edge.*stim_grad;
    [~,edge_grad_mag]=cart2pol(edge_grad(:,:,1),edge_grad(:,:,2));
    e=sum(edge_grad_mag(:));
else
    % take dot product of normal vectors with gradients:
    absdotprod=abs(mask_normal(:,:,1).*stim_grad(:,:,1)+mask_normal(:,:,2).*stim_grad(:,:,2));
%     figure
%     show_image(stim)
%     colorbar off
%     figure
%     imagesc(absdotprod)
%     axis image; axis off
%     colormap hot
    e=sum(absdotprod(:));
end