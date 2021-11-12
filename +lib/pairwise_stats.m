function stats=pairwise_stats(x,y)
% compute stats (n,xm,ym,xym,x2m,y2m,r) of pairwise observations x and y.
x=x(:); y=y(:);
if numel(x)~=numel(y)
    error('The number of observations in the two lists are different.');
end

n=numel(x);
xm=mean(x); ym=mean(y);
xym=mean(x.*y);
x2m=mean(x.^2); y2m=mean(y.^2);
r=(xym-xm*ym)/sqrt((x2m-xm^2)*(y2m-ym^2));
stats=[n xm, ym, xym, x2m, y2m, r];