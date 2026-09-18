function [texture_edge_density, n_boundary_edge_pixels, boundary_contours, texture_contours] = ...
    edge_measures(stim, options)
% EDGE_MEASURES  Split an image's edge contours into boundary and texture sets.
%   [texture_edge_density, n_boundary_edge_pixels] = lib.edge_measures(stim)
%   [...] = lib.edge_measures(stim, 'bdry_strip', mask_strip)
%
%   Detects all zero-crossing edges in the image, then partitions them by
%   whether they fall inside the ribbon along the target boundary. The idea is
%   a signal-detection comparison: how many edge pixels lie on the boundary,
%   against how dense edges are in the surrounding texture.
%
%   Inputs
%     stim        - greyscale stimulus image, in normalised luminance units.
%     bdry_strip  - (name-value) logical ribbon along the target boundary.
%                   Defaults to the fourth output of lib.target_mask() called
%                   with no arguments, i.e. a 256-pixel image with a
%                   64-pixel-radius circular target. That default is rebuilt
%                   on every call that does not supply one, and is wrong for
%                   any other image size; see B3.13 in the plan.
%     edge_kernel - (name-value) 3x3 smoothing kernel handed to EDGE's
%                   'zerocross' method. Defaults to a binomial kernel.
%
%   Outputs
%     texture_edge_density   - total texture edge-contour length divided by the
%                              number of pixels outside the boundary ribbon;
%                              dimensionless, a fraction of pixels.
%     n_boundary_edge_pixels - total length, in pixels, of the edge contours
%                              inside the boundary ribbon.
%     boundary_contours      - cell array of contours from BWBOUNDARIES, inside
%                              the ribbon.
%     texture_contours       - same, outside the ribbon.
%
%   The call to edge(...) below is the Image Processing Toolbox EDGE, not
%   lib.edge, even though this file lives in +lib: MATLAB does not resolve an
%   unqualified name against its own package. This was checked by running it
%   and is correct as written; do not "fix" it to lib.edge.
%
%   See also lib.TARGET_MASK, lib.EDGE_VECTOR_IDEAL, EDGE, BWBOUNDARIES.

    arguments
        stim {mustBeNumeric}
        options.bdry_strip {mustBeA(options.bdry_strip, 'logical')} = default_bdry_strip()
        options.edge_kernel {mustBeNumeric} = [1/16 1/8 1/16;
            1/8 1/4 1/8;
            1/16 1/8 1/16]
    end

    bdry_strip = options.bdry_strip;
    edge_kernel = options.edge_kernel;

    %% compute all edge contours in the image
%     all_edges=edge(stim,'canny',[.2 .3]); % threshold for foliage
    all_edge_pixels = edge(stim, 'zerocross', 1e-3, edge_kernel);  % threshold for foliage

    %% separate into boundary contours and texture contours
    boundary_contours = bwboundaries((all_edge_pixels & bdry_strip)');
    texture_contours = bwboundaries((all_edge_pixels & ~bdry_strip)');

    %% compute edge density d'
    % texture edge density fraction
    texture_edge_density = sum(cellfun(@(x) size(x, 1), texture_contours))/nnz(~bdry_strip);

    % number of boundary edge pixels
    n_boundary_edge_pixels = sum(cellfun(@(x) size(x, 1), boundary_contours));

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
end

function bdry_strip = default_bdry_strip()
% The default boundary ribbon: lib.target_mask's fourth output, with no
% arguments, i.e. a 256-pixel image with a 64-pixel-radius circular target.
% A local function because an arguments-block default must be one expression,
% and this needs the fourth of several outputs. See B3.13.
    [~, ~, ~, bdry_strip] = lib.target_mask();
end
