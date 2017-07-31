function pos = samplePositions(pixPerUnit,numPix)
%SAMPLEPOSITIONS Spatial positions of samples given a sampling rate 
%
% Example:
%	posDeg = lib.SAMPLEPOSITIONS(128,128)
%
% Output:   
%	pos: 	spatial positions of sample
%
% Johannes Burge

minPos = -0.5*max(numPix)./pixPerUnit;
maxPos =  0.5*max(numPix)./pixPerUnit - 1/pixPerUnit;
pos    = linspace(minPos,maxPos,max(numPix));