exp_name='pink_noise';

% load edge powers
load(['global_data/edge_powers/' exp_name '.mat'],'edge_powers')

[blank_ep_counts,blank_ep_bins]=histcounts(edge_powers(:,1));
blank_ep_counts=blank_ep_counts/max(blank_ep_counts);

% target histogram
[target_ep_counts,target_ep_bins]=histcounts(edge_powers(:,2));
target_ep_counts=target_ep_counts/max(target_ep_counts);

subj_list=dir(['exp_files/' exp_name '/subject_out/*.mat']);
all_dprimes=nan(size(edge_powers,1),length(subj_list));

for i_subj=1:length(subj_list)
    figure; hold on
    % blank histogram
    histogram('BinEdges',blank_ep_bins,'BinCounts',blank_ep_counts,'facecolor','b','facealpha',0.3,'edgecolor','none')
    % target histogram
    histogram('BinEdges',target_ep_bins,'BinCounts',target_ep_counts,'facecolor','r','facealpha',0.3,'edgecolor','none')

    [~,subj_name]=fileparts(subj_list(i_subj).name)
    % compute pmf parameters
    [th,b,c]=experiment.analysis.computeThreshold_edgePower(exp_name,subj_name,1,0);
    mu=0;
    a=th-mu;
    [~,~,~,dprimes]=experiment.analysis.psychometricFun(edge_powers(:,2),mu,a,b,c);
    all_dprimes(:,i_subj)=dprimes;
    title(sprintf('%s: %s',exp_name,subj_name))
end

all_acc=normcdf(all_dprimes/2);

% mean and sd of pooled accuracy of all stimuli across all subjects
[acc_sd,acc_avg]=std(all_acc(:));
fprintf('%s: %.1f ± %.1f%%\n',exp_name,100*acc_avg,100*acc_sd);
% title(sprintf('%s: %.1f ± %.1f%%',exp_name,100*acc_avg,100*acc_sd))