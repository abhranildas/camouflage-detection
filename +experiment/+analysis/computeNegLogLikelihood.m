function nll = computeNegLogLikelihood(p,target_means, num_blanks,num_targets, num_hits, num_cr)
    %COMPUTENEGLOGLIKELIHOOD Negative log likelihood for the signal detection model
    %
    % Example:
    %   nll = COMPUTENEGLOGLIKELIHOOD(x, contrast, correct);
    %
    % Output:
    %   nll:     negative log likelihood
    %   b: 		 model beta (slope parameter)
    %
    %   See also FITPSYCHOMETRICFUNCTION.
    %
    % v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>
    
    %%
    
%     mu=p(1);
    mu=0;
    a=p(1);
    b=p(2);
    c=p(3);
    
    
    % y_bm=(blank_mean/a).^b;
    % yc=d/2;
    % y=(x/a).^b;
    
    % yc=y_bm+(y_t-y_bm)*(c+1)/2;
    
    % z=y-yc;
    if a > 0 && b > 0 && c>-1 && c<1
        %         ll=sum(log(normcdf(z(response)/2)))+... % response target
        %      + sum(log(normcdf(d(~response),'upper'))); % response blank
        
        d=(abs(target_means-mu)/a).^b.*sign(target_means-mu); % d primes
        p_h=normcdf(d*(1-c)/2); % prob. of hits
        p_cr=normcdf(d*(1+c)/2); % prob. of correct rejection
%         p_c=(p_h+p_cr)/2; % prob. of correct
        
%         p_c=normcdf(d/2);
        ll=sum(log(binopdf(num_hits,num_targets,p_h)))+...
           sum(log(binopdf(num_cr,num_blanks,p_cr)));
        nll = -ll;
    else
        nll = inf;
    end