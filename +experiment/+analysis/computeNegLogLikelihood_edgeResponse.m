function [nll,p_c,d] = computeNegLogLikelihood_edgeResponse(p,stim_l_groups,stim_e_groups,bTarget,bOpt,num_blanks,num_targets,num_hits,num_cr)
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
    
    th=p(1);
    n=p(2);
    sigma=p(3);
    
    nTrials=size(bTarget,1);
    nLevels=size(bTarget,2);
    
    if th>0 && n>0 && sigma>0
        % edge responses
        r=cellfun(@(l,e) lib.edge_response(l,e,th,n), stim_l_groups, stim_e_groups);
        
        % mean and sd of edge responses for blanks and targets in each level
        r_b_means=nan(1,nLevels); r_b_sds=nan(1,nLevels);
        r_t_means=nan(1,nLevels); r_t_sds=nan(1,nLevels);
        for i=1:nLevels
            r_level=r(:,i);
            r_b=r_level(~bTarget(:,i)); r_t=r_level(bTarget(:,i));
            r_b_means(i)=mean(r_b); r_b_sds(i)=sqrt(var(r_b)+sigma^2);
            r_t_means(i)=mean(r_t); r_t_sds(i)=sqrt(var(r_t)+sigma^2);
        end
        
        % d'_e
        d=abs(r_t_means-r_b_means)./((r_b_sds+r_t_sds)/2);
        
        % ignoring bias
        p_c=normcdf(d/2);
        if bOpt
            ll=mean(p_c);
        else
            ll=sum(log(binopdf(num_hits+num_cr,nTrials,p_c)));
        end
        
        % incorporating bias
%         p_h=normcdf(d*(1-gamma)/2); % prob. of hits
%         p_cr=normcdf(d*(1+gamma)/2); % prob. of correct rejection
%         p_c=(p_h+p_cr)/2; % prob. of correct
%         ll=sum(log(binopdf(num_hits,num_targets,p_h)))+...
%             sum(log(binopdf(num_cr,num_blanks,p_cr)));
        
        nll = -ll;
    else
        nll = inf;
    end