% analyze_shape_expts  Plot accuracy vs. target boundary shape exponent,
%     for five near-1 exponents plus a circular-target baseline.
%
%     analyze_shape_expts
%
% Script, no arguments. Loads one subject's `SubjectExpFile` for the
% circular-target condition and for each of five `shape_exponent`
% conditions (0.8, 0.9, 1, 1.1, 1.2), computes accuracy and its
% binomial-SEM error bar at each boundary-shape exponent tested within a
% condition, and overlays all five error-bar series plus the circular
% baseline (plotted at exponent 3, off the exponent axis, as a reference
% point) on one axes.
%
% Inputs: `exp_files/texture_exponent/ecc_0/subject_out/neel.mat` and
%     `exp_files/shape_exponent/{0.8,0.9,1,1.1,1.2}/subject_out/neel.mat`,
%     each supplying `SubjectExpFile.correct` (trials x sessions,
%     dimensionless 0/1).
% Output: one figure, accuracy (proportion correct, dimensionless) vs.
%     boundary shape exponent (dimensionless), one color per condition.
%     Nothing is saved to disk.
%
% See also general.plot_shape_exponent_exps, general.compute_avg_acc_for_texture.

hold on

% circle experiments
load('exp_files/texture_exponent/ecc_0/subject_out/neel.mat')
accuracy_circ = mean(SubjectExpFile.correct, [1 3]);
accuracy_circ = [accuracy_circ([5 6 7 8]) .9898];
% the last accuracy value here for exponent 1.2 is extracted from the
% psychometric fit
accuracy_circ_sd = sqrt(accuracy_circ.*(1-accuracy_circ)/ ...
    (size(SubjectExpFile.correct, 1)*size(SubjectExpFile.correct, 3)));

% 0.8
load('exp_files/shape_exponent/0.8/subject_out/neel.mat')
exponents_0_8 = linspace(0, 1.6, 7);
accuracy_0_8 = mean(SubjectExpFile.correct, [1 3]);
% accuracy_0_8_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
accuracy_0_8_sd = sqrt(accuracy_0_8.*(1-accuracy_0_8)/ ...
    (size(SubjectExpFile.correct, 1)*size(SubjectExpFile.correct, 3)));
errorbar([exponents_0_8 3], [accuracy_0_8 accuracy_circ(1)], ...
    [accuracy_0_8_sd accuracy_circ_sd(1)], '-om');
% plot(exponents_0_8,accuracy_0_8,'-ok');
xline(0.8, 'm')

% 0.9
load('exp_files/shape_exponent/0.9/subject_out/neel.mat')
exponents_0_9 = sort([linspace(0, 2, 7) [5 7 9]/6]);
accuracy_0_9 = mean(SubjectExpFile.correct, [1 3]);
% accuracy_0_9_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
accuracy_0_9_sd = sqrt(accuracy_0_9.*(1-accuracy_0_9)/ ...
    (size(SubjectExpFile.correct, 1)*size(SubjectExpFile.correct, 3)));
errorbar([exponents_0_9 3], [accuracy_0_9 accuracy_circ(2)], ...
    [accuracy_0_9_sd accuracy_circ_sd(2)], '-ok');
% plot(exponents_0_8,accuracy_0_8,'-ok');
xline(0.9, 'k')

% 1
load('exp_files/shape_exponent/1/subject_out/neel.mat')
exponents_1 = sort([linspace(0, 2, 7) [5 7 9]/6]);
accuracy_1 = mean(SubjectExpFile.correct, [1 3]);
% accuracy_1_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
accuracy_1_sd = sqrt(accuracy_1.*(1-accuracy_1)/ ...
    (size(SubjectExpFile.correct, 1)*size(SubjectExpFile.correct, 3)));
errorbar([exponents_1 3], [accuracy_1 accuracy_circ(3)], ...
    [accuracy_1_sd accuracy_circ_sd(3)], '-ob');
% plot(exponents_1,accuracy_1,'-ob');
xline(1, 'b')

% 1.1
load('exp_files/shape_exponent/1.1/subject_out/neel.mat')
exponents_1_1 = sort([linspace(0, 2.2, 7) .8249 .9166 1.2833]);
accuracy_1_1 = mean(SubjectExpFile.correct, [1 3]);
% accuracy_1_1_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
accuracy_1_1_sd = sqrt(accuracy_1_1.*(1-accuracy_1_1)/ ...
    (size(SubjectExpFile.correct, 1)*size(SubjectExpFile.correct, 3)));
errorbar([exponents_1_1 3], [accuracy_1_1 accuracy_circ(4)], ...
    [accuracy_1_1_sd accuracy_circ_sd(4)], '-or');
% plot(exponents_1_1,accuracy_1_1,'-or');
xline(1.1, 'r')

% 1.2
load('exp_files/shape_exponent/1.2/subject_out/neel.mat')
exponents_1_2 = linspace(0, 2.4, 7);
accuracy_1_2 = mean(SubjectExpFile.correct, [1 3]);
% accuracy_1_2_sd=std(squeeze(mean(SubjectExpFile.correct,1)),0,2)'/sqrt(size(SubjectExpFile.correct,3));
accuracy_1_2_sd = sqrt(accuracy_1_2.*(1-accuracy_1_2)/ ...
    (size(SubjectExpFile.correct, 1)*size(SubjectExpFile.correct, 3)));
errorbar([exponents_1_2 3], [accuracy_1_2 accuracy_circ(5)], ...
    [accuracy_1_2_sd accuracy_circ_sd(5)], '-og');
% plot(exponents_1_2,accuracy_1_2,'-og');
xline(1.2, 'g')
