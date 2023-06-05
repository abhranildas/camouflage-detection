exp_list=dir(['exp_files/shape_exponent/']);
exp_list={exp_list(3:end).name};
for i_exp=1:length(exp_list)
    subj_list=dir(['exp_files/shape_exponent/' exp_list{i_exp} '/subject_out/*.mat']);
    correct=nan()
    for i_subj=1:length(subj_list)
    load(['exp_files/shape_exponent/' exp_list{i_exp} '/subject_out/' subj_list(i_subj).name])
    end
end