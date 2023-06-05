function Rh = Rh(ptch1,ptch2,edges)
% gray-scale histogram difference response
%
% edge bin bounds for histogram
%
N1 = histcounts(ptch1,edges);
N2 = histcounts(ptch2,edges);
n = size(N1,2);
snum = 0;
sden = 0;
for i = 1:n
  if N1(i) > 0
    snum = snum + N1(i)*log(N1(i)/n); 
  end
  if N2(i) > 0
    snum = snum + N2(i)*log(N2(i)/n); 
  end
  if (N1(i) + N2(i)) > 0
    sden = sden + (N1(i)+N2(i))*log((N1(i)+N2(i))/(2*n)); 
  end
end
%
Rh = snum-sden;
end

