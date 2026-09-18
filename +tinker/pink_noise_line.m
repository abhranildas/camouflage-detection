function y=pink_noise_1D(len,klist)
x=0:len-1;
y=zeros(1,len);
for k=klist
    phi=unifrnd(-pi,pi);
    if ~k
        amp=0;
    else
        amp=1/sqrt(k);
    end
    y_comp= amp * sin(k*x+phi);
    y=y+y_comp;
end