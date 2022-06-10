function [threshold, b, c, threshold_sd, b_sd, c_sd, sessions_completed, target_means, pcBoot_sds, x_pmf, y_pmf] = computeThreshold_edgePower(expTypeStr, subjectStr, bPlot, bBootstrap)

    % Load in experiment settings file
    load(['./exp_files/' expTypeStr '/exp_settings.mat'],'ExpSettings');

    % Load in subject experiment file
    load(['./exp_files/' expTypeStr '/subject_out/'  subjectStr '.mat'],'SubjectExpFile');
    
    nTrials = size(SubjectExpFile.correct, 1);
    nLevels = size(SubjectExpFile.correct, 2);
    completedBinIndex = SubjectExpFile.levelCompleted == nLevels;
    sessions_completed=sum(completedBinIndex);
    
    if(sessions_completed == 0)
        error(['Error: Needed ' num2str(nLevels) ' levels to fit psychometric function.']);
    end
    
    exp_values=[];
    bTarget=logical([]);
    hit=logical([]);
    correct_reject=logical([]);
    correct=logical([]);
    
%     blank_mean=mean(SubjectExpFile.edgePowers(~SubjectExpFile.bTargetPresent));
    
    if(bPlot)
        disp(['Sessions used: ' num2str(sessions_completed)]);
    end
    
    for cItr = 1:length(completedBinIndex)
        if(completedBinIndex(cItr))
            exp_values    = [exp_values; ExpSettings.edgePowers(:,:,cItr)];
            bTarget = [bTarget; SubjectExpFile.bTargetPresent(:,:,cItr)];
            hit = [hit; SubjectExpFile.hit(:,:,cItr)];
            correct_reject = [correct_reject; SubjectExpFile.correctRejection(:,:,cItr)];
            correct = [correct; SubjectExpFile.correct(:,:,cItr)];
        end
    end
    
    num_targets=sum(bTarget);
    num_blanks=sum(~bTarget);
    num_hits=sum(hit);
    num_cr=sum(correct_reject);
    
    target_means=nan(1,nLevels);
    target_sds=nan(1,nLevels);
    for i=1:nLevels
        exp_level=exp_values(:,i);
        bTarget_level=bTarget(:,i);
        target_means(i)=mean(exp_level(bTarget_level));
        target_sds(i)=std(exp_level(bTarget_level));
    end
    
    p_c=mean(correct); % prob. of correct
    
%     mu_init=blank_mean;
    a_init=mean(target_means);
    b_init=1;
    c_init=0;
    [a,b,c] = experiment.analysis.fitPsychometric(a_init, b_init, c_init, target_means, num_blanks,num_targets, num_hits, num_cr);
    mu=0;
    threshold=mu+a;
    
    %% Figure properties
    if bPlot
        hold on;
        plot(target_means, p_c, 'ob', 'markerfacecolor','b','MarkerSize',5);
        fplot(@(x) experiment.analysis.psychometricFun(x,mu,a,b,c),[mu 1],'b');
        xline(threshold,'color','b','Linewidth',1)
%         xlim([0 1])
        ylim([0 1])
        xlabel('edge power'); ylabel('% correct')
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
                    'facecolor',[0 0 1 .1], 'edgecolor','none')
            end
        end
        % mark threshold errorband:
        rectangle('Position',[threshold-threshold_sd 0 2*threshold_sd 1],'facecolor',[0 0 1 .1], 'edgecolor','none')
    end
