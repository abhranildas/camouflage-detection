% texture.type='pink_noise';
% texture.alpha=1;

textures={'sand','moth','rock','spots','coral','bark','leaf','leather','foliage','sand2'};

addpath(genpath('por_sim_tx_synth'))

for i=2:length(textures)
    input_img=['vislab_data/' textures{i} '.jpg'];
    im0=double(im2gray(imread(input_img)));
    Nsc = 4; % Number of scales
    Nor = 4; % Number of orientations
    Na = 9;  % Spatial neighborhood is Na x Na coefficients
    Niter = 25;	% Number of iterations of synthesis loop
    texture=struct;
    texture.type='por_sim';
    texture.stats=textureAnalysis(im0, Nsc, Nor, Na);
    texture.Niter=Niter;
    
    tic
    stim=lib.stimulus('bg_size',2^11,'texture',texture);
    
    stim=(stim-mean(stim(:)))/std(stim(:));
    
    r=lib.autocorr(stim,50);
    toc
    
    % r=fftshift(r);
    
    figure;
    imagesc(r); colormap gray; axis square
    hold on
    contour(r,exp(-1)*[1 1],'r');
    rlist=cat(3,rlist,r);
    
    corr_length=regionprops(r>=exp(-1), 'Perimeter').Perimeter/(2*pi); % avg. correlation length
    corr_lengths=[corr_lengths; corr_length]
end