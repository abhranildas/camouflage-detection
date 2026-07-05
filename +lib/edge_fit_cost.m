function cost=edge_fit_cost(s,dprimes)
cost=0;
for i_exp=1:size(dprimes,1)
    cost=cost+sumsqr(dprimes{i_exp,1}-s*dprimes{i_exp,2});
end
end