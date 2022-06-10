subj_id=3; % 0 for optimal

% Load edge model data
load('global_data/edge_model.mat','edge_model');

[~,~,~,bdry_strip]=lib.target_mask();
n_bdry_pixels=nnz(bdry_strip); % number of boundary pixels

sig_n_init=1;
init=[sig_n_init];
options=optimset('PlotFcns',@optimplotfval);
if subj_id==0
    params=fminsearch(@(p) compute_nll_edge_model(p,target,bOpt),init,options);
else
    params=fminsearch(@(p) general.compute_nll_edge_model(p,edge_model,n_bdry_pixels,subj_id),init,options);
end
sig_n=params(1);

%% Plot psychometric function
figure; hold on;
if subj_id==0
    [~,p_correct,d] = experiment.analysis.computeNegLogLikelihood_new_edge(params,target,bOpt,edge_measures);
    plot(d, p_correct, 'ok', 'markerfacecolor','k','MarkerSize',5);
else
    [~,~,d_all,responses] = general.compute_nll_edge_model(params,edge_model,n_bdry_pixels,subj_id);
    for exp_id=1:numel(edge_model)
        p_correct=mean(edge_model(exp_id).subject_data(subj_id).correct);
        plot(d_all{exp_id}, p_correct, 'ok', 'markerfacecolor','k','MarkerSize',5);
    end
end
xlimit=xlim; xlim([0 xlimit(2)])
fplot(@(x) experiment.analysis.psychometricFun(x,0,1,1,0),xlim,'k');
xlabel("edge response d'"); ylabel('% correct')
set(gca,'FontSize',13,'TickDir','out','box','off','ytick',[.5 .75 1],'yticklabel',[50 75 100]);

%% Bootstrap
if(bBootstrap)
    n_boot=500;
    pc_boot=nan(n_boot,nLevels); mu_boot=zeros(1,n_boot); a_boot=nan(1,n_boot); b_boot=nan(1,n_boot); c_boot=nan(1,n_boot);
    for iBoot= 1:n_boot
        exp_values_boot=nan(nTrials,nLevels);
        target_means_boot=nan(1,nLevels);
        bTarget_boot=false(nTrials,nLevels);
        hit_boot=false(nTrials,nLevels);
        correct_reject_boot=false(nTrials,nLevels);
        correct_boot=false(nTrials,nLevels);
        for iLevel=1:nLevels
            [exp_level,boot_idx]=datasample(exp_values(:,iLevel),nTrials);
            exp_values_boot(:,iLevel)=exp_level;
            bTarget_level=target(boot_idx',iLevel);
            bTarget_boot(:,iLevel)=bTarget_level;
            target_means_boot(iLevel)=mean(exp_level(bTarget_level));
            hit_boot(:,iLevel)=hit(boot_idx',iLevel);
            correct_reject_boot(:,iLevel)=correct_reject(boot_idx',iLevel);
            correct_boot(:,iLevel)=correct(boot_idx',iLevel);
        end
        num_targets_boot=sum(bTarget_boot);
        num_blanks_boot=sum(~bTarget_boot);
        num_hits_boot=sum(hit_boot);
        num_cr_boot=sum(correct_reject_boot);
        
        pc_boot(iBoot,:)=mean(correct_boot);
        [a_boot(iBoot),b_boot(iBoot),c_boot(iBoot)]=experiment.analysis.fitPsychometric(a,b,c,target_means_boot, num_blanks_boot,num_targets_boot, num_hits_boot, num_cr_boot);
    end
    threshold_boot=mu_boot+a_boot;
    mu_sd=std(mu_boot);
    threshold_sd = std(threshold_boot);
    b_sd = std(b_boot);
    c_sd = std(c_boot);
    pcBoot_sds = std(pc_boot);
    if(bPlot)
        for i=1:length(target_means)
            rectangle('Position',[target_means(i)-target_sds(i), p_correct(i)-pcBoot_sds(i), 2*target_sds(i), 2*pcBoot_sds(i)],...
                'facecolor',[0 0 0 .1], 'edgecolor','none')
        end
    end
    % mark threshold errorband:
    rectangle('Position',[threshold-threshold_sd 0 2*threshold_sd 1],'facecolor',[0 0 0 .1], 'edgecolor','none')
end
