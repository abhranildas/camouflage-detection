function filter=laplacian_of_gaussian_filter(sd,n_sd)
% creates a 2D Laplacian-of-Gaussian filter
% n_sd: extent of the filter, in units of sd

filter_radius=sd*n_sd;                       
filter_size=2*ceil(filter_radius)+1;
filter = fspecial('log',filter_size*[1,1],sd);