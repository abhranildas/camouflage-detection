function [edge,edge_field,edge_normal_field,th_grid] = edge_vector_ideal(stim,varargin)
    
    parser=inputParser;
    parser.KeepUnmatched=true;
    addRequired(parser,'stim', @isnumeric);
    addParameter(parser,'mask', 64, @(x) isscalar(x) || islogical(x)); % scalar means circular mask
    addParameter(parser,'mask_edge', [], @islogical);
    addParameter(parser,'mask_normal', [], @isnumeric);
    addParameter(parser,'n_edge', 1e3, @isnumeric);
    addParameter(parser,'kernel_size', [1 3], @isnumeric);
    
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
%         F=scatteredInterpolant(boundary(:,1),boundary(:,2),thetas','nearest');
%         [X,Y] = meshgrid(1:bg_size);
%         theta_field=F(X,Y);
%         theta_field=theta_field.*mask_edge;
        for i=1:length(row)
            theta_field(row(i),col(i))=thetas(nearest_idx(i));
        end
    end
    
    % calculate stimulus gradient using steerable filter:
    stim_grad=lib.steerable_grad(stim,kernel_size);
    
    % edge magnitude
    edge_field=mask_edge.*stim_grad;
    [~,edge_mag_field]=cart2pol(edge_field(:,:,1),edge_field(:,:,2));
    
    % normal gradient
    edge_normal_field=mask_normal(:,:,1).*stim_grad(:,:,1)+mask_normal(:,:,2).*stim_grad(:,:,2);
    
    % table of theta and edge
    th_edge=sortrows([theta_field(mask_edge),edge_normal_field(mask_edge),edge_mag_field(mask_edge)]);
    
    %     th_edge=th_edge(unique_idx_1,:);
    
    % wrap on either side to help interpolation
    th_edge_wrap=[[th_edge(:,1)-2*pi; th_edge(:,1); th_edge(:,1)+2*pi],repmat(th_edge(:,[2 3]),[3 1])];
    
    % make unique, averaging across the degenerate thetas
    [~,~,unique_idx_2]=unique(th_edge_wrap(:,1));
    th_edge_wrap=groupsummary(th_edge_wrap,unique_idx_2,@nanmean);
    
    % Return a uniform-gridded edge vector without nans
    th_wrap=th_edge_wrap(:,1); edge_norm_wrap=th_edge_wrap(:,2); edge_mag_wrap=th_edge_wrap(:,3);
    edge_norm_interp = griddedInterpolant(th_wrap(~isnan(edge_norm_wrap)),edge_norm_wrap(~isnan(edge_norm_wrap)));
    edge_mag_interp = griddedInterpolant(th_wrap(~isnan(edge_mag_wrap)),edge_mag_wrap(~isnan(edge_mag_wrap)));
    
    th_grid=linspace(-pi,pi,n_edge+1);
    th_grid=th_grid(2:end);
    
    edge_mag=edge_mag_interp(th_grid);
    edge=edge_norm_interp(th_grid)/rms(edge_mag);