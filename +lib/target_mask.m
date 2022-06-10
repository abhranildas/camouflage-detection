function [mask,mask_edge,mask_normal,mask_strip]=target_mask(varargin)

parser=inputParser;
parser.KeepUnmatched=true;
addParameter(parser,'bg_size', 256, @(x) isscalar(x) && ~mod(x,2)); %bg_size needs to be even, otherwise you get complex numbers.
%     addParameter(parser,'seed','rand', @(x) isscalar(x) || strcmp(x,'rand'));
addParameter(parser,'target_shape', 'circular', @(x) strcmp(x,'circular') || isscalar(x));
addParameter(parser,'target_radius', 64, @isnumeric);
addParameter(parser,'target_radius_cont', .15, @isnumeric);
addParameter(parser,'target_loc', 'center', @(x) isvector(x) || strcmp(x,'center'));
addParameter(parser,'kernel_size', [1 3], @isnumeric);

parse(parser,varargin{:});
bg_size=parser.Results.bg_size;
%     seed=parser.Results.seed;
target_radius=parser.Results.target_radius;
target_shape=parser.Results.target_shape;
target_radius_cont=parser.Results.target_radius_cont;
target_loc=parser.Results.target_loc;
kernel_size=parser.Results.kernel_size;

if strcmp(target_loc,'center')
    mask_center=floor(bg_size/2)*[1 1];
else
    mask_center=target_loc;
end

% compute mask
mask=false(bg_size);

if strcmp(target_shape,'circular')
    for i=1:bg_size
        for j=1:bg_size
            mask(i,j)=(norm([i,j]-mask_center)<target_radius);
        end
    end
else
    n_ang=1e3; % no. of angle points
    r_grid=lib.create_pink_noise_line(n_ang,target_shape);
    
    % set mean and std of target radius:
    r_grid=(r_grid-mean(r_grid(:)))*target_radius*target_radius_cont/std(r_grid(:))+target_radius;
    
    % polar coords of each pixel in the image
    [x,y]=meshgrid(1:bg_size);
    [th,r]=cart2pol(x-mask_center(1),y-mask_center(2));
    th_idx=round((th+pi)/(2*pi)*n_ang)+1; th_idx(th_idx==n_ang+1)=1;
    mask=r<r_grid(th_idx);
end

%             %check if boundary point (old method):
%             if mask(i,j)&&...
%                     ~(mask(i-1,j-1)&&mask(i-1,j)&&mask(i-1,j+1)&&mask(i,j-1)...
%                     &&mask(i,j+1)&&mask(i+1,j-1)&&mask(i+1,j)&&mask(i+1,j+1))
%                 mask_edge_old(i,j)=true;
%             end

%check if boundary point (new method):
%nbd=mask(i-1:i+1,j-1:j+1);
%if length(unique(nbd))>1
%mask_edge(i,j)=1;

% compute mask edge: all pixels where at least one of its neighbours
% is diff. from it
mask_edge=bwperim(mask,4)|bwperim(~mask,4);
mask_edge(:,[1 end])=0; mask_edge([1 end],:)=0;

% compute mask normal vectors
mask_normal=zeros(bg_size,bg_size,2);

if strcmp(target_shape,'circular')
    for i=2:bg_size-1
        for j=2:bg_size-1
            if mask_edge(i,j)
                vec=[j-mask_center(2),mask_center(1)-i];
                vec=vec/norm(vec);
                mask_normal(i,j,1)=vec(1); mask_normal(i,j,2)=vec(2);
            end
        end
    end
else
    %         [mask_normal(:,:,1),mask_normal(:,:,2)] = imgradientxy(mask);
    %         mask_normal(:,:,1)=-mask_normal(:,:,1);
    [~,gdir] = imgradient(~mask);
    mask_normal(:,:,1)=cosd(gdir);
    mask_normal(:,:,2)=sind(gdir);
    
    %         mask_normal=lib.steerable_grad(~mask,[1 3]);
    %
    %         mask_normal=mask_normal./vecnorm(mask_normal,2,3);
    mask_normal=mask_normal.*mask_edge;
    
end

% make boundary ribbon of steerable kernel width
mask_grad=lib.steerable_grad(mask,kernel_size);
mask_grad_mag=mask_grad(:,:,1).^2+mask_grad(:,:,2).^2;
mask_strip=mask_grad_mag>1e-31;
