%% Compute edge contour properties of experimental stimuli
% filepaths={'pink_noise','texture_exponent/ecc_0','natural/moth','natural/rock','natural/spots','natural/bark_recast','natural/leaf',...
%     'natural/leather','natural/foliage','natural/soil','natural/paper','natural/grass','natural/camo'};
filepaths={'pink_noise'};
ppd=60;

edge_props=struct;
for i = 1:length(filepaths)
    filepath=filepaths{i}
    load(['exp_files/' filepath '/exp_settings.mat']);

    edge_props.num=nan(size(ExpSettings.seeds));
    edge_props.dens=nan(size(ExpSettings.seeds));
    edge_props.len=cell(size(ExpSettings.seeds));
    edge_props.or=cell(size(ExpSettings.seeds));
    edge_props.curv=cell(size(ExpSettings.seeds));
    edge_props.ep1=cell(size(ExpSettings.seeds));
    edge_props.ep2=cell(size(ExpSettings.seeds));
    edge_props.ep4=cell(size(ExpSettings.seeds));
    edge_props.ep8=cell(size(ExpSettings.seeds));
    edge_props.ep16=cell(size(ExpSettings.seeds));
    edge_props.or_al=nan(size(ExpSettings.seeds));
    %     edge_props.len_mean=nan(size(ExpSettings.seeds));
    edge_props.or_mean=nan(size(ExpSettings.seeds));
    edge_props.curv_mean=nan(size(ExpSettings.seeds));
    %     edge_props.ep1_mean=nan(size(ExpSettings.seeds));
    %     edge_props.ep2_mean=nan(size(ExpSettings.seeds));
    %     edge_props.ep4_mean=nan(size(ExpSettings.seeds));

    for iSession=1:ExpSettings.nSessions
        for iLevel=1:ExpSettings.nLevels
            for iTrial=1:ExpSettings.nTrials
%                 [iSession iLevel iTrial]
                stim=ExpSettings.stimuli(:,:,iTrial,iLevel,iSession);
                stim_otf=lib.otf_filter(stim,ppd);

                % detect edge pixels over entire image:
                edge_pixels=lib.detect_edge_pixels(stim_otf);

                % separate into boundary and texture edge pixels
                [~,~,~,bd_strip]=lib.target_mask('kernel_size',[1 2]);
                bd_pixels=single(edge_pixels&bd_strip)';
                bd_pixels(~bd_strip)=nan; % nan the non-boundary region to compute densities correctly
                %                 tx_pixels=single(edge_pixels&(~bd_strip))';
                %                 tx_pixels(bd_strip)=nan;

                [edge_props_this,mean_edge_props_this]=lib.edge_props_stim(stim_otf,'edge_pixels',bd_pixels);
                %                 [~,mean_tx_contour_props]=lib.edge_contour_props(stim_otf,'edge_pixels',tx_pixels);

                edge_props.num(iTrial,iLevel,iSession)=mean_edge_props_this.num;
                edge_props.dens(iTrial,iLevel,iSession)=mean_edge_props_this.dens;
                edge_props.len{iTrial,iLevel,iSession}=[edge_props_this.len];
                edge_props.len_mean(iTrial,iLevel,iSession)=mean_edge_props_this.length;
                edge_props.or{iTrial,iLevel,iSession}=[edge_props_this.or];
                edge_props.or_mean(iTrial,iLevel,iSession)=mean_edge_props_this.or;
                edge_props.curv{iTrial,iLevel,iSession}=[edge_props_this.curv];
                edge_props.curv_mean(iTrial,iLevel,iSession)=mean_edge_props_this.curv;
                edge_props.ep1{iTrial,iLevel,iSession}=[edge_props_this.ep1];
                %                 edge_props.ep1_mean(iTrial,iLevel,iSession)=mean_edge_props_this.ep1;
                edge_props.ep2{iTrial,iLevel,iSession}=[edge_props_this.ep2];
                %                 edge_props.ep2_mean(iTrial,iLevel,iSession)=mean_edge_props_this.ep2;
                edge_props.ep4{iTrial,iLevel,iSession}=[edge_props_this.ep4];
                %                 edge_props.ep4_mean(iTrial,iLevel,iSession)=mean_edge_props_this.ep4;
                edge_props.ep8{iTrial,iLevel,iSession}=[edge_props_this.ep8];
                edge_props.ep16{iTrial,iLevel,iSession}=[edge_props_this.ep16];
                edge_props.or_al(iTrial,iLevel,iSession)=mean_edge_props_this.or_al;
            end
        end
    end

    %% compute normal contour count stats
    num=edge_props.num;

    % blank stats
    num_blanks=num(~ExpSettings.bTargetPresent);
    [num_blank_sd,num_blank_mean]=std(num_blanks);

    % target stats
    num_target_means=nan(1,10);
    num_target_sds=nan(1,10);

