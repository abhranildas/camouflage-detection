function [S, P, Pwindowed] = loadPatchAtIndex(ImgStats, patchIndex, filePath, bDisp, envelope)
%LOADPATCHATINDEX: Returns a surround (S) and target patch (P)
%
% Example: 
%   [S,P,Pwindowed] lib.LOADPATCHATINDEX(ImgStats, patchIndex,
%                       fp, 1, 1);
% Outut:
%   S           image surround patch
%   P           image background
%   Pwindowed   windowed patch
%
% v1.0, 1/15/2016, Steve Sebastian <sebastian@utexas.edu>

%% Set parameters

% if the file path is not specified, set it to a default
if(~exist('filePath', 'var'))
    filePath = ImgStats.Settings.imgFilePath;
end;

% if the display boolean is not set, default to 0
if(~exist('bDisp', 'var'))
    bDisp = 0;
end;

if(~exist('envelope', 'var'))
    envelope = [];
end;

surroundSizePix = ImgStats.Settings.surroundSizePix;
targetSizePix = ImgStats.Settings.targetSizePix;

[coordIndex, imgIndex]    = ind2sub(size(ImgStats.C), patchIndex);

%%

imName = ImgStats.imgDir(imgIndex).name;
load([filePath '/' imName]);

% crop out the surround patch
S = lib.cropImage(I_PPM, ImgStats.sampleCoords(coordIndex,:), surroundSizePix, [], 1);

% crop out the patch
centerCoord = ceil(surroundSizePix/2);
P = lib.cropImage(S, [centerCoord, centerCoord], targetSizePix, [], 1);

if(~isempty(envelope))
    P = double(P);
    Pwindowed = ((P-mean(P(:))).*envelope) + mean(P(:));
else
    Pwindowed = [];
end

% plot 
if(bDisp) 
    
    if(isempty(envelope))
        bitsIn = 14;
        subplot(1, 2, 1);
        imagesc(S, [0 2^bitsIn-1]); colormap gray; axis square; % display the image 
        axis square;
        set(gca, 'xtick', []); set(gca, 'ytick', []);

        subplot(1, 2, 2);
        imagesc(P, [0 2^bitsIn-1]); colormap gray; axis square; % display the image 
        axis square;
        set(gca, 'xtick', []); set(gca, 'ytick', []);
    else
        bitsIn = 8;
        pEnv = double(P);
        pEnv = (pEnv-mean(pEnv(:))).*envelope + mean(pEnv(:));
        imagesc(pEnv, [0 2^bitsIn-1]); colormap gray; axis square; % display the image 
        axis square;
        set(gca, 'xtick', []); set(gca, 'ytick', []);
    end
        
end;