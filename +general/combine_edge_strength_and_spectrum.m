%% Combine edge strength and edge shape to Gaussian LLR

% Combine the edge strength and edge spectrum decision variables
% into one decision variable, by fitting 2D gaussians to the
% blank and target distributions of (edge strength, edge spectrum),
% then computing the log likelihood ratio.
% This requires having labelled (blank/target) observations.

% Pink
load('vislab-common/data/edge_strengths.mat')
load('vislab-common/data/edge_spectra_LLR.mat','edge_spectra_LLR_pink')

% blank gaussian
x_b=[edge_strengths(:,2),edge_spectra_LLR_pink(:,2)];
mu_b=mean(x_b);
v_b=cov(x_b);

% target gaussian
x_t=[edge_strengths(:,3),edge_spectra_LLR_pink(:,3)];
mu_t=mean(x_t);
v_t=cov(x_t);

% log likelihood ratio of data
l_b=lib.gauss_llr(x_b,mu_t,v_t,mu_b,v_b);
l_t=lib.gauss_llr(x_t,mu_t,v_t,mu_b,v_b);

% error and d'
results_llr=bayes_classify(l_b,l_t,'type','obs');

% White
load('vislab-common/data/edge_strengths_whitened.mat')
load('vislab-common/data/edge_spectra_LLR.mat','edge_spectra_LLR_white')

% blank gaussian
x_b_w=[edge_strengths_w(:,2),edge_spectra_LLR_white(:,2)];
mu_b_w=mean(x_b_w);
v_b_w=cov(x_b_w);

% target gaussian
x_t_w=[edge_strengths_w(:,3),edge_spectra_LLR_white(:,3)];
mu_t_w=mean(x_t_w);
v_t_w=cov(x_t_w);

% log likelihood ratio of data
l_b_w=lib.gauss_llr(x_b_w,mu_t_w,v_t_w,mu_b_w,v_b_w);
l_t_w=lib.gauss_llr(x_t_w,mu_t_w,v_t_w,mu_b_w,v_b_w);

% error and d'
results_llr_w=bayes_classify(l_b_w,l_t_w,'type','obs');

%% Combine edge strength and edge shape for maximum reliability
% using the method of
% 'Weighted linear cue combination with possibly correlated error'
% by Oruc et al.
% This does not require labelled observations.

% Pink
edge_strengths_all=[edge_strengths(:,2);edge_strengths(:,3)];
edge_spectra_all=[edge_spectra_LLR_pink(:,2);edge_spectra_LLR_pink(:,3)];

r_edge_strength=1/var(edge_strengths_all);
r_edge_spectrum=1/var(edge_spectra_all);

rho=corr(edge_strengths_all,edge_spectra_all);

w=[r_edge_strength-rho*sqrt(r_edge_strength*r_edge_spectrum);...
r_edge_spectrum-rho*sqrt(r_edge_strength*r_edge_spectrum)];

r_b=x_b*w;
r_t=x_t*w;

% error and d'
results_rel=bayes_classify(r_b,r_t,'type','obs');

% White
edge_strengths_all_w=[edge_strengths_w(:,2);edge_strengths_w(:,3)];
edge_spectra_all_w=[edge_spectra_LLR_white(:,2);edge_spectra_LLR_white(:,3)];

r_edge_strength_w=1/var(edge_strengths_all_w);
r_edge_spectrum_w=1/var(edge_spectra_all_w);

rho_w=corr(edge_strengths_all_w,edge_spectra_all_w);

w_w=[r_edge_strength_w-rho_w*sqrt(r_edge_strength_w*r_edge_spectrum_w);...
r_edge_spectrum_w-rho_w*sqrt(r_edge_strength_w*r_edge_spectrum_w)];

r_b_w=x_b_w*w_w;
r_t_w=x_t_w*w_w;

% error and d'
results_rel_w=bayes_classify(r_b_w,r_t_w,'type','obs');


