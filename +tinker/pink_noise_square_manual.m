function img=pink_noise_square_manual(len,klist,d_alph)
img=zeros(len);
x=repmat(1:len,[len,1]);
y=x';

for k=klist % component frequency
    for alph=0:d_alph:2*pi % component direction
        u=k*cos(alph); v=k*sin(alph); % x and y freqs of component
        phi=unifrnd(0,2*pi);
        wave=sin(u*x+v*y+phi)/k;
        img=img+wave;
    end
end


