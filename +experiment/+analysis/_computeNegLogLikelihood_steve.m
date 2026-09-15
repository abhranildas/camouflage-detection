function nll = computeNegLogLikelihood_steve(x,variable,correct)
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

a = x(1);   
b = x(2);    

like = 0;       %Set the likelihood to zero

if a > 0 && b > 0
    like = like + sum(log(normcdf(0.5 * ((variable(correct)/a).^b))));   %Add up the likelihoods for the correct trials
    like = like + sum(log(normcdf(0.5 * ((variable(~correct)/a).^b),'upper'))); %Add up the likelihoods for the incorrect trials
    nll = -like;    
else
    nll = inf;
end