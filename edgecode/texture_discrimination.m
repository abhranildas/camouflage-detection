%
% texture discrimination
clear all;
close all;
rng(0);
% rng(33);
%
% constants and parameters
sz = 640;               % texture image size
nimgk = 20; nimgj = 20; % number of textures (even numbers, nimgk >= nimgj)
psz = 64;               % patch size
mnk = 1;  mnj = 1;      % first texture numbers
ntrl = 40;              % number of trials per texture pair
b = 10;                 % weak power suppression parameter
bw = 4;                 % histogram bin width parameter, power of 2
r = 32; shp = 2;        % window size (if r = psz/2 flat) and shape
% win = mk_win(psz,r,shp); % make raised-cosine-boundary window
ks = 2; nks = 1; thresh = 100; % edge paramters
%
% trial storage
nall = (nimgk*nimgj/2 - nimgk/2)*ntrl;
rpd = zeros(nimgk,nimgj,ntrl);  % power spectrum
rhd = zeros(nimgk,nimgj,ntrl);  % gray level histogram
rsd = zeros(nimgk,nimgj,ntrl);  % spatial pattern
red = zeros(nimgk,nimgj,ntrl);  % edges
rps = zeros(nimgk,nimgj,ntrl);
rhs = zeros(nimgk,nimgj,ntrl);
rss = zeros(nimgk,nimgj,ntrl);
res = zeros(nimgk,nimgj,ntrl);
vrpd = zeros(nall,1);
vrhd = zeros(nall,1);
vrsd = zeros(nall,1);
vrps = zeros(nall,1);
vrhs = zeros(nall,1);
vrss = zeros(nall,1);
%
% means storage 
mpd = zeros(nimgk,nimgj);
mhd = zeros(nimgk,nimgj);
msd = zeros(nimgk,nimgj);
mps = zeros(nimgk,nimgj);
mhs = zeros(nimgk,nimgj);
mss = zeros(nimgk,nimgj);
%
% standard deviations storage
sdpd = zeros(nimgk,nimgj);
sdhd = zeros(nimgk,nimgj);
sdsd = zeros(nimgk,nimgj);
sdps = zeros(nimgk,nimgj);
sdhs = zeros(nimgk,nimgj);
sdss = zeros(nimgk,nimgj);
%
% dprimes
dp = zeros(nimgk,nimgj);
dh = zeros(nimgk,nimgj);
ds = zeros(nimgk,nimgj);
%
% create histogram edges
nbin = 256/bw;
edges = zeros(nbin,1); % histogram edges
for i = 1:nbin+1
  edges(i) = (i-1)*bw;
end
%
% different trials
n = 1;
for k = 1:nimgk
  num = num2str(k-1+mnk);
  name = append('B',num,'.gif');
  imgk = imread(name);
  for j = k+1:nimgj
    num = num2str(j-1+mnj);
    name = append('B',num,'.gif');
    imgj = imread(name);
    i = 1;
    while i <= ntrl
%
% texture patch k
      x = randi(sz-psz);
      y = randi(sz-psz);
      ptch1 = double(imgk(x:x+psz-1,y:y+psz-1));
%       mptch = mean(mean(ptch1));
%       ptch1 = (ptch1-mptch).*win + mptch;
%       figure; colormap(gray(256)); image(ptch1); axis image;
%
% texture patch j
      x = randi(sz-psz);
      y = randi(sz-psz);
      ptch2 = double(imgj(x:x+psz-1,y:y+psz-1));
%       mptch = mean(mean(ptch2));
%       ptch2 = (ptch2-mptch).*win + mptch;
%     figure; colormap(gray(256)); image(ptch2); axis image;
%
% compute responses
      rpd(k,j,i) = Rp(ptch1,ptch2,b,psz,win);
      rhd(k,j,i) = Rh(ptch1,ptch2,edges);
      rsd(k,j,i) = Rs(ptch1,ptch2,psz);
      red(k,j,i) = Re(ptch1,ptch2,psz,ks,nks,thresh);
      vrpd(n,1) = log(rpd(k,j,i));
      vrhd(n,1) = log(rhd(k,j,i));
      vrsd(n,1) = log(rsd(k,j,i));
%       vrpd(n,1) = rpd(k,j,i);
%       vrhd(n,1) = rhd(k,j,i);
%       vrsd(n,1) = rsd(k,j,i);
      if (vrhd(n,1) > -10) && (vrpd(n,1) > -10)
        i = i + 1;
        n = n+1;
      end
    end
  end
end
%
% same trials
n = 1;
for k = 1:nimgk
  num = num2str(k-1+mnk);
  name = append('B',num,'.gif');
  imgk = imread(name);
  imgj = imgk;  % make image j the same as image k
  for j = k+1:nimgj
    i = 1;
    while i <= ntrl
%
% texture patch k
      x = randi(sz-psz);
      y = randi(sz-psz);
      ptch1 = double(imgk(x:x+psz-1,y:y+psz-1));
%       mptch = mean(mean(ptch1));
%       ptch1 = (ptch1-mptch).*win + mptch;
%     figure; colormap(gray(256)); image(ptch1); axis image;
%
% texture patch j
      x = randi(sz-psz);
      y = randi(sz-psz);
      ptch2 = double(imgj(x:x+psz-1,y:y+psz-1));
%       mptch = mean(mean(ptch2));
%       ptch2 = (ptch2-mptch).*win + mptch;
%     figure; colormap(gray(256)); image(ptch2); axis image;
%
% compute responses
      rps(k,j,i) = Rp(ptch1,ptch2,b,psz,win);
      rhs(k,j,i) = Rh(ptch1,ptch2,edges);
      rss(k,j,i) = Rs(ptch1,ptch2,psz);
      vrps(n,1) = log(rps(k,j,i));
      vrhs(n,1) = log(rhs(k,j,i));
      vrss(n,1) = log(rss(k,j,i));
