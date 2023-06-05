%
% fit_atf
  % ATF includes Watson OTF, aperture, generalized-Gaussian surround and
  % center
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
u0 = [0.1,1.12,2,2.83,4,5.66,8,11.3,16,22.6,30];
z0 = [0.25,0.518,0.714,0.905,1.0,0.768,0.546,0.327,0.155,0.0713,0.0289];
loglog(u0,z0,'o'); hold on;
%
p0 = [0.85; 0.1; 0.065];
n = 2;
d = 4;
w = 555;
f = @(p) lib.csf_err(p,u0,d,w,n,z0);
p_fit = fmincon(f,p0,[],[],[],[],[0;0;0],[1;1;1]);
u=linspace(min(u0),max(u0),1e3);
z=lib.csf_fitted(u);
z=z/max(z);
% err = 20*sqrt(atf_err(p_fit,u0,d,w,n,z0)/11);
% err0 = 20*sqrt(atf_err(p0,u0,d,w,n,z0)/11);
loglog(u,z,'-');

%% plot CSF spatial filter
ppd=60;
csf_kernel=lib.csf_spatial_filter(ppd);
plot(csf_kernel(128,:))
xlim(128+50*[-1 1]); ylim([-.01 .08])
set(gca,'xtick',[],'ytick',[])
