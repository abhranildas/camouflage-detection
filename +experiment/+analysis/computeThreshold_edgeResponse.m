function [th,n,sigma,threshold_sd, b_sd, c_sd, sessions_completed, target_means, pcBoot_sds, x_pmf, y_pmf] = computeThreshold(expTypeStr, subjectStr, bPlot, bBootstrap)
    
    % Load in experiment settings file
    load(['./exp_files/' expTypeStr '/exp_settings.mat'],'ExpSettings');
    nTrials = ExpSettings.nTrials;
    nLevels = ExpSettings.nLevels;
    
%     stim_n_groups=[];
    stim_l_groups=[];
    stim_e_groups=[];
    bTarget=logical([]);
    
    if strcmp(subjectStr,'optimal')
        bOpt=true;
        completedBinIndex=true(ExpSettings.nSessions,1);
    else
        bOpt=false;
        % Load in subject file
        load(['./exp_files/' expTypeStr '/subject_out/'  subjectStr '.mat'],'SubjectExpFile');
        completedBinIndex = SubjectExpFile.levelCompleted == nLevels;
        sessions_completed=sum(completedBinIndex);
        if(sessions_completed == 0)
            error(['Error: Needed ' num2str(nLevels) ' levels to fit psychometric function.']);
        end
        disp(['Sessions used: ' num2str(sessions_completed)]);
        hit=logical([]);
        correct_reject=logical([]);
        correct=logical([]);
    end
    
    for idx=1:length(completedBinIndex)
        if(completedBinIndex(idx))
%             stim_n_groups=[stim_n_groups; ExpSettings.stim_n_groups(:,:,idx)];
            stim_l_groups=[stim_l_groups; ExpSettings.stim_l_groups(:,:,idx)];
            stim_e_groups=[stim_e_groups; ExpSettings.stim_e_groups(:,:,idx)];
            bTarget=[bTarget; ExpSettings.bTargetPresent(:,:,idx)];
            if ~bOpt
                hit=[hit; SubjectExpFile.hit(:,:,idx)];
                correct_reject=[correct_reject; SubjectExpFile.correctRejection(:,:,idx)];
                correct=[correct; SubjectExpFile.correct(:,:,idx)];
            end
        end
    end
    
    num_targets=sum(bTarget);
    num_blanks=sum(~bTarget);
    if ~bOpt
        num_hits=sum(hit);
        num_cr=sum(correct_reject);
        p_c=mean(correct); % prob. of correct
    end
    th_init=5;
    n_init=0.1;
    sigma_init=5;
    
    init=[th_init n_init sigma_init];
    options=optimset('PlotFcns',@optimplotfval);
    if bOpt
        params=fminsearch(@(p) experiment.analysis.computeNegLogLikelihood_edgeResponse(p,stim_l_groups,stim_e_groups,bTarget,bOpt),init,options);
    else
        params=fminsearch(@(p) experiment.analysis.computeNegLogLikelihood_edgeResponse(p,stim_l_groups,stim_e_groups,bTarget,bOpt,num_blanks,num_targets, num_hits, num_cr),init,options);
    end
    th=params(1);
    n=params(2);
    sigma=params(3);
    
    %     [alpha,beta] = experiment.analysis.fitPsychometric_edgeResponse(alpha_init, beta_init, stim_n_groups,stim_l_groups,stim_e_groups,bTarget,num_blanks,num_targets, num_hits, num_cr);
    %     mu=0;
    %     threshold=mu+a;
    
    %% Figure properties
    if bPlot
        figure; hold on;
        if bOpt
            [~,p_c,d] = experiment.analysis.computeNegLogLikelihood_edgeResponse(params,stim_l_groups,stim_e_groups,bTarget,bOpt);
        else
            [~,~,d] = experiment.analysis.computeNegLogLikelihood_edgeResponse(params,stim_l_groups,stim_e_groups,bTarget,bOpt,num_blanks,num_targets, num_hits, num_cr);
        end
        %         r_t_means=r_t_means-mean(r_b_means);
        plot(d, p_c, 'ok', 'markerfacecolor','k','MarkerSize',5);
        xlimit=xlim; xlim([0 xlimit(2)])
        fplot(@(x) experiment.analysis.psychometricFun(x,0,1,1,0),xlim,'k');
        %         xline(threshold,'color','k','Linewidth',1)
        %         xlim([0 1])
        %         ylim([0 1])
        xlabel("edge response d'"); ylabel('% correct')
        set(gca,'FontSize',13,'TickDir','out','box','off','ytick',[.5 .75 1],'yticklabel',[50 75 100]);
    end
    
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
                bTarget_level=bTarget(boot_idx',iLevel);
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
                rectangle('Position',[target_means(i)-target_sds(i), p_c(i)-pcBoot_sds(i), 2*target_sds(i), 2*pcBoot_sds(i)],...
                    'facecolor',[0 0 0 .1], 'edgecolor','none')
            end
        end
        % mark threshold errorband:
        rectangle('Position',[threshold-threshold_sd 0 2*threshold_sd 1],'facecolor',[0 0 0 .1], 'edgecolor','none')
    end
