function [f_z,z]=pink_noise_1D_dist(log_kmin,log_kmax,d_logk)
z1_range=1/(10^log_kmin);
dz=z1_range/100;
z1=-z1_range:dz:z1_range;

f_z=1;
for k=10.^(log_kmin:d_logk:log_kmax)
    % distribution of k-frequency sine
    zk=z1(abs(z1)<1/sqrt(k));
    f_zk=1./(pi*(sqrt(1-k*zk.^2)));
    % normalize:
    f_zk=f_zk/sum(f_zk);    
    % convolve with previous distribution:
    f_z=conv(f_z,f_zk); 
end

% normalize to unit area:
f_z=f_z/dz;

% set up support of the distribution:
z_num=(numel(f_z)-1)/2;
z=-z_num*dz:dz:z_num*dz;