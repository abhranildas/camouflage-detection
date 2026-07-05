function output = find_spot_centers(centers, origin, spotLength, spotDistance, totalLength, nDirections)

for ang = 0:360 / nDirections:359.9
    candidate = [round(origin(1)+spotDistance*sin(ang*pi/180)), round(origin(2)+spotDistance*cos(ang*pi/180))]; % ij coordinates
    if (candidate(1) - totalLength/2)^2 + (candidate(2) - totalLength/2)^2 > ((totalLength-spotLength)/2)^2
        continue;
    elseif ismember(candidate, centers,'row')
        continue;
    else
        centers(end+1,:) = candidate;
        centers = lib.find_spot_centers(centers, candidate, spotLength, spotDistance, totalLength, nDirections);
    end
end

output = centers;