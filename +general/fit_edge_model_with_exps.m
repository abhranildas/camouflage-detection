%% Plot subject d's, and model d', scaled to avg. subject d'
% exp_paths={'natural/moth','natural/rock','natural/camo_large','natural/spots','natural/leaf','natural/leather','natural/camo','pink_noise',...
%     'natural/foliage','natural/soil','natural/grass','natural/paper','natural/bark_recast','texture_exponent/ecc_0'}; %
exp_paths={'pink_noise'};
% exp_paths={'natural/moth','natural/rock','natural/camo_large','natural/spots','natural/leaf','natural/leather','natural/camo','pink_noise',...
%     'natural/foliage','natural/soil','natural/grass','natural/paper','texture_exponent/ecc_0'}; %

nLevels=10;
% edge_feature_names={'grad_m_comb','grad_o_comb','grad_p_comb','npix_llr','ncon_llr','pos_llr','or_llr','curv_llr',...
%     'ep_comb'};
edge_feature_names={'grad_m_comb','grad_o_comb','grad_p_comb'};

n_features=numel(edge_feature_names);

dprimes=cell(length(exp_paths),2);

num_figs = length(findall(0, 'Type', 'figure'));
% figure;

for i_exp=1:length(exp_paths)

    % load experiment settings
    load(['exp_files/' exp_paths{i_exp} '/exp_settings.mat']);

    % load edge properties
    load(['exp_files/' exp_paths{i_exp} '/edge_props_pca.mat']);

    % compute model d's:
    dprimes_model_cons=nan(n_features,nLevels); % d' contributions from each feature (for bar graphs)
    dprimes_model=nan(1,nLevels);
    feature_corrs_blank=nan(n_features,n_features,nLevels);
    feature_corrs_target=nan(n_features,n_features,nLevels);
    for iLevel=1:nLevels
        targets_thislevel=ExpSettings.bTargetPresent(:,iLevel,:);
        feature_vectors_target=nan(nnz(targets_thislevel),numel(edge_feature_names));
        feature_vectors_blank=nan(nnz(~targets_thislevel),numel(edge_feature_names));
        for iFeature=1:numel(edge_feature_names)
            feature=edge_props.(edge_feature_names{iFeature});
            feature_thislevel=feature(:,iLevel,:);
            feature_vectors_target(:,iFeature)=feature_thislevel(targets_thislevel);
            feature_vectors_blank(:,iFeature)=feature_thislevel(~targets_thislevel);
        end

        % correlation coefficient between features:
        feature_corrs_blank(:,:,iLevel)=corrcoef(feature_vectors_blank);
        feature_corrs_target(:,:,iLevel)=corrcoef(feature_vectors_target);

        results=classify_normals(feature_vectors_target,feature_vectors_blank,'input_type','samp','samp_opt',false,'d_con',true,'eff',0.34,'plotmode',0,'precision','basic');
        % d' contributions
        dprimes_model_cons(:,iLevel)=results.d_con;
        dprimes_model(iLevel)=results.norm_d_b;
    end
    dprimes{i_exp,2}=dprimes_model;

    subj_list=dir(['exp_files/' exp_paths{i_exp} '/subject_out/*.mat']);
    dprimes_subj=nan(length(subj_list),10);

    figure(num_figs+1)
    subplot(4,4,i_exp);
    hold on

    % subject data
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

        % now combine both
        dprime_subj=dprime_hf;
        dprime_subj(isinf(dprime_subj))=dprime_correct(isinf(dprime_subj));

        dprimes_subj(i_subj,:)=dprime_subj;

        % plot subject accuracy:
        x=(1:nLevels)';
        y=normcdf(dprime_subj/2)';
        % plot subject accuracy errorband:
        dy=std(squeeze(mean(SubjectExpFile.correct)),0,2);
        fill([x;flipud(x)],[y-dy;flipud(y+dy)],'k','linestyle','none','facealpha',.1);
        plot(x,y,'-ok','markersize',4,'markerfacecolor','k');
    end

    dprimes{i_exp,1}=dprimes_subj;

    % average subject d' in this experiment:
    % averaging acc, then getting d' (so as not to average inf d's).
    % but for the model we are averaging d' directly, so it's not an exact
    % comparison
    avg_subj_acc=mean(normcdf(dprimes_subj/2),'all');
    avg_subj_dprime=2*norminv(avg_subj_acc);
    title(sprintf('%s: %.1f%%',exp_paths{i_exp}, 100*avg_subj_acc),'interpreter','none')

    % plot individual feature contributions to d':
    figure(num_figs+2)
    hold on

    % single color-bar for sum across levels
    dprime_cons_tot=sum(dprimes_model_cons,2);
    % scale the total height of the bar to the avg. overall d' across levels:
    dprime_cons_tot=dprime_cons_tot/sum(dprime_cons_tot)*mean(dprimes_model);
    bar_h=bar(i_exp,flip(dprime_cons_tot),0.2,'stacked','facecolor','flat');

    % bar colours

    % edge power, blue gradient
    % bar_h(1).CData=[0 0 0.44];
    % bar_h(2).CData=[0 0.24 0.54];
    % bar_h(3).CData=[0 0.54 0.84];
    % bar_h(1).CData=[0 0.74 1];
    % bar_h(5).CData=[0 0.9 1];
    % 
    % % edge power sums, purple gradient
    % %     b(6).CData=[0 0 0.44];
    % %     b(7).CData=[0 0.24 0.54];
    % %     b(8).CData=[0 0.54 0.84];
    % %     b(9).CData=[0 0.74 1];
    % %     b(10).CData=[0 0.9 1];
    % 
    % % curvature, red
    % bar_h(2).CData=[1 0 0];
    % 
    % % orientation alignment, yellow
    % bar_h(3).CData=[1 1 0];
    % 
    % % position alignment, orange
    % bar_h(4).CData=[1 0.4588 0.0941];
    % 
    % % len llr, light green
    % % bar_h(9).CData=[0.66 0.87 0.38];
    % 
    % % len sum, green
    % % bar_h(10).CData=[0.4660 0.6740 0.1880];
    % 
    % % ncon llr, light green
    % bar_h(5).CData=[0.66 0.87 0.38];
    % 
    % % npix llr, green
    % bar_h(6).CData=[0.4660 0.6740 0.1880];
    % 
    % % grad prod histogram, dark grey 
    bar_h(1).CData=.5*[1 1 1];
    % 
    % % grad or histogram, light grey
    bar_h(2).CData=.7*[1 1 1];
    % 
    % % grad mag histogram, white
    bar_h(3).CData=[1 1 1];


    % bar_h(1).CData=[1 .5 .5];
    % bar_h(2).CData=.8*bar_h(1).CData;
    % bar_h(3).CData=.6*bar_h(1).CData;
    % bar_h(4).CData=.4*bar_h(1).CData;

    % bar_h(2).CData=[0 1 0];
    % bar_h(6).CData=.8*bar_h(5).CData;
    % bar_h(7).CData=.6*bar_h(5).CData;
    % bar_h(8).CData=.4*bar_h(5).CData;

    % bar_h(3).CData=[.4 .7 1];
    % bar_h(10).CData=.8*bar_h(9).CData;
    % bar_h(11).CData=.6*bar_h(9).CData;
    % bar_h(12).CData=.4*bar_h(9).CData;


    % plot feature correlations
    % blank
