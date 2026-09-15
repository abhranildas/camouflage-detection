% +main  (package namespace: experiment.main.*)
% Psychtoolbox/EyeLink runtime for a single experiment session: the interval
% functions (fixation, stimulus, response, feedback, level-start display)
% wired as hooks into vislab.psychframework.run_experiment by
% runCamouflageExperiment, plus the self-contained search/detect variant
% runCamouflageExperiment_search and the EyeLink configuration helper.
%
% Call functions as experiment.main.<function>. Requires the repo root on
% the MATLAB path (see setup.m) and Psychtoolbox (+ EyeLink for peripheral /
% non-foveal runs).
%
% testscripts/ holds ad-hoc, non-runnable scratch scripts for manual display
% testing; they are not part of the live path.

