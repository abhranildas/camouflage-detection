function [p_c,p_h,p_cr,d]=psychometricFun(x,mu,a,b,c)
    d=(abs(x-mu)/a).^b.*sign(x-mu); % d primes
    p_h=normcdf(d*(1-c)/2); % prob. of hits
    p_cr=normcdf(d*(1+c)/2); % prob. of correct rejection
    p_c=(p_h+p_cr)/2; % prob. of correct
    
