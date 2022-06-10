function [contour_length,contour_normal]=contour_props(cont)
    contour_normal=nan(size(cont));
    % these are choppy 1-point central differences. Could make them
    % smoother with n-point central differences:
    contour_normal(:,1)=gradient(cont(:,1));
    contour_normal(:,2)=gradient(cont(:,2));
    cont_lengths=vecnorm(contour_normal,2,2);
    contour_length=sum(cont_lengths);
    contour_normal=contour_normal./cont_lengths;
    contour_normal(isnan(contour_normal))=0;