function spot_centers = find_spot_centers(centers, origin, spot_length, spot_distance, ...
    total_length, n_directions)
% FIND_SPOT_CENTERS  Recursively places non-overlapping spot centers around an origin.
%   spot_centers = lib.find_spot_centers(centers, origin, spot_length, spot_distance, ...
%       total_length, n_directions)
%
%   See B3.5 in the plan: the ismember check below passes 'row' (singular),
%   but the valid flag is 'rows', so the row-wise membership test silently
%   does something else. Not fixed here (Stage 1 is behaviour-preserving).
%
%   Output
%     spot_centers - centers, extended with every new spot center found.
%
%   See also ISMEMBER, experiment.SET_UP_EXPERIMENT_SEARCH.

    for angle_deg = 0:360/n_directions:359.9
        candidate_center = [round(origin(1)+spot_distance*sin(angle_deg*pi/180)), ...
            round(origin(2)+spot_distance*cos(angle_deg*pi/180))];   % ij coordinates
        if (candidate_center(1) - total_length/2)^2 + (candidate_center(2) - total_length/2)^2 ...
                > ((total_length-spot_length)/2)^2
            continue;
        elseif ismember(candidate_center, centers, 'row')
            continue;
        else
            centers(end+1, :) = candidate_center;
            centers = lib.find_spot_centers(centers, candidate_center, spot_length, ...
                spot_distance, total_length, n_directions);
        end
    end

    spot_centers = centers;
end