%     figure(3); subplot(4,4,i_exp);
%     imagesc(mean(feature_corrs_blank,3)); axis square
%     colorbarpzn(-1,1,'rev'); colorbar off
%     set(gca,'xtick',[],'ytick',[])
% 
%     % target
%     figure(4); subplot(4,4,i_exp);
%     imagesc(mean(feature_corrs_target,3)); axis square
%     colorbarpzn(-1,1,'rev'); colorbar off
%     set(gca,'xtick',[],'ytick',[])
end

% set bar labels and edge feature legends
figure(num_figs+2)
xticks(1:numel(exp_paths))
xticklabels(exp_paths);
set(gca,'TickLabelInterpreter','none');

f=get(gca,'Children');
% legend([f(1),f(2),f(3),f(4),f(5),f(6),f(7),f(8),f(9),f(10),f(11),f(12),f(13)],edge_feature_names,'interpreter','none')
legend boxoff

% find efficiency scalar to match model d's to subject d's:
[s,sqerr]=fmincon(@(s)lib.edge_fit_cost(s,dprimes),1,-1,0);

for i_exp=1:length(exp_paths)
    % scale model d'
    % dprimes{i_exp,2}=dprimes{i_exp,2}*s;

    % plot model d's:
    figure(num_figs+1)
    subplot(4,4,i_exp);
    plot(normcdf(dprimes{i_exp,2}/2),'-or','markersize',4,'markerfacecolor','r','linewidth',1)
    set(gca,'xtick',[],'ytick',[.5 1],'tickdir','out','yticklabels',{'',''});
    axis([1 10 .4 1])
end