%       vrps(n,1) = rps(k,j,i);
%       vrhs(n,1) = rhs(k,j,i);
%       vrss(n,1) = rss(k,j,i);
      if (vrhs(n,1) > -10) && (vrps(n,1) > -10)
        i = i + 1;
        n = n+1;
      end
    end
  end
end
%
% compute means, standard deviations, and dprimes
dpavep = 0;
dpaveh = 0;
dpaves = 0;
ndp = 0;
for k = 1:nimgk
  for j = k+1:nimgj
    mpd(k,j) = mean(rpd(k,j,:));
    mhd(k,j) = mean(rhd(k,j,:));
    msd(k,j) = mean(rsd(k,j,:));
    mps(k,j) = mean(rps(k,j,:));
    mhs(k,j) = mean(rhs(k,j,:));
    mss(k,j) = mean(rss(k,j,:));
    sdpd(k,j) = std(rpd(k,j,:));
    sdhd(k,j) = std(rhd(k,j,:));
    sdsd(k,j) = std(rsd(k,j,:));
    sdps(k,j) = std(rps(k,j,:));
    sdhs(k,j) = std(rhs(k,j,:));
    sdss(k,j) = std(rss(k,j,:));
    dp(k,j) = 2*abs(mpd(k,j)-mps(k,j))/(sdpd(k,j)+sdps(k,j));
    dh(k,j) = 2*abs(mhd(k,j)-mhs(k,j))/(sdhd(k,j)+sdhs(k,j));
    ds(k,j) = 2*abs(msd(k,j)-mss(k,j))/(sdsd(k,j)+sdss(k,j));
    if dp(k,j) > 0
      dpavep = dpavep + dp(k,j);
      dpaveh = dpaveh + dh(k,j);
      dpaves = dpaves + ds(k,j);
      ndp = ndp + 1;
    end
  end
end
dpavep = dpavep/ndp;
dpaveh = dpaveh/ndp;
dpaves = dpaves/ndp;
figure; plot(dp,dh,'ko');
xlabel('d-prime power spectrum cue');
ylabel('d-prime histogram cue');
figure; plot(dp,ds,'ko');
xlabel('d-prime power spectrum cue');
ylabel('d-prime spatial similarity cue');
%
% analysis of Rp
rsm = mean(vrps); rssd = std(vrps);
rdm = mean(vrpd); rdsd = std(vrpd);
dpp = 2*(rdm - rsm)/(rssd + rdsd);
% vrps = (vrps-rsm)/rssd; vrpd = (vrpd-rsm)/rssd;
figure; h1 = histogram(vrps); hold on; h2 = histogram(vrpd);
h1.Normalization = 'probability'; h1.BinWidth = 0.25;
h2.Normalization = 'probability'; h2.BinWidth = 0.25;
xlabel('normalized log power decision variable');
ylabel('probability');
%
% analysis of Rh
rsm = mean(vrhs); rssd = std(vrhs);
rdm = mean(vrhd); rdsd = std(vrhd);
dph = 2*(rdm - rsm)/(rssd + rdsd);
% vrhs = (vrhs-rsm)/rssd; vrhd = (vrhd-rsm)/rssd;
figure; h1 = histogram(vrhs); hold on; h2 = histogram(vrhd);
h1.Normalization = 'probability'; h1.BinWidth = 0.25;
h2.Normalization = 'probability'; h2.BinWidth = 0.25;
xlabel('normalized log histogram decision variable');
ylabel('probability');
%
% analysis of Rs
rsm = mean(vrss); rssd = std(vrss);
rdm = mean(vrsd); rdsd = std(vrsd);
dps = 2*(rdm - rsm)/(rssd + rdsd);
% vrhs = (vrhs-rsm)/rssd; vrhd = (vrhd-rsm)/rssd;
figure; h1 = histogram(vrss); hold on; h2 = histogram(vrsd);
h1.Normalization = 'probability'; h1.BinWidth = 0.15;
h2.Normalization = 'probability'; h2.BinWidth = 0.15;
xlabel('normalized log similarity decision variable');
ylabel('probability');
%
% analysis of combined cues
% figure; scatter(vrps,vrhs); hold on; scatter(vrpd,vrhd);
results =  classify_normals([vrps,vrhs],[vrpd,vrhd],...
    'input_type','samp');
results =  classify_normals([vrps,vrss],[vrpd,vrsd],...
    'input_type','samp');
results =  classify_normals([vrhs,vrss],[vrhd,vrsd],...
    'input_type','samp');
results =  classify_normals([vrps,vrhs,vrss],[vrpd,vrhd,vrsd],...
    'input_type','samp');
% %
% % find criteria the minimize errors
% z0 = zeros(2,1); z0(1) = 0.6; z0(2) = 4;
% z = z0;
% errmin = err_min(z,vrps,vrpd,vrhs,vrhd,nall);
% zmin = z;
% for i = 1:200
%   z(1) = i*0.05;
%   for j = 1:200
%      z(2) = j*0.05;
%      err = err_min(z,vrps,vrpd,vrhs,vrhd,nall);
%      if err < errmin
%          errmin = err;
%          zmin = z;
%      end
%   end
% end
% err = err_min(zmin,vrps,vrpd,vrhs,vrhd,nall);
% err0 = err_min(z0,vrps,vrpd,vrhs,vrhd,nall);
% dpall = 2*norminv(1-err);

