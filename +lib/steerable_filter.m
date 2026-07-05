function filter=steerable_filter(kernel_size)
% returns a steerable filter.
% kernel_sd: gaussian kernel sd
kernel_sd=kernel_size(1);
% kernel_nsd: number of kernel SDs for truncation
kernel_nsd=kernel_size(2);

filter_radius=kernel_nsd*kernel_sd;                       
filter_width=2*ceil(filter_radius)+1;
filter=zeros(filter_width,filter_width,2);
filter_center=(floor(filter_width/2)+1)*[1 1];
for i=1:filter_width
    for j=1:filter_width
        if norm([i,j]-filter_center)<=filter_radius
            filter(i,j,1)=(j-filter_center(2))/kernel_sd^2*exp(-(norm([i,j]-filter_center)/kernel_sd)^2/2);
            filter(i,j,2)=(filter_center(1)-i)/kernel_sd^2*exp(-(norm([i,j]-filter_center)/kernel_sd)^2/2);
        end
    end
end

% normalize by their L2 norm (so that larger filter responses aren't bigger
% simply due to size
% filter_1=filter(:,:,1); filter_1=filter_1(:);
% filter=filter/norm(filter_1(:));

%display filter
% img = filter(:,:,2)- min(min(filter(:,:,2)));
% img = sqrt(img);                           % gamma correct for display
% img = 256*img/max(max(img));               % scale to max of 256
% figure; colormap(gray(256));image(img);axis image;