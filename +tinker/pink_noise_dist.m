function [f_z,z]=pink_noise_dist(dim,klist,d_alph)
z1_range=1/klist(1);
dz=z1_range/100;
z1=-z1_range:dz:z1_range;

f_z=1;
for k=klist
    % distribution of k-frequency sine
    zk=z1(abs(z1)<k^(-dim/2));
    f_zk=1./(pi*(sqrt(1-(zk*k^(dim/2)).^2)));
    % normalize:
    f_zk=f_zk/sum(f_zk);
    if dim==2
        for alph=0:d_alph:2*pi
            % convolve with previous distribution:
            f_z=conv(f_z,f_zk);
        end
    elseif dim==1
        f_z=conv(f_z,f_zk);
    end
end

% normalize to unit area:
f_z=f_z/dz;

% set up support of the distribution:
z_num=(numel(f_z)-1)/2;
z=-z_num*dz:dz:z_num*dz;