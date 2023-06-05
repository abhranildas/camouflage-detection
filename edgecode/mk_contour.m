function [contour,lnks,ncon] = mk_contour(npx,y,x)
    % finds a contour from a list of edge pixels
    %
    % npx = number of pixels in the list
    % y = vertical coordinates
    % x = horixontal coordinates
    %
    lnks = zeros(npx,npx); contour = zeros(npx,1);
    %
    % create link map
    for i = 1:npx
        for j = i+1:npx
            if (x(i)-x(j))^2 + (y(i)-y(j))^2 <= 2
                lnks(i,j) = 1; lnks(j,i) = 1;
            end
        end
    end
    %
    % find first row with only one link
    i = 0;
    nlnk = 2;
    while nlnk > 1
        i = i+1;
        nlnk = sum(lnks(i,:));
    end
    %
    % make contour
    ncon = 1; contour(ncon) = i;
    i1 = i; i0 = 0;
    while i1 ~= i0
        j = 1; i0 = i1;
        while (i1 == i0) && (j <= npx)
            if lnks(i1,j) == 1
                i1 = j;
                lnks(i0,j) = 0;
                lnks(j,i0) = 0;
                ncon = ncon + 1;
                contour(ncon) = j;
            end
            j = j+1;
        end
    end
end

