function e = csf_err(p,u,d,w,n,z0)
  % ATF based on Watson's descriptive OTF
  % p(1) = a   surround strength
  % p(2) = b   surround size
  % p(3) = c   center size
  % p(4) = s   scalar
  % u = vector of frequencies c/deg
  % d = pupil diameter mm
  % w = wavelength nm
  % n = surround shape exponent
  % z0 = human atf values
  %
  z = lib.csf_floating(p,u,d,w,n);
  z = z/max(z);
%   sz = size(z);
%   for i = 1:sz(2)
%     if z(i) <= 0
%       z(i) = 10^-20;
%     end
%   end
  e = sum((log(z)-log(z0)).^2);
end

