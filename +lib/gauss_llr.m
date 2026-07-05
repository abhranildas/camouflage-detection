function l=gauss_llr(x,mu_a,v_a,mu_b,v_b)
% Log likelihood ratio of observation x belonging to
% gaussian a vs gaussian b.
l=(lib.maha_dist(x,mu_b,v_b) - lib.maha_dist(x,mu_a,v_a)...
    + log(det(v_b)/det(v_a)))/2;