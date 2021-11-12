function [a, b, a_sd, b_sd, sessions_completed, target_means, pcBoot_sds, x_pmf, y_pmf] = computeThreshold_steve(expTypeStr, subjectStr, bPlot, bBootstrap)
    
    % Load in subject experiment file
    load(['./exp_files/' expTypeStr '/subject_out/'  subjectStr '.mat'],'SubjectExpFile');
    
    nTrials = size(SubjectExpFile.correct, 1);
    nLevels = size(SubjectExpFile.correct, 2);
    completedBinIndex = SubjectExpFile.levelCompleted == nLevels;
    sessions_completed=sum(completedBinIndex);
    
    if(sessions_completed == 0)
        error(['Error: Needed ' num2str(nLevels) ' levels to fit psychometric function.']);
    end
    
    exp_values = [];
    bTarget = logical([]);
    correct = logical([]);
    response = logical([]);

    blank_mean=mean(SubjectExpFile.edgePowers(~SubjectExpFile.bTargetPresent));
    
    if(bPlot)
        disp(['Sessions used: ' num2str(sessions_completed)]);
    end
    
    for cItr = 1:length(completedBinIndex)
        if(completedBinIndex(cItr))
            exp_values    = [exp_values; SubjectExpFile.edgePowers(:,:,cItr)];
            bTarget = [bTarget; SubjectExpFile.bTargetPresent(:,:,cItr)];
            correct = [correct; SubjectExpFile.correct(:,:,cItr)];
            response = [response; SubjectExpFile.response(:,:,cItr)];
        end
    end
    
%     exp_values=exp_values-blank_mean; % subtract the blank mean
    target_means=nan(1,nLevels);
    target_sds=nan(1,nLevels);
    for i=1:nLevels
        exp_level=exp_values(:,i);
        bTargetPresent_level=bTarget(:,i);
        target_means(i)=mean(exp_level(bTargetPresent_level));
        target_sds(i)=std(exp_level(bTargetPresent_level));
    end
    
    pc_mean=mean(correct);
    a_init=mean(target_means);
    b_init=1;
    [a, b] = experiment.analysis.fitPsychometric_steve(a_init, b_init, exp_values(bTarget), correct(bTarget));
    
    %% Figure properties
    if bPlot
        figure; hold on;
        plot(target_means, pc_mean, '.k', 'MarkerSize', 15);
        fplot(@(x) experiment.analysis.psychometricFun_new(x,a,b),'k');
        xline(a,'color','k','Linewidth',1)
        xlim(SubjectExpFile.edgePowerBlockEdges([1 end]))
        ylim([.5 1])
        xlabel('edge power'); ylabel('% correct')
        set(gca,'FontSize',13,'TickDir','out','box','off','ytick',[.5 .75 1],'yticklabel',[50 75 100]);
    end
    
    %% Bootstrap
    a_sd = 0;
    if(bBootstrap)
        n_boot = 500;
        pc_boot=nan(n_boot,nLevels); a_boot=nan(1,n_boot); b_boot=nan(1,n_boot);
        for iBoot= 1:n_boot
            exp_values_boot=nan(nTrials,nLevels);
            bTarget_boot=false(nTrials,nLevels);
            correct_boot=false(nTrials,nLevels);
            response_boot=false(nTrials,nLevels);
            for iLevel=1:nLevels
                [exp_values_boot(:,iLevel),boot_idx]=datasample(exp_values(:,iLevel),nTrials);
                bTarget_boot(:,iLevel)=bTarget(boot_idx',iLevel);
                correct_boot(:,iLevel)=correct(boot_idx',iLevel);
                response_boot(:,iLevel)=response(boot_idx',iLevel);
            end
            pc_boot(iBoot,:) = mean(correct_boot);
            [a_boot(iBoot), b_boot(iBoot)]=experiment.analysis.fitPsychometric_steve(a, b, exp_values_boot(bTarget_boot), correct_boot(bTarget_boot));
        end
        threshold_boot=a_boot+blank_mean;
        a_sd = std(threshold_boot);
        b_sd = std(b_boot);
        pcBoot_sds = std(pc_boot);
        if(bPlot)
            for i=1:length(target_means)
                rectangle('Position',[target_means(i)-target_sds(i), pc_mean(i)-pcBoot_sds(i), 2*target_sds(i), 2*pcBoot_sds(i)],...
                    'facecolor',[0 0 0 .1], 'edgecolor','none')
            end
        end
        % mark threshold errorband:
        rectangle('Position',[a-a_sd .5 2*a_sd range(ylim)],'facecolor',[0 0 0 .1], 'edgecolor','none')
    end
