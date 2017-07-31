function [cT, b] = fitPsychometric(initCT,initB,contrast,correct)
%FITPSYCHOMETRIC Fit a Weibull function using max liklihood
%
% Example: 
%   [cT, b] = FITPSYCHOMETRIC(0.2, 1, contrast, correct);
% 
% Output:
%   cT:      model alpha (contrast where d' = 1) 
%   b: 		 model beta (slole parameter)
%
%   See also COMPUTENEGLOGLIKELIHOOD.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%% Fit model

options = optimset('TolX',1e-3,'Display','off');    
init = [initCT initB];                              

params = fminsearch(@(x) analysis.computeNegLogLikelihood(x,contrast,correct),init,options);    

cT = params(1);  
b = params(2);   
    