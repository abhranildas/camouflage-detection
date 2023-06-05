function Reout = Re(ptch1,ptch2,psz,ks,nks,thresh)
%
% edge similarity response
%
% ptch1 & ptch2 = two patches that are compared
% psz = patch size
% ks = kernal filter size
% nks = number of kernals
% thres = gradient threshold
%
% normalize patches to have same mean and standard deviation
% cntr1 = zeros(200,psz^2);
ptch1 = ptch1*128/mean(mean(ptch1)) - 128;
ptch2 = ptch2*128/mean(mean(ptch2)) - 128;
sd1 = sqrt(sum(sum(ptch1.*ptch1))/psz^2);
sd2 = sqrt(sum(sum(ptch2.*ptch2))/psz^2);
ptch1 = ptch1*42/sd1 + 128;
ptch2 = ptch2*42/sd2 + 128;
% find zero crossings
zc1 = edge(ptch1,'log',0,ks);
zc2 = edge(ptch2,'log',0,ks);
%
% compute image gradient magnitude and direction
[gm1,gd1] = imgradient(ptch1);
[gm2,gd2] = imgradient(ptch2);
%
% find gradient magnitudes at zero crossings
gm1 = gm1.*zc1;
gm2 = gm2.*zc2;
%
% threshold zero crossings based on gradient magnitude
for i = 1:psz
  for j = 1:psz
    if gm1(i,j) < thresh
       gm1(i,j) = 0;
       zc1(i,j) = 0;
       gd1(i,j) = 0*nks;
    end
    if gm2(i,j) < thresh
       gm2(i,j) = 0;
       zc2(i,j) = 0;
       gd2(i,j) = 0;
    end
  end
end
%
% find contours and contour properties for patch 1
mxpx = 500;
cc = bwconncomp(zc1);
lcc1 = labelmatrix(cc);
nc1 = cc.NumObjects;         % number of contours
npx = zeros(nc1,1);
ei = zeros(nc1,mxpx);
ej = zeros(nc1,mxpx);
for i = 1:psz
  for j = 1:psz
    en = lcc1(i,j);
    if en > 0
      npx(en) = npx(en) + 1;  % number of pixels in contour
      ei(en,npx(en)) = i;     % contour pixel i coorinate
      ej(en,npx(en)) = j;     % contour pixel j coordinate
    end
  end
end
cntdif = 0; sdgd = 0; sumpix = 0;
for k = 1:nc1
  [contour,lnks,ncon] = mk_contour(npx(k),ei(k,:),ej(k,:));
  if ncon < npx(k)
    cntdif = cntdif + 1;
  end
  for i = 1:ncon-1
    y = ei(k,contour(i));     % coordinates of pixel i
    x = ej(k,contour(i));
    yp1 = ei(k,contour(i+1)); % coordinates of pixel i+1
    xp1 = ej(k,contour(i+1));
    cosdgd = sind(gd1(x,y))*sind(gd1(xp1,yp1)) +...  % cosine of orien diff
             cosd(gd1(x,y))*cosd(gd1(xp1,yp1));
    sdgd = sdgd + acosd(cosdgd);     % sum of orientation differences
    sumpix = sumpix + 1;
  end
end
mdgd1 = sdgd/sumpix;
%
% find contours and contour properties for patch 2
mxpx = 500;
cc = bwconncomp(zc2);
lcc2 = labelmatrix(cc);
nc2 = cc.NumObjects;         % number of contours
npx = zeros(nc2,1);
ei = zeros(nc2,mxpx);
ej = zeros(nc2,mxpx);
for i = 1:psz
  for j = 1:psz
    en = lcc2(i,j);
    if en > 0
      npx(en) = npx(en) + 1;  % number of pixels in contour
      ei(en,npx(en)) = i;     % contour pixel i coorinate
      ej(en,npx(en)) = j;     % contour pixel j coordinate
    end
  end
end
cntdif = 0; sdgd = 0; sumpix = 0;
for k = 1:nc1
  [contour,lnks,ncon] = mk_contour(npx(k),ei(k,:),ej(k,:));
  if ncon < npx(k)
    cntdif = cntdif + 1;
  end
  for i = 1:ncon-1
    y = ei(k,contour(i));     % coordinates of pixel i
    x = ej(k,contour(i));
    yp1 = ei(k,contour(i+1)); % coordinates of pixel i+1
    xp1 = ej(k,contour(i+1));
    cosdgd = sind(gd2(x,y))*sind(gd2(xp1,yp1)) +...  % cosine of orien diff
             cosd(gd2(x,y))*cosd(gd2(xp1,yp1));
    sdgd = sdgd + acosd(cosdgd);     % sum of orientation differences
    sumpix = sumpix + 1;
  end
end
mdgd2 = sdgd/sumpix;
%
% find contours and contour properties for patch 2
% cc = bwconncomp(zc2);
% lcc2 = labelmatrix(cc);
% nc2 = cc.NumObjects;         % number of contours
% eps2 = zeros(nc2,7);
% for i = 1:psz
%   for j = 1:psz
%     en = lcc2(i,j);
%     if en > 0
%       eps2(en,1) = eps2(en,1) + 1; % number of pixels in contour
%       eps2(en,2) = eps2(en,2) + gm2(i,j);   % gradient magnitude
%       eps2(en,3) = eps2(en,3) + gm2(i,j)^2; % gradient magnitude squared
%     end
%   end
% end
% for i = 1:nc2
%   eps2(i,2) = eps2(i,2)/eps2(i,1);
%   eps2(i,3) = eps2(i,3)/eps2(i,1);
% end
% ml1 = mean(eps1(:,1));
% ml2 = mean(eps2(:,1));
% mg1 = mean(eps1(:,2));
% mg2 = mean(eps2(:,2));
% msg1 = mean(eps1(:,3));
% msg2 = mean(eps2(:,3));
% vg1 = msg1 - mg1^2;
% vg2 = msg2 - mg2^2;

% figure; colormap(gray(256)); image(ptch1); axis image;
% figure; colormap(gray(256)); image(ptch2); axis image;
% figure; colormap(gray(256)); image(zc1*255); axis image;
% figure; colormap(gray(256)); image(gm1); axis image;
% figure; colormap(gray(256)); image(zc2*255); axis image;
% figure; colormap(gray(256)); image(gm2); axis image;
Reout = mdgd2-mdgd1;
end

