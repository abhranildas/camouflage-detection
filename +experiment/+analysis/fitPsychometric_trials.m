function [mu, a, b, c] = fitPsychometric_trials(mu_init, a_init, b_init, c_init, target_means, exp_values,response)
%FITPSYCHOMETRIC Fit a cumulative Gaussian function using max likelihood
%
% Example: 
%   [cT, b] = FITPSYCHOMETRIC(0.2, 1, contrast, correct);
% 
% Output:
%   cT:      model alpha (contrast where d' = 1) 
%   b: 		 model beta (slope parameter)
%
%   See also COMPUTENEGLOGLIKELIHOOD.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%% Fit model
% n_levels=size(exp_values,2);
% 
% % means of blanks and targets in each level
% mu_blanks=nan(1,n_levels); 
% mu_targets=nan(1,n_levels);
% 
% for level=1:n_levels
%     x_level=exp_values(:,level);
%     blanks_level=~bTargetPresent(:,level);
%     mu_blanks(level)=mean(x_level(blanks_level));
%     targets_level=bTargetPresent(:,level);
%     mu_targets(level)=mean(x_level(targets_level));
% end

options = optimset('TolX',1e-3);    
init = [mu_init a_init b_init c_init];                              

params = fminsearch(@(p) experiment.analysis.computeNegLogLikelihood_trials(p,target_means,exp_values,response),init,options);    

mu=params(1);
a=params(2); 
b=params(3);
c=params(4);
    