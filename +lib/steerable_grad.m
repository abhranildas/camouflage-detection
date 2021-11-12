function grad=steerable_grad(stim,kernel_size)
% compute stimulus gradient using steerable filters:
steerable_filter=lib.steerable_filter(kernel_size);
grad=zeros([size(stim),2]);
grad(:,:,1)=filter2(steerable_filter(:,:,1),stim,'same');
grad(:,:,2)=filter2(steerable_filter(:,:,2),stim,'same');