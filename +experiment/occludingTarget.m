function stimulusOut = occludingTarget(backgroundImg, targetFunction, TargetParams)
%ADDITIVETARGET Adds the target specified by targetFunction to the background
% 
% Example: 
% 	stimulusOut = OCCLUDINGTARGET(backgroundImg, @lib.haar2D, HaarParams);
%
% 1/19/2016, R.C Walshe <calen.walshe@gmail.com>

target = targetFunction(TargetParams);

bAdditive = 0;
bitsIn = 8;

stimulusOut = lib.embedImageinCenter(background, target, bAdditive, bitsIn);
