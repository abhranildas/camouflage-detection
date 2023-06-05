function z = csf_fitted(u)
% ATF based on Watson's descriptive OTF
% u = vector of frequencies c/deg

n = 2; d = 4; w = 555;
a = 0.8563; b = 0.1516; c = 0.0651;
p=[a b c];

z = lib.csf_floating(p,u,d,w,n);
end

