function img_porsim=create_porsim_square(input_img,size)

input_img='global_data/bark.png';
%im0 = pgmRead('text.pgm');	% im0 is a double float matrix!
im0=double((imread(input_img)));

Nsc = 4; % Number of scales
Nor = 4; % Number of orientations
Na = 9;  % Spatial neighborhood is Na x Na coefficients
	 % It must be an odd number!

params = textureAnalysis(im0, Nsc, Nor, Na);

Niter = 25;	% Number of iterations of synthesis loop
texture_params=struct;
texture_params.params=params;
texture_params.Niter=Niter;

Nsx = size;	% Size of synthetic image is Nsy x Nsx
Nsy = size;	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

img_porsim = textureSynthesis(params, [Nsy Nsx], Niter);

