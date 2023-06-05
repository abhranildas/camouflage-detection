function Rpout = Rp(ptch1,ptch2,b,psz,win)
% power difference response
%
% ptch1 & ptch2 = two patches that are compared
% b = noise suppression constant
% psz = patch size
% win = window function
%
% ptch1
ptch1 = ptch1.*win;
ptch1 = ptch1 - mean(mean(ptch1));
ftim = fftshift(fft2(fftshift(ptch1)));      % fourier transform patch
pim1 = abs(ftim).^2;
pim1 = pim1/mean(mean(pim1)) + b;
%
%   ptch2
ptch2 = ptch2.*win;
ptch2 = ptch2 - mean(mean(ptch2));
ftim = fftshift(fft2(fftshift(ptch2)));       % fourier transform image
pim2 = abs(ftim).^2;
pim2 = pim2/mean(mean(pim2)) + b;
%
% compute power difference measure
pnum = (pim1 + pim2).^2;
pden = 4*pim1.*pim2;
Rpout = sum(sum(log(pnum./pden)))/psz^2;
%
end

