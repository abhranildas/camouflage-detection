function Rsout = Rs(ptch1,ptch2,psz)
%
% spatial pattern similarity response
%
% ptch1 & ptch2 = two patches that are compared
% psz = patch size
%
% normalize patches
p1 = ptch1-mean(mean(ptch1));
p2 = ptch2-mean(mean(ptch2));
p1 = p1/sqrt(sum(sum(p1.^2)));
p2 = p2/sqrt(sum(sum(p2.^2)));
%
Rsout = -1;
for dx = 1:psz
 for dy = 1:psz
   p1s = circshift(p1,[dx,dy]);
   sm = sum(sum(p1s.*p2));
   if sm > Rsout
     Rsout = sm;
     dxmx = dx; dymx = dy;
   end
 end
end
p1s = circshift(p1,[dxmx,dymx]);
Rsout = 1/Rsout;
end

