function M = watson_otf(u,d,lambda)
  % Watson's descriptive Optical Transfer Function
  % u = vector of frequencies c/deg
  % d = pupil diameter mm
  % lambda = wavelength nm
  %
  u0 = d*pi*1e6/(lambda*180);
  uh = u/u0;
  D = (acos(uh) - uh.*sqrt(1-uh.^2))*2/pi;
  u1 = 21.95 - 5.512*d + 0.3922*d^2;
  M = sqrt(D).*(1 + (u/u1).^2).^(-0.62);
end

