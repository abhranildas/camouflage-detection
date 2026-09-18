% +analysis  (package namespace: experiment.analysis.*)
% Psychometric fitting and threshold estimation for camouflage-detection
% session data. The signal-detection model itself is
% experiment.analysis.psychometric_fun (a Weibull d' with an asymmetric
% criterion), fit by experiment.analysis.fit_psychometric via
% experiment.analysis.compute_neg_log_likelihood. The compute_threshold_* family
% wraps that fit for a specific experiment variant (edge power, edge
% response, texture exponent), loading a subject's exp_files/ data and
% optionally bootstrapping standard errors.
%
% Call functions as experiment.analysis.<function>. Requires the repo root
% on the MATLAB path (see setup.m); the compute_threshold_* family also
% requires a completed exp_files/<expType>/ session tree.
%
% Several call sites in this package reference an "analysis.*" or
% "nm.analysis.*" package that does not exist in this repo or a sibling one
% (B2.9, pre-existing, not fixed here) — see the tranche 0.1.5 findings log.
%
% 7 files in this directory are excluded from this package's scope: they
% were renamed with a leading "_" before this cleanup pass began, which
% makes them unresolvable as package members, and are dead code pending a
% Stage 3 decision (S3.6) rather than part of the live path.

