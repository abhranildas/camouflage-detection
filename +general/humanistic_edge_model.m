%% Plot subject d's, and model d', scaled to avg. subject d'
% exp_paths={'pink_noise','texture_exponent/ecc_0','natural/moth','natural/rock','natural/spots','natural/bark_recast','natural/leaf',...
%     'natural/leather','natural/foliage','natural/soil','natural/paper','natural/grass','natural/camo'};
exp_paths={'pink_noise'};

dprimes=cell(length(exp_paths),3);
figure;

for i_exp=1:length(exp_paths)

    % load experiment settings
    load(['exp_files/' exp_paths{i_exp} '/exp_settings.mat']);

    % load edge properties
    load(['exp_files/' exp_paths{i_exp} '/edge_props.mat']);

    % compute edge power d's (for x-axis of plots), and model d's:
    ep_dprimes=nan(1,10);
    [ep_blank_sd,ep_blank_mean]=std(ExpSettings.edgePowers(~ExpSettings.bTargetPresent));
    %     edge_features=fieldnames(edge_props);
    edge_prop_names={'dens_llr','len_llr','or_al','ep1_llr','ep2_llr','ep4_llr','ep8_llr','ep16_llr'};
    dprimes_model_ind=nan(numel(edge_prop_names),10); % individual feature dprimes (for bar graphs)
    dprimes_model_corr=nan(1,10);
    for iLevel=1:10
        targets_thislevel=ExpSettings.bTargetPresent(:,iLevel,:);
        ep_thislevel=ExpSettings.edgePowers(:,iLevel,:);
        ep_dprimes(iLevel)=2*(mean(ep_thislevel(targets_thislevel))-ep_blank_mean)/...
            (std(ep_thislevel(targets_thislevel))+ep_blank_sd);

        cue_vectors_target=nan(nnz(targets_thislevel),numel(edge_prop_names));
        cue_vectors_blank=nan(nnz(~targets_thislevel),numel(edge_prop_names));
        for iCue=1:numel(edge_prop_names)
            cue=edge_props.(edge_prop_names{iCue});
            cue_thislevel=cue(:,iLevel,:);
            cue_vectors_target(:,iCue)=cue_thislevel(targets_thislevel);
            cue_vectors_blank(:,iCue)=cue_thislevel(~targets_thislevel);
        end
        dprimes_model_ind(:,iLevel)=2*abs(mean(cue_vectors_target)-mean(cue_vectors_blank))'./(std(cue_vectors_target)+std(cue_vectors_blank))';
        results=classify_normals(cue_vectors_target,cue_vectors_blank,'input_type','samp','samp_opt',false,'plotmode',0);
        dprimes_model_corr(iLevel)=results.norm_d_b;
    end
    dprimes_model_ind=sum(dprimes_model_ind.^2,2);

    dprimes{i_exp,1}=ep_dprimes;
    dprimes{i_exp,3}=dprimes_model_corr;

    subj_list=dir(['exp_files/' exp_paths{i_exp} '/subject_out/*.mat']);
    dprimes_subj=nan(length(subj_list),10);

    figure(1)
    subplot(4,4,i_exp);
    hold on
    title(exp_paths{i_exp},'Interpreter', 'none')

    for i_subj=1:length(subj_list)
        % load subject file
        load(['exp_files/' exp_paths{i_exp} '/subject_out/' subj_list(i_subj).name])

        % compute subject d's across blocks
        % by inverting the overall accuracy
        p_correct=mean(SubjectExpFile.correct,[1 3]);
        dprime_correct=2*norminv(p_correct);

        % by using hits & false alarms (to correct bias):
        hit_rate=sum(SubjectExpFile.hit,[1 3])./sum(SubjectExpFile.bTargetPresent,[1 3]);
        fa_rate=sum(SubjectExpFile.falseAlarm,[1 3])./sum(~SubjectExpFile.bTargetPresent,[1 3]);
        dprime_hf=norminv(hit_rate)-norminv(fa_rate);

        % by combining both
        dprime_subj=dprime_hf;
        dprime_subj(isinf(dprime_subj))=dprime_correct(isinf(dprime_subj));

        dprimes_subj(i_subj,:)=dprime_subj;

        % plot subject accuracy:
        x=(1:10)';
        y=normcdf(dprime_subj/2)';
        % plot subject accuracy errorband:
        dy=std(squeeze(mean(SubjectExpFile.correct)),0,2);
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],'k','linestyle','none','facealpha',.1);
        plot(x,y,'-ok','markersize',5,'markerfacecolor','k');
    end

    dprimes{i_exp,2}=dprimes_subj;

    % plot individual feature contributions to d':
    figure(2)
    subplot(4,4,i_exp); hold on
    b=bar(0,flip(dprimes_model_ind)/sum(dprimes_model_ind),0.2,'stacked','facecolor','flat');
    b(1).CData=[0 0 0.44];
    b(2).CData=[0 0.24 0.54];
    b(3).CData=[0 0.54 0.84];
    b(4).CData=[0 0.74 1];
    b(5).CData=[0 0.9 1];
    b(6).CData=[0.4660 0.6740 0.1880];
    b(7).CData=[1 0.4588 0.0941];
    axis([-.1 .1 0 1]); axis image
    set(gca,'xtick',[],'ytick',[]);
end

% find efficiency scalar to match model d's to subject d's:
[s,sqerr]=fmincon(@(s)lib.edge_fit_cost(s,dprimes),1,-1,0);

for i_exp=1:length(exp_paths)
    % scale model d'
    dprimes{i_exp,3}=dprimes{i_exp,3}*s;

    % plot model d's:
    figure(1)
    subplot(4,4,i_exp);
    plot(normcdf(dprimes{i_exp,3}/2),'-or','markersize',7,'markerfacecolor','r','linewidth',2)
    set(gca,'xtick',[],'ytick',[.5 1],'fontsize',20);
    title ''
    axis([1 10 .4 1])
end

% percent variance of mean subject accuracies explained
mean_subj_acc=cell2mat(cellfun(@(x) mean(normcdf(x/2)), dprimes(:,2),'un',0));
model_acc=normcdf(vertcat(dprimes{:,3})/2);
var_exp=1-rms(mean_subj_acc-model_acc,'all')^2/var(mean_subj_acc(:))
% var_exp=1-sqerr/numel(vertcat(dprimes{:,2}))

% percent variance of dprimes explained across all subjects
% (this is what the efficiency scalar was optimizing for)
dprimes_subj=vertcat(dprimes{:,2});
dprimes_subj(isinf(dprimes_subj))=nan;
var_exp=1-sqerr/(var(dprimes_subj,0,'all','omitnan')*numel(~isnan(dprimes_subj)))