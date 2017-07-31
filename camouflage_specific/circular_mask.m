function [mask,varargout]=circular_mask(bg_size,target_radius)
% create circular mask
mask=zeros(bg_size);
mask_center=floor(bg_size/2)*[1 1];
for i=1:bg_size
    for j=1:bg_size
        mask(i,j)=(norm([i,j]-mask_center)<target_radius);
    end
end

if nargout>1    
    % boundary and normal vectors of circular mask:
    mask_edge=zeros(bg_size);
    mask_normal=zeros(bg_size,bg_size,2);
    for i=1:bg_size
        for j=1:bg_size
            if mask(i,j)
                %check if boundary point:
                if ~(mask(i-1,j-1)&&mask(i-1,j)&&mask(i-1,j+1)&&mask(i,j-1)...
                        &&mask(i,j+1)&&mask(i+1,j-1)&&mask(i+1,j)&&mask(i+1,j+1))
                    mask_edge(i,j)=1;
                    vec=normr([j-mask_center(2),mask_center(1)-i]);
                    mask_normal(i,j,1)=vec(1); mask_normal(i,j,2)=vec(2);
                end
            end
        end
    end
    varargout{1}=mask_edge;
    varargout{2}=mask_normal;
end