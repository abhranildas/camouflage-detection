function [n,xm,ym,xym,x2m,y2m,r]=combine_pairwise_stats(n_l,xm_l,ym_l,xym_l,x2m_l,y2m_l,r_l)
% combines the statistics of several groups of pairwise observations
% to output the statistics of the pooled observations.

% input: 7 lists of the 7 stats (n,xm,ym,xym,x2m,y2m,r) for each group.

% output: combined stats (n,xm,ym,xym,x2m,y2m,r).

n=sum(n_l);
f_l=n_l/sum(n); % relative frequencies (row vector)

xm=dot(f_l,xm_l);
ym=dot(f_l,ym_l);
xym=dot(f_l,xym_l);
x2m=dot(f_l,x2m_l);
y2m=dot(f_l,y2m_l);
r=(xym-xm*ym)/sqrt((x2m-xm^2)*(y2m-ym^2));

