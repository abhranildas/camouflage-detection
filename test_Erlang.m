close all;
clear all;
l1 = 1/300;
l2 = 1/10;
xmx = 1500;
x = 1:xmx/1000:xmx;
y = (exp(-l1*x) - exp(-l2*x))*l2*l1/(l2-l1);
plot(x,y);