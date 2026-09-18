function [a, b] = fitPsychometric_steve(a_init,b_init,variable,correct)
%FIT_PSYCHOMETRIC Fit a cumulative Gaussian function using max likelihood
%
% Example: 
%   [cT, b] = FIT_PSYCHOMETRIC(0.2, 1, contrast, correct);
% 
% Output:
%   cT:      model alpha (contrast where d' = 1) 
%   b: 		 model beta (slope parameter)
%
%   See also COMPUTE_NEG_LOG_LIKELIHOOD.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%% Fit model

options = optimset('TolX',1e-3);    
init = [a_init b_init];                              

params = fminsearch(@(x) experiment.analysis.computeNegLogLikelihood_steve(x,variable,correct),init,options);    

a = params(1);  
b = params(2);   
    