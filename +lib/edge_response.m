function [response, edge_power_suppressed] = edge_response(group_lengths, group_edge_powers, ...
    threshold, group_count_offset)
% EDGE_RESPONSE  Observer response from per-contour-group edge powers.
%   [response, edge_power_suppressed] = ...
%       lib.edge_response(group_lengths, group_edge_powers, threshold, group_count_offset)
%
%   Given the contour groups along a target boundary — their lengths and their
%   mean edge powers — and the two fit parameters, returns the model
%   observer's scalar response. Weak edges are suppressed by a soft threshold
%   before being weighted by contour length and pooled.
%
%   Inputs
%     group_lengths      - vector of contour-group lengths, in edge samples.
%     group_edge_powers  - vector, same size, of log mean edge power per
%                          group. Dimensionless; the exp() below means these
%                          are logs.
%     threshold          - fit parameter: the log edge power at which
%                          suppression sets in. Same units as
%                          group_edge_powers.
%     group_count_offset - fit parameter: a constant added to the number of
%                          groups in the divisive pooling, so that a stimulus
%                          with few groups is not over-weighted.
%
%   Outputs
%     response              - scalar pooled response, dimensionless.
%     edge_power_suppressed - the soft-thresholded group edge powers, same
%                             size as group_edge_powers.
%
%   The original one-line docstring said this returns "the edge response mean
%   and sd". It does not: the second output is the per-group suppressed
%   powers, not a standard deviation. Nothing here computes a standard
%   deviation.
%
%   See also lib.EDGE_FIT_COST, lib.EDGE, lib.EDGE_MEASURES_IDEAL.

    % suppress weak edge strengths
    edge_power_suppressed = log((exp(group_edge_powers) + exp(threshold))/(1 + exp(threshold)));
    group_strengths = group_lengths.*edge_power_suppressed;  % edge group strengths
    response = sum(group_strengths)/(numel(group_edge_powers) + group_count_offset);
    %     e_sup(isinf(e_sup))=e_tot(isinf(e_sup))-log(1+k);
    %     r=mean(e_sup);
end
