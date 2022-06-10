function [r,e_sup]=edge_response(l,e,th,n)
    % given number of edge groups, their lengths and mean edge power,
    % and the fit parameters, compute the edge response mean and sd
    
    e_sup=log((exp(e)+exp(th))/(1+exp(th))); % suppress weak edge strengths
    g=l.*e_sup; % edge group strengths
    r=sum(g)/(numel(e)+n);
    %     e_sup(isinf(e_sup))=e_tot(isinf(e_sup))-log(1+k);
    %     r=mean(e_sup);