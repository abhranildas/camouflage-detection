function imgOut = gammaCorrect(imgIn, gammaValue, bitDepthIn, bitDepthOut)
%GAMMACORRECT Apply gamma commpression to the 
% 
% Example: 
%  [stimiuli pIndex] = SAMPLEPATCHESFOREXPERIMENT(ImgStats, 'gabor', [5 5 5], 'uniform'); 
%
% v1.0, 2/24/2016, Steve Sebastian <sebastian@utexas.edu>

%%
maxPixelValIn = 2^bitDepthIn - 1;
maxPixelValOut = 2^bitDepthOut - 1;

%% Gamma correct

imgOut = (imgIn./maxPixelValIn).^(1/gammaValue);
imgOut = maxPixelValOut.*imgOut;
imgOut = round(imgOut);

