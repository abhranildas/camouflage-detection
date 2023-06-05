function [contour_props,mean_contour_props]=edge_props_stim(stim,varargin)

    %% parse inputs
    parser=inputParser;
    parser.KeepUnmatched=true;
    addRequired(parser,'stim', @isnumeric);
    addParameter(parser,'edge_pixels',[], @(x)isa(x,'single'));
    [~,~,target_normal]=lib.target_mask();
    addParameter(parser,'target_normal',target_normal, @isnumeric);

    parse(parser,stim,varargin{:});
    stim=parser.Results.stim;

    if any(strcmpi(parser.UsingDefaults,'edge_pixels'))
        edge_pixels=single(lib.detect_edge_pixels(stim));
    else
        edge_pixels=single(parser.Results.edge_pixels);
    end

    % omit border padding of the smallest kernel thickness
    padsize=1*3;
    padding=true(size(stim));
    padding(padsize+1:end-padsize,padsize+1:end-padsize,1)=false;
    edge_pixels(padding)=nan;

    % compute gradients
    grad_1px=lib.steerable_grad(stim,'kernel_size',[1 3]);
    grad_2px=lib.steerable_grad(stim,'kernel_size',[2 3]);
    grad_4px=lib.steerable_grad(stim,'kernel_size',[4 3]);
    grad_8px=lib.steerable_grad(stim,'kernel_size',[8 3]);
    grad_16px=lib.steerable_grad(stim,'kernel_size',[16 3]);

    %% contour type (check if more edge pixels are within boundary strip, or outside)
    % no longer being used
    %     edge_pixels=false(size(bd_strip));
    %     for i=1:size(contour,1)
    %         edge_pixels(contour(i,1),contour(i,2))=true;
    %     end
    %
    %     contour_type=nnz(edge_pixels&bd_strip)>nnz(edge_pixels&~bd_strip);

    edge_contours=lib.trace_contours(edge_pixels);

    contour_props=struct;
    for i=1:length(edge_contours)
        contour_props(i).contour=edge_contours{i};
    end

    for i=1:length(contour_props)
        contour=contour_props(i).contour;
        contour_linear_indices=sub2ind(size(stim),contour(:,2),contour(:,1));

        %% contour length
        contour_lengths=vecnorm(diff(contour),2,2);
        contour_length=sum(contour_lengths);
        contour_props(i).len=contour_length;

        %% contour tangent (deactivated for now)
        %         contour_tangent=nan(size(contour));
        %         % these are choppy 1-point central differences. Could make them
        %         % smoother with n-point central differences:
        %         contour_tangent(:,1)=gradient(contour(:,1));
        %         contour_tangent(:,2)=-gradient(contour(:,2));
        %         contour_tangent=contour_tangent./vecnorm(contour_tangent,2,2);
        %         contour_tangent(isnan(contour_tangent))=0;
        %         contour_props(i).tangent=contour_tangent;

        %     contour_normal=[contour_tangent(:,2) -contour_tangent(:,1)];
        %     contour_props.contour_normal=contour_normal;

        %% contour overall orientation
        contour_displacement=contour(end,:)-contour(1,:);
        contour_orientation=atan2(contour_displacement(2),contour_displacement(1));
        contour_props(i).or=contour_orientation;

        %% total edge power at different scales along contour
        grad_1px_x=grad_1px(:,:,1); grad_1px_y=grad_1px(:,:,2);
        grad_2px_x=grad_2px(:,:,1); grad_2px_y=grad_2px(:,:,2);
        grad_4px_x=grad_4px(:,:,1); grad_4px_y=grad_4px(:,:,2);
        grad_8px_x=grad_8px(:,:,1); grad_8px_y=grad_8px(:,:,2);
        grad_16px_x=grad_16px(:,:,1); grad_16px_y=grad_16px(:,:,2);

        edge_vector_1px=[grad_1px_x(contour_linear_indices),grad_1px_y(contour_linear_indices)];
        edge_vector_2px=[grad_2px_x(contour_linear_indices),grad_2px_y(contour_linear_indices)];
        edge_vector_4px=[grad_4px_x(contour_linear_indices),grad_4px_y(contour_linear_indices)];
        edge_vector_8px=[grad_8px_x(contour_linear_indices),grad_8px_y(contour_linear_indices)];
        edge_vector_16px=[grad_16px_x(contour_linear_indices),grad_16px_y(contour_linear_indices)];
        %         contour_props(i).edge_vector=edge_vector_4px;

        % edge power is the sum squared magnitude, i.e. mean squared magnitude * length:
        ep1=mean(vecnorm(edge_vector_1px,2,2).^2);
        ep2=mean(vecnorm(edge_vector_2px,2,2).^2);
        ep4=mean(vecnorm(edge_vector_4px,2,2).^2);
        ep8=mean(vecnorm(edge_vector_8px,2,2).^2);
        ep16=mean(vecnorm(edge_vector_16px,2,2).^2);

        contour_props(i).ep1=ep1*contour_length;
        contour_props(i).ep2=ep2*contour_length;
        contour_props(i).ep4=ep4*contour_length;
        contour_props(i).ep8=ep8*contour_length;
        contour_props(i).ep16=ep16*contour_length;

        %% orientation deviation b/w target normal
        % & contour gradient at 4px (seemed best)

        target_normal_x=target_normal(:,:,1);
        target_normal_y=target_normal(:,:,2);
        contour_target_normal=[target_normal_x(contour_linear_indices),target_normal_y(contour_linear_indices)];
        %         contour_props(i).target_normal=contour_target_normal;
        % cosine alignment:
        cos_dev=abs(dot(contour_target_normal',edge_vector_4px'))./vecnorm(edge_vector_4px');
        contour_props(i).or_al=sum(cos_dev);

        %% SD of curvature (deg) of edge vector at 1px
        theta=cart2pol(edge_vector_1px(:,1),edge_vector_1px(:,2));
        edge_vector_curvature=angdiff(theta);
        contour_props(i).curv=rad2deg(std(edge_vector_curvature))^2*contour_length;
    end

    %% mean contour features
    lengths=vertcat(contour_props.len);
    orientations=vertcat(contour_props.or);
    curv=vertcat(contour_props.curv);
    ep1=vertcat(contour_props.ep1);
    ep2=vertcat(contour_props.ep2);
    ep4=vertcat(contour_props.ep4);
    ep8=vertcat(contour_props.ep8);
    ep16=vertcat(contour_props.ep8);

    mean_contour_props=struct;
    mean_contour_props.num=length(edge_contours);
    mean_contour_props.dens=nnz(edge_pixels==1)/nnz(~isnan(edge_pixels));

    mean_contour_props.length=mean(lengths);

    % length-weighted mean of orientations
    mean_contour_props.or=orientation_stats(orientations,lengths);

    % sum of orientation alignments
    mean_contour_props.or_al=sum([contour_props.or_al]);
    
    % straight mean of curvatures
    % mean_contour_props.curv=mean(curv);

    % mean of total curvatures
    mean_contour_props.curv=mean(curv);

    % mean of total edge powers
    mean_contour_props.ep1=mean(ep1);
    mean_contour_props.ep2=mean(ep2);
    mean_contour_props.ep4=mean(ep4);
    mean_contour_props.ep8=mean(ep8);
    mean_contour_props.ep16=mean(ep16);

