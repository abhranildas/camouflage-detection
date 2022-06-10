function [txtr_edge_density,n_bdry_edge_pixels,bdry_contours,txtr_contours]=edge_measures(stim,varargin)
    
    parser=inputParser;
    parser.KeepUnmatched=true;
    addRequired(parser,'stim', @isnumeric);
    [~,~,~,bdry_strip]=lib.target_mask();
    addParameter(parser,'bdry_strip', bdry_strip, @islogical);
%     addParameter(parser,'sig_n', 1, @isnumeric);
    
    parse(parser,stim,varargin{:});
    bdry_strip=parser.Results.bdry_strip;
%     sig_n=parser.Results.sig_n;
    
    %     kernel_size=[1 3];
    
    %% compute all edge contours in the image
    % stimulus gradient using steerable filter:
    %     stim_grad=lib.steerable_grad(stim,kernel_size);
    
    %     stim_grad_x=stim_grad(:,:,1); stim_grad_y=stim_grad(:,:,2);
    all_edges=edge(stim,'canny',[.2 .3]); % threshold for foliage
    
    %% separate into boundary contours and texture contours
    bdry_contours=bwboundaries((all_edges&bdry_strip)');
    txtr_contours=bwboundaries((all_edges&~bdry_strip)');
    
    %% compute edge density d'
    % texture edge density fraction
    txtr_edge_density=sum(cellfun(@(x) size(x,1), txtr_contours))/nnz(~bdry_strip);
    
    n_bdry_edge_pixels=sum(cellfun(@(x) size(x,1), bdry_contours)); % number of boundary edge pixels
    
    %     d_n=(n_bdry_edges-n_bdry*txtr_edge_density)/sqrt(sig_n^2+n_bdry*txtr_edge_density*(1-txtr_edge_density));
    
    %% response
    %     response=d_n;
    
    %     contours_all=bwboundaries(all_edges);
    
    
    
    %     all_contours_l=nan(size(contours_all,1),1);
    %     all_contours_e=nan(size(all_contours_l));
    %     for i=1:size(contours_all,1)
    %         contour=contours_all{i,1};
    %         [all_contours_l(i),contour_normal]=lib.contour_props(contour);
    %         %         l_contours_all(i)=contour_length;
    %         contour_indices=sub2ind(size(stim),contour(:,1),contour(:,2));
    %         contour_gradient=nan(size(contour,1),2); % image gradient along the contour
    %         contour_gradient(:,1)=stim_grad_x(contour_indices); contour_gradient(:,2)=stim_grad_y(contour_indices);
    %         contour_normal_gradient=contour_normal(:,1).*contour_gradient(:,1)+contour_normal(:,2).*contour_gradient(:,2);
    %         contour_edge=contour_normal_gradient./stim_std(contour_indices);
    %         all_contours_e(i)=mean(contour_edge.^2);
    %     end