%     figure;
    for iLevel=1:10
        num_thislevel=num(:,iLevel,:);
        num_targets=num_thislevel(ExpSettings.bTargetPresent(:,iLevel,:));
        [num_target_sds(iLevel),num_target_means(iLevel)]=std(num_targets);

%         subplot(10,1,iLevel); hold on
%         histogram(num_blanks,'normalization','pdf','edgecolor','none')
%         histogram(num_targets,'normalization','pdf','edgecolor','none')
        %             xlim([0 22]); set(gca,'ytick',[])
        %     set(gca,'yscale','log')
    end

    % compute LLRs
    num_llr=nan(size(edge_props.num));
    for iSession=1:ExpSettings.nSessions
        for iLevel=1:ExpSettings.nLevels
            for iTrial=1:ExpSettings.nTrials
                num_llr(iTrial,iLevel,iSession)=((num(iTrial,iLevel,iSession)-num_blank_mean)/num_blank_sd)^2-...
                    ((num(iTrial,iLevel,iSession)-num_target_means(iLevel))/num_target_sds(iLevel))^2;
            end
        end
    end

    edge_props.num_stats.blank_mean=num_blank_mean;
    edge_props.num_stats.blank_sd=num_blank_sd;
    edge_props.num_stats.target_means=num_target_means;
    edge_props.num_stats.target_sds=num_target_sds;
    edge_props.num_llr=num_llr;
    
    %% compute normal edge density stats
    dens=edge_props.dens;

    % blank stats
    dens_blanks=dens(~ExpSettings.bTargetPresent);
    [dens_blank_sd,dens_blank_mean]=std(dens_blanks);

    % target stats
    dens_target_means=nan(1,10);
    dens_target_sds=nan(1,10);

%     figure;
    for iLevel=1:10
        dens_thislevel=dens(:,iLevel,:);
        dens_targets=dens_thislevel(ExpSettings.bTargetPresent(:,iLevel,:));
        [dens_target_sds(iLevel),dens_target_means(iLevel)]=std(dens_targets);

%         subplot(10,1,iLevel); hold on
%         histogram(dens_blanks,'normalization','pdf','edgecolor','none')
%         histogram(dens_targets,'normalization','pdf','edgecolor','none')
        %             xlim([0 22]); set(gca,'ytick',[])
        %     set(gca,'yscale','log')
    end

    % compute LLRs
    dens_llr=nan(size(edge_props.num));
    for iSession=1:ExpSettings.nSessions
        for iLevel=1:ExpSettings.nLevels
            for iTrial=1:ExpSettings.nTrials
                dens_llr(iTrial,iLevel,iSession)=((dens(iTrial,iLevel,iSession)-dens_blank_mean)/dens_blank_sd)^2-...
                    ((dens(iTrial,iLevel,iSession)-dens_target_means(iLevel))/dens_target_sds(iLevel))^2;
            end
        end
    end

    edge_props.dens_stats.blank_mean=dens_blank_mean;
    edge_props.dens_stats.blank_sd=dens_blank_sd;
    edge_props.dens_stats.target_means=dens_target_means;
    edge_props.dens_stats.target_sds=dens_target_sds;
    edge_props.dens_llr=dens_llr;

    %% compute exponential contour length stats

    len=edge_props.len;

    % blank stats
    len_blanks=[len{~ExpSettings.bTargetPresent}];
    len_blank_mean=mean(len_blanks);

    % target stats
    len_target_means=nan(1,10);
%     figure;
    for iLevel=1:10
        len_thislevel=len(:,iLevel,:);
        len_targets=[len_thislevel{ExpSettings.bTargetPresent(:,iLevel,:)}];
        len_target_means(iLevel)=mean(len_targets);

%         subplot(10,1,iLevel); hold on
%         histogram(len_blanks,'normalization','pdf','edgecolor','none')
%         histogram(len_targets,'normalization','pdf','edgecolor','none')
        %             xlim([0 22]); set(gca,'ytick',[])
