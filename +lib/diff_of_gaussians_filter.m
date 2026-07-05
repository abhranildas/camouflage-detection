function filter=diff_of_gaussians_filter(sd_cent,sd_surr,n_sd)
% creates a center-surround difference-of-gaussians filter
% n_sd: extent of the filter, in units of surround sd

filter_radius=sd_surr*n_sd;                       
filter_size=2*ceil(filter_radius)+1;
filter_origin=(floor(filter_size/2)+1)*[1 1];

filter_cent=zeros(filter_size);
filter_surr=zeros(filter_size);

for i=1:filter_size
    for j=1:filter_size
        X=[i,j]-filter_origin;
        if norm(X)<=filter_radius
            filter_cent(i,j)=mvnpdf(X,[],eye(2)*sd_cent^2);
            filter_surr(i,j)=mvnpdf(X,[],eye(2)*sd_surr^2);
        end
    end
end

% normalize each filter to 1
filter_cent=filter_cent/sum(filter_cent(:));
filter_surr=filter_surr/sum(filter_surr(:));

filter=filter_cent-filter_surr;

