function [ptchout,mnv] = ptch_norm(ptch,m0,c0,ntype)
%
% normalize patch
% m0 = desired mean
% c0 = desired contrast
% ntype = type of normalization
% (0 = none 1 = mean, 2 = mean and contrast, 3 = mean for color image)
%
mnv = zeros(3,1);
if ntype == 1
  mnv(1) = mean(mean(ptch));               % mean    
  ptchout = ptch*m0/mnv(1);                % normalize to mean of m0
elseif ntype == 2 
  mnv(1) = mean(mean(ptch));               % mean
  sd = sqrt(sum(sum((ptch-m).^2)));        % standard deviation
  ptch = c0*m*(ptch-mnv(1))/sd + mnv(1);   % normalize to contrast of c0
  ptchout = ptch*m0/mnv(1);                     % normalize to mean of m0
elseif ntype == 3
  ptchout = ptch;
  mnv(1) = mean(mean(ptch(:,:,1)));        % mean    
  ptchout(:,:,1) = ptch(:,:,1)*m0/mnv(1);  % normalize to mean of m0    
  mnv(2) = mean(mean(ptch(:,:,2)));        % mean    
  ptchout(:,:,2) = ptch(:,:,2)*m0/mnv(2);  % normalize to mean of m0    
  mnv(3) = mean(mean(ptch(:,:,3)));        % mean    
  ptchout(:,:,3) = ptch(:,:,3)*m0/mnv(3);  % normalize to mean of m0    
elseif ntype == 0
  ptchout = ptch;                     % no normalization
end
%
end