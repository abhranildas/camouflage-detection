function nll = computeNegLogLikelihood_trials(p,target_means,exp_values,response)
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
    
    mu=p(1);
    a=p(2);
    b=p(3);
    c=p(4);
    
    
    if mu>0 && a > 0 && b > 0 && c>-1 && c<1        
        [~,~,~,y]=experiment.analysis.psychometricFun(exp_values,mu,a,b,c);
        [~,~,~,yt]=experiment.analysis.psychometricFun(target_means,mu,a,b,c);
        yc=repmat(yt*(1+c)/2,[size(y,1) 1]); % criteria for each block
        dy=y-yc;
        ll=sum(log(normcdf(dy(response))))+... % response target
            + sum(log(normcdf(dy(~response),'upper'))); % response blank
        nll = -ll;
    else
        nll = inf;
    end