% percent variance of mean subject accuracies explained
mean_subj_acc=cell2mat(cellfun(@(x) mean(normcdf(x/2)), dprimes(:,2),'un',0));
model_acc=normcdf(vertcat(dprimes{:,2})/2);
var_exp=1-rms(mean_subj_acc-model_acc,'all')^2/var(mean_subj_acc(:))
% var_exp=1-sqerr/numel(vertcat(dprimes{:,2}))

% percent variance of dprimes explained across all subjects
% (this is what the efficiency scalar was optimizing for)
dprimes_subj=vertcat(dprimes{:,1});
dprimes_subj(isinf(dprimes_subj))=nan;
var_exp=1-sqerr/(var(dprimes_subj,0,'all','omitnan')*numel(~isnan(dprimes_subj)))

%% scatter plot of model vs subject d' (to see how proportional they are)
figure
for i_exp=1:length(exp_paths)
    dprimes_subj_thisexp=dprimes{i_exp,1};
    subplot(4,4,i_exp); hold on
    for i_subj=1:size(dprimes_subj_thisexp,1)
        plot(dprimes{i_exp,2},dprimes_subj_thisexp(i_subj,:),'-ok')
    end
    title(sprintf('%s',exp_paths{i_exp}),'interpreter','none')
end

%% fit edge model for all-textures experiment
% load data
load('exp_files/all/exp_settings.mat');
load('exp_files/all/edge_props.mat');
load('exp_files/all/texture_list.mat');
load('exp_files/all/subject_out/neel.mat');

edge_feature_names={'dens','len_llr','al_sum','curv_sum','ep1_sum','ep2_sum','ep4_sum','ep8_sum','ep16_sum'};
n_tex=length(texture_list);
n_trials=40;
n_features=numel(edge_feature_names);
errs_model=nan(n_tex,1);
dprimes_model=nan(n_tex,1);

errs_subj=nan(n_tex,1);

% first classify target vs blank images for the whole experiment
feature_vectors_target=nan(nnz(ExpSettings.bTargetPresent),n_features);
feature_vectors_blank=nan(nnz(~ExpSettings.bTargetPresent),n_features);

for iFeature=1:n_features
    feature=edge_props.(edge_feature_names{iFeature});
    feature_vectors_target(:,iFeature)=feature(ExpSettings.bTargetPresent);
    feature_vectors_blank(:,iFeature)=feature(~ExpSettings.bTargetPresent);
end

results=classify_normals(feature_vectors_target,feature_vectors_blank,'input_type','samp','d_con',true);

% get the overall sample-optimized boundary
overall_bd=results.samp_opt_bd;

% now use this overall boundary to classify target vs blank for each texture

for iTex=1:n_tex
    tex=texture_list(iTex)
    tex_select=arrayfun(@(x) isequal(x,tex), ExpSettings.textures);
    errs_subj(iTex)=mean(~SubjectExpFile.correct(tex_select));

    feature_vectors_target=nan(nnz(tex_select&ExpSettings.bTargetPresent),n_features);
    feature_vectors_blank=nan(nnz(tex_select&~ExpSettings.bTargetPresent),n_features);

    for iFeature=1:n_features
        feature=edge_props.(edge_feature_names{iFeature});
        feature_vectors_target(:,iFeature)=feature(tex_select&ExpSettings.bTargetPresent);
        feature_vectors_blank(:,iFeature)=feature(tex_select&~ExpSettings.bTargetPresent);
    end
    results=classify_normals(feature_vectors_target,feature_vectors_blank,'input_type','samp','dom',overall_bd,'plotmode',0);
    errs_model(iTex)=results.samp_err;
%     dprimes_model(iTex)=results.samp_d_b;
end

err_sd_subj=sqrt(errs_subj.*(1-errs_subj)/n_trials); % sd of subj error rate assuming binomial

figure
errorbar(errs_model,errs_subj,err_sd_subj,'ok')
xlabel 'model error rates'
ylabel 'subject error rates'
set(gca,'fontsize',13)

%% show all textures with subject and model accuracy

bg_size=256;
lum=0.5;
cont=0.15;
target_radius=64;

for i_tex=1:length(texture_list)
    i_tex
    texture=texture_list(i_tex);
    stim=lib.stimulus('texture',texture,'ml_b',0.5,'cont_b',0.15,'ml_t',0.5,'cont_t',0.15,'target_radius',target_radius);
    figure;
    imshow(stim,[]);
    title(sprintf('%s %.2f, %.2f',texture.img,1-errs_subj(i_tex),1-errs_model(i_tex)),'Interpreter','none')
end