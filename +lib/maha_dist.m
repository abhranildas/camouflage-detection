function d=maha_dist(x,mu,v)
% Mahalanobis distance between observations (col=var, row=obs)
% and Gaussian with mean mu and covariance v. Returns colum of distances.
d=dot(x-mu,(x-mu)/v,2);
