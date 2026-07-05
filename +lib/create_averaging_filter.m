function filter=create_averaging_filter(kernel_size)
% returns an averaging filter of the same size as steerable filter,
% to be used for calculating mean luminance over a patch.

% kernel_sd: gaussian kernel sd
kernel_sd=kernel_size(1);
% kernel_nsd: number of kernel SDs for truncation
kernel_nsd=kernel_size(2);

filter_radius=kernel_nsd*kernel_sd;                       
filter_width=2*filter_radius+1;
filter=zeros(filter_width,filter_width);
filter_center=(floor(filter_width/2)+1)*[1 1];
for i=1:filter_width
    for j=1:filter_width
            filter(i,j)=(norm([i,j]-filter_center)<=filter_radius);
    end
end
filter=filter/sum(filter(:)); %so that it's mean instead of sum when convolved.