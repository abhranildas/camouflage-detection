% plot_shape_exponent_exps  Load every subject's data for every
%     shape-exponent experiment condition.
%
%     plot_shape_exponent_exps
%
% Script, no arguments. Appears to be an unfinished stub: it loads each
% subject's `SubjectExpFile` but never reads `correct` (declared, never
% assigned) or plots anything, despite the file's name. Left as found.
%
% Inputs: `exp_files/shape_exponent/<condition>/subject_out/*.mat`, one
%     per subject per condition.
% Output: none — nothing is computed, plotted, or saved.
%
% See also general.analyze_shape_exps.

cfg = config();
folder_family = fullfile(cfg.paths.exp_files, 'shape_exponent');
exp_list = dir(folder_family);
exp_list = {exp_list(3:end).name};
for i_exp = 1:length(exp_list)
    subj_list = dir(fullfile(folder_family, exp_list{i_exp}, 'subject_out', '*.mat'));
    correct = nan()
    for i_subj = 1:length(subj_list)
        load(fullfile(folder_family, exp_list{i_exp}, 'subject_out', subj_list(i_subj).name))
    end
end