%         set(gca,'yscale','log')
    end

    % compute LLRs
    len_llr=nan(size(edge_props.num));
    for iSession=1:ExpSettings.nSessions
        for iLevel=1:ExpSettings.nLevels
            for iTrial=1:ExpSettings.nTrials
                len_llr(iTrial,iLevel,iSession)=...
                    edge_props.num(iTrial,iLevel,iSession)*log(len_blank_mean/len_target_means(iLevel))+...
                    (1/len_blank_mean-1/len_target_means(iLevel))*sum(len{iTrial,iLevel,iSession});
            end
        end
    end

    edge_props.len_stats.blank_mean=len_blank_mean;
    edge_props.len_stats.target_means=len_target_means;
    edge_props.len_llr=len_llr;

    %% compute exponential edge power stats
    ep_list={'ep1','ep2','ep4','ep8','ep16'};

    for i_ep=1:numel(ep_list)
        ep=edge_props.(ep_list{i_ep});

        % blank stats
        ep_blanks=[ep{~ExpSettings.bTargetPresent}];
        ep_blank_mean=mean(ep_blanks);

        % target stats
        ep_target_means=nan(1,10);
%         figure;
        for iLevel=1:10
            ep_thislevel=ep(:,iLevel,:);
            ep_targets=[ep_thislevel{ExpSettings.bTargetPresent(:,iLevel,:)}];
            ep_target_means(iLevel)=mean(ep_targets);

%             subplot(10,1,iLevel); hold on
%             histogram(ep_blanks,'normalization','pdf','edgecolor','none')
%             histogram(ep_targets,'normalization','pdf','edgecolor','none')
            %                 xlim([0 22]); set(gca,'ytick',[])
%             set(gca,'yscale','log')
        end

        % compute LLRs
        ep_llr=nan(size(edge_props.num));
        for iSession=1:ExpSettings.nSessions
            for iLevel=1:ExpSettings.nLevels
                for iTrial=1:ExpSettings.nTrials
                    ep_llr(iTrial,iLevel,iSession)=...
                        edge_props.num(iTrial,iLevel,iSession)*log(ep_blank_mean/ep_target_means(iLevel))+...
                        (1/ep_blank_mean-1/ep_target_means(iLevel))*sum(ep{iTrial,iLevel,iSession});
                end
            end
        end

        edge_props.([ep_list{i_ep} '_stats']).blank_mean=ep_blank_mean;
        edge_props.([ep_list{i_ep} '_stats']).target_means=ep_target_means;
        edge_props.([ep_list{i_ep} '_llr'])=ep_llr;
    end

    save(['exp_files/' filepath '/edge_props.mat'],'edge_props');
end



%% compute normal log(length-weighted contour curvature) stats
% load exp_settings and edge_props_exp

% curv=cellfun(@(x,y) (x.^2).*y, edge_props.curv, edge_props.len,'un',0);
%
% % blank stats
% curv_blanks=[curv{~ExpSettings.bTargetPresent}];
% [curv_blank_std,curv_blank_mean]=std(curv_blanks);
%
% % target stats
% len_target_means=nan(1,10);
% figure;
% for iLevel=1:10
%     len_thislevel=len(:,iLevel,:);
%     len_targets=[len_thislevel{ExpSettings.bTargetPresent(:,iLevel,:)}];
%     len_target_means(iLevel)=mean(len_targets);
%
%     subplot(10,1,iLevel); hold on
%     histogram(len_blanks,'normalization','pdf','edgecolor','none')
%     histogram(len_targets,'normalization','pdf','edgecolor','none')
%     %     xlim([0 22]); set(gca,'ytick',[])
%     set(gca,'yscale','log')
% end
%
% % compute LLRs
% len_llr=nan(size(edge_props.num));
% for iSession=1:ExpSettings.nSessions
%     for iLevel=1:ExpSettings.nLevels
%         for iTrial=1:ExpSettings.nTrials
%             len_llr(iTrial,iLevel,iSession)=...
%                 edge_props.num(iTrial,iLevel,iSession)*log(len_blank_mean/len_target_means(iLevel))+...
%                 (1/len_blank_mean-1/len_target_means(iLevel))*sum(len{iTrial,iLevel,iSession});
%         end
%     end
% end
%
% edge_props.len_stats.blank_mean=len_blank_mean;
% edge_props.len_stats.target_means=len_target_means;
% edge_props.len_llr=len_llr;

