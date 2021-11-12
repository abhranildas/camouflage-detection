function [corr_cross,corr_same,d,shift_stats_same,shift_stats_cross]=correlations_across_same(stim,mask)
% compute correlation coefficients of pairs of points in
% a stimulus image, separately for pairs across, and on the same side
% of the boundary (given by the mask).

%% 1. compute sufficient pairwise statistics for all x-y shifts
% that can be combined to get correlation coefficients:

bg_size=size(stim,1);
shift_stats_cross=nan(bg_size,2*bg_size-1,7);
shift_stats_same=nan(bg_size,2*bg_size-1,7);

for shift_x=0:bg_size-1
    for shift_y=-(bg_size-1):bg_size-1
        shift_y_1=shift_y; shift_y_2=-shift_y;
        
        y_start_1=max(1-shift_y_1,1); y_end_1=min(bg_size-shift_y_1,bg_size);
        y_start_2=max(1-shift_y_2,1); y_end_2=min(bg_size-shift_y_2,bg_size);
        
        stim_1=stim(1:end-shift_x,y_start_1:y_end_1);
        stim_2=stim(1+shift_x:end,y_start_2:y_end_2);
        
        mask_1=mask(1:end-shift_x,y_start_1:y_end_1);
        mask_2=mask(1+shift_x:end,y_start_2:y_end_2);
        
        stim_1_cross=stim_1(mask_1~=mask_2);
        stim_2_cross=stim_2(mask_1~=mask_2);
        
        stim_1_same=stim_1(mask_1==mask_2);
        stim_2_same=stim_2(mask_1==mask_2);
        
        shift_stats_cross(shift_x+1,shift_y+bg_size,:)=lib.pairwise_stats(stim_1_cross,stim_2_cross);
        shift_stats_same(shift_x+1,shift_y+bg_size,:)=lib.pairwise_stats(stim_1_same,stim_2_same);        
    end
end

% remove vertical reflection from being double-counted
shift_stats_cross(1,bg_size+1:end,1)=0;
shift_stats_same(1,bg_size+1:end,1)=0;

%% 2. compute correlation coefficient vs distance by combining above
% pairwise stats for each distance:

shift_stats_cross_flat=reshape(shift_stats_cross,[bg_size*(2*bg_size-1),7]);
shift_stats_same_flat=reshape(shift_stats_same,[bg_size*(2*bg_size-1),7]);

x2=repmat((0:bg_size-1).^2,[2*bg_size-1,1]); % array of x^2
y2=repmat((-(bg_size-1):bg_size-1).^2,[bg_size,1]); % array of y^2
d2_mat=x2'+y2; % matrix of d^2 = x^2 + y^2
d2_list=unique(d2_mat);
d=sqrt(d2_list);
corr_cross=nan(numel(d),1);
corr_same=nan(numel(d),1);

for i=1:numel(d2_list)
    d2=d2_list(i);
    
    % across boundary:
    d2_stats_cross=shift_stats_cross_flat((d2_mat==d2)&(shift_stats_cross(:,:,1)>0),:);
    [~,~,~,~,~,~,r]=lib.combine_pairwise_stats(...
        d2_stats_cross(:,1),...
        d2_stats_cross(:,2),...
        d2_stats_cross(:,3),...
        d2_stats_cross(:,4),...
        d2_stats_cross(:,5),...
        d2_stats_cross(:,6),...
        d2_stats_cross(:,7));
    corr_cross(i)=r;
    
    % same side of boundary:
    d2_stats_same=shift_stats_same_flat(d2_mat==d2,:);
    [~,~,~,~,~,~,r]=lib.combine_pairwise_stats(...
        d2_stats_same(:,1),...
        d2_stats_same(:,2),...
        d2_stats_same(:,3),...
        d2_stats_same(:,4),...
        d2_stats_same(:,5),...
        d2_stats_same(:,6),...
        d2_stats_same(:,7));
    corr_same(i)=r;

end