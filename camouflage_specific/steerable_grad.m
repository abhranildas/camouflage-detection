function grad=steerable_grad(stim,kernel_sd,kernel_nsd)
% compute stimulus gradient using steerable filters:
steerable_filter=create_steerable_filters(kernel_sd,kernel_nsd);
grad=zeros([size(stim),2]);
grad(:,:,1)=conv2(stim,steerable_filter(:,:,1),'same');
grad(:,:,2)=conv2(stim,steerable_filter(:,:,2),'same');