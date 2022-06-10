% object with a 1/f^2 boundary spectrum
% at an RMS noise amplitude of 16 pixels

close all;
sz = 513;           % image size
img = zeros(sz,sz);
cen = floor(sz/2)+1;
sza = 2*floor(floor(pi()*sz)/2);
szf = sza/2;
a = zeros(sza,1); r = zeros(sza,1);
f = zeros(szf,1);
for i = 1:sza
  a(i) = ((i-1)/sza)*360;   % angles
end
for i = 1:szf
  f(i) = i/sza;             % frequencies cycles per boundary
end
%
%
r0 = 128;                   % base radius
rsd = 16;                   % standard deviation of boundary modulation
pow = 2;                    % 1/f exponent
% ramp = zeros(szf,1);
% ramp(2) = 0;
% ramp(4) = 8;
% ramp(6) = 8;
ramp = randn(szf,1);
ramp(1) = 0;
for j = 1:szf
  ramp(j) = ramp(j)/j^pow;
end
for j = 1:sza/2
  for i = 1:sza
    r(i) = r(i) + ramp(j)*sin(2*pi()*f(j)*(i-1));
  end
end
r = r*rsd/std(r);
r = r + r0;             % radial amplitude of boundary
%
shftd = randi(360);     % random rotation of object
shft = round(shftd*sza/360);
r = circshift(r,shft);
% figure; plot(a,r,'o');
%
% make indicator function
th = zeros(sz,sz);
for y = 1:sz
  for x = 1:sz
    th(x,y) = atan2d(y-cen,x-cen);
    if th(x,y) < 0
      th(x,y) = th(x,y) + 360;
    end
    i = floor(th(x,y)*sza/360) + 1;
    rr = sqrt((x-cen)^2 + (y-cen)^2);
    if rr < r(i)
      img(x,y) = 1;
    end
  end
end
img(cen,cen) = 0;       % plot the center of the image
figure; colormap(gray(256)); image(img*255); axis image;

