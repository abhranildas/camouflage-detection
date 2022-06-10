function [target_edge_vector,target_edge_power,target_contours_l,target_contours_e,target_edge_field,th_grid,all_contours_l,all_contours_e]=edge(stim,varargin)
    % EDGE Compute the target edge vector and its measures
    %
    % Abhranil Das <abhranil.das@utexas.edu>
    % Center for Perceptual Systems, University of Texas at Austin
    %
    % Example:
    % stim=lib.stimulus();
    % [edge_vector,edge_power]=lib.edge(stim);
    %
    % Required inputs: none
    % stim                  greyscale stimulus image
    %
    % Optional name-value inputs:
    % mask                  binary image of target mask for which to
    %                       compute the edge
    % mask_edge             binary image of the target mask edge
    % mask_normal           2 arrays specifying the x- and y- components of
    %                       the normal vectors to the mask edge
    % n_edge                number of points to compute on edge vector. 1e3 by default.
    % kernel_size           2-element vector. First is the Gaussian sd (in
    %                       px) of the steerable gradient filter. Second is
    %                       the number of sd's by which the kernel goes out
    %                       from the center before it is truncated. Default
    %                       is [1,3].
    
    parser=inputParser;
    parser.KeepUnmatched=true;
    addRequired(parser,'stim', @isnumeric);
    addParameter(parser,'mask', 64, @(x) isscalar(x) || islogical(x)); % scalar means circular mask
    addParameter(parser,'mask_edge', [], @islogical);
    addParameter(parser,'mask_normal', [], @isnumeric);
    addParameter(parser,'n_edge', 1e3, @isnumeric);
    addParameter(parser,'kernel_size', [1 3], @isnumeric);
    
    %% compute the edge along the target boundary
    parse(parser,stim,varargin{:});
    stim=parser.Results.stim;
    if isscalar(parser.Results.mask)
        target_radius=parser.Results.mask;
    else
        mask=parser.Results.mask;
        mask_edge=parser.Results.mask_edge;
        mask_normal=parser.Results.mask_normal;
    end
    n_edge=parser.Results.n_edge;
    kernel_size=parser.Results.kernel_size;
    
    bg_size=size(stim,1);
    target_center=floor(bg_size/2)*[1 1];
    
    % field of parameter theta along the boundary
    theta_field=nan(bg_size);
    if isscalar(parser.Results.mask) % if circular mask
        
        % array of angles theta for circular mask
        for i=1:bg_size
            for j=1:bg_size
                vec=[i,j]-target_center;
                theta_field(i,j)=cart2pol(vec(1),vec(2));
            end
        end
        
        % create mask edge and normal
        [~,mask_edge,mask_normal]=lib.target_mask('bg_size',size(stim,1),'target_radius',target_radius);
        
    else
        % array of parameter theta along the boundary
        boundaries=bwboundaries(mask,'noholes');
        [~,idx]=max(cellfun(@(x) size(x,1),boundaries)); %longest boundary
        boundary=boundaries{idx};
        thetas=linspace(-pi,pi,size(boundary,1)+1);
        thetas=thetas(1:end-1);
        [row,col]=find(mask_edge);
        nearest_idx=knnsearch([boundary(:,1),boundary(:,2)],[row col]);
        for i=1:length(row)
            theta_field(row(i),col(i))=thetas(nearest_idx(i));
        end
    end
    
    % stimulus gradient using steerable filter:
    stim_grad=lib.steerable_grad(stim,kernel_size);
    
    % local luminance*contrast (std):
    % define local patch neighbourhood
    nhood_radius=kernel_size(1)*kernel_size(2);
    nhood_size=2*ceil(nhood_radius)+1;
    nhood=false(nhood_size);
    nhood_center=(floor(nhood_size/2)+1)*[1 1];
    for i=1:nhood_size
        for j=1:nhood_size
            if norm([i,j]-nhood_center)<=nhood_radius
                nhood(i,j)=true;
            end
        end
    end
    stim_std=stdfilt(stim,nhood);
    
    % normal gradient
    normal_gradient_field=mask_normal(:,:,1).*stim_grad(:,:,1)+mask_normal(:,:,2).*stim_grad(:,:,2);
    
    % normalize by std
    target_edge_field=normal_gradient_field./stim_std;
    
    % table of theta and edge
    th_edge=sortrows([theta_field(mask_edge),target_edge_field(mask_edge)]);
    
    % wrap on either side to help interpolation
    th_edge_wrap=[[th_edge(:,1)-2*pi; th_edge(:,1); th_edge(:,1)+2*pi],repmat(th_edge(:,2),[3 1])];
    
    % make unique, averaging across the degenerate thetas
    [~,~,unique_idx_2]=unique(th_edge_wrap(:,1));
    th_edge_wrap=groupsummary(th_edge_wrap,unique_idx_2,@nanmean);
    
    % Return a uniform-gridded edge vector without nans
    th_wrap=th_edge_wrap(:,1); edge_norm_wrap=th_edge_wrap(:,2);
    edge_norm_interp = griddedInterpolant(th_wrap(~isnan(edge_norm_wrap)),edge_norm_wrap(~isnan(edge_norm_wrap)));
    
    th_grid=linspace(-pi,pi,n_edge+1);
    th_grid=th_grid(2:end);
    
    target_edge_vector=edge_norm_interp(th_grid);
    target_edge_power=mean(target_edge_vector.^2);
    
    %% compute edge contours along the target boundary
    s=sign([target_edge_vector,target_edge_vector]);
    sign_changes=diff(s);
    sign_changes=sign_changes(1:length(target_edge_vector));
    locs=find(sign_changes);
    
    % circularly shift to begin at a group
    edge_rotated=circshift(target_edge_vector,-locs(1));
    sign_changes=circshift(sign_changes,-locs(1));
    
    locs=find(sign_changes);
    n_groups=length(locs);
    locs=[0,locs];
    target_contours_l=diff(locs)';
    
    target_contours_e=nan(n_groups,1);
    for i=1:n_groups
        target_contours_e(i)=mean(edge_rotated(locs(i)+1:locs(i+1)).^2);
    end
    
    %% compute all edge contours in the image
    stim_grad_x=stim_grad(:,:,1); stim_grad_y=stim_grad(:,:,2);
    e=edge(stim,'canny',[.25 .43]); % threshold for foliage
    contours_all=bwboundaries(e);
    all_contours_l=nan(size(contours_all,1),1);
    all_contours_e=nan(size(all_contours_l));
    for i=1:size(contours_all,1)
        contour=contours_all{i,1};
        [all_contours_l(i),contour_normal]=lib.contour_props(contour);
%         l_contours_all(i)=contour_length;
        contour_indices=sub2ind(size(stim),contour(:,1),contour(:,2));
        contour_gradient=nan(size(contour,1),2); % image gradient along the contour
        contour_gradient(:,1)=stim_grad_x(contour_indices); contour_gradient(:,2)=stim_grad_y(contour_indices);
        contour_normal_gradient=contour_normal(:,1).*contour_gradient(:,1)+contour_normal(:,2).*contour_gradient(:,2);
        contour_edge=contour_normal_gradient./stim_std(contour_indices);
        all_contours_e(i)=mean(contour_edge.^2);
    end