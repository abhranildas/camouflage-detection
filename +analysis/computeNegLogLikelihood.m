function nll = computeNegLogLikelihood(x,contrast,correct)
%COMPUTENEGLOGLIKELIHOOD Negative log likelihood for the signal detection model
%
% Example: 
%   nll = COMPUTENEGLOGLIKELIHOOD(x, contrast, correct);
% 
% Output:
%   nll:     negative log likelihood
%   b: 		 model beta (slole parameter)
%
%   See also FITPSYCHOMETRICFUNCTION.
%
% v1.0, 1/5/2016, Jared Abrams, Steve Sebastian <sebastian@utexas.edu>

%%

cT = x(1);   
b = x(2);    

like = 0;       %Set the likelihood to zero

if cT > 0 && cT <= 1 && b > 0
    like = like + sum(log(normcdf(0.5 * ((contrast(correct==1)./cT).^b))));   %Add up the likelihoods for the correct trials
    like = like + sum(log(1-normcdf(0.5 * ((contrast(correct==0)./cT).^b)))); %Add up the likelihoods for the incorrect trials
    nll = -like;    
else
    nll = inf;
end