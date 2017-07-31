function filter=create_steerable_filters(kernel_sd,kernel_nsd)
% returns a steerable filter. Inputs:
% kernel_sd: gaussian kernel sd
% kernel_nsd: number of kernel SDs for truncation
filter_radius=kernel_nsd*kernel_sd;                       
filter_width=2*filter_radius+1;
filter=zeros(filter_width,filter_width,2);
filter_center=(floor(filter_width/2)+1)*[1 1];
for i=1:filter_width
    for j=1:filter_width
        if norm([i,j]-filter_center)<=filter_radius
            %filter_values=-([i,j]-filter_center)/kernel_sd^2*exp(-(norm([i,j]-filter_center)/kernel_sd)^2/2);
            filter(i,j,1)=(j-filter_center(2))/kernel_sd^2*exp(-(norm([i,j]-filter_center)/kernel_sd)^2/2);
            filter(i,j,2)=(filter_center(1)-i)/kernel_sd^2*exp(-(norm([i,j]-filter_center)/kernel_sd)^2/2);
        end
    end
end

%display filter
% img = filter(:,:,2)- min(min(filter(:,:,2)));
% img = sqrt(img);                           % gamma correct for display
% img = 256*img/max(max(img));               % scale to max of 256
% figure; colormap(gray(256));image(img);axis image;