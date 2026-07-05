function z = csf_floating(p,u,d,w,n)
  % ATF based on Watson's descriptive OTF
  % p(1) = a   surround strength
  % p(2) = b   surround size
  % p(3) = c   center size
  % u = vector of frequencies c/deg
  % d = pupil diameter mm
  % w = wavelength nm
  % n = surround shape exponent
  %
  a = p(1); b = p(2); c = p(3);
  M = lib.watson_otf(u,d,w);  % Watson's OTF
  z = M.*(1-a*exp(-b*u.^n)).*exp(-c*u); % ATF
end

