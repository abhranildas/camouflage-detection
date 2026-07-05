%% Compute edge contour properties of the stimuli of each experiment
% exp_paths={'natural/moth','natural/rock','natural/camo_large','natural/spots','natural/leaf','natural/leather','natural/camo','pink_noise',...
%     'natural/foliage','natural/soil','natural/grass','natural/paper','natural/bark_recast','texture_exponent/ecc_0'}; %
exp_paths={'pink_noise'};
% filepaths={'all'};

% load the efficient-coding histogram bins of gradient magnitude computed from natural images
load('vislab_data/nat_im_eff_coding.mat') 

% dumb down the efficient bins to only use equispaced bins at the middle scale
n_bins=size(grad_m_bins,2)-1;
% grad_m_bins=repmat([-inf linspace(grad_m_bins(3,2),grad_m_bins(3,end-1),n_bins-1) inf],[5 1]);
% grad_o_bins=repmat([-inf linspace(grad_o_bins(3,2),grad_o_bins(3,end-1),n_bins-1) inf],[5 1]);
% grad_p_bins=repmat([-inf linspace(grad_p_bins(3,2),grad_p_bins(3,end-1),n_bins-1) inf],[5 1]);

% or equispaced bins at each scale
for i_scale=1:size(grad_m_bins,1)
    grad_m_bins(i_scale,:)=[-inf linspace(grad_m_bins(i_scale,2),grad_m_bins(i_scale,end-1),n_bins-1) inf];
    grad_o_bins(i_scale,:)=[-inf linspace(grad_o_bins(i_scale,2),grad_o_bins(i_scale,end-1),n_bins-1) inf];
    grad_p_bins(i_scale,:)=[-inf linspace(grad_p_bins(i_scale,2),grad_p_bins(i_scale,end-1),n_bins-1) inf];
end

[Itrial, ILevel, ISession]=ndgrid(1:30,10:-1:1,1:4);
n_scales=5;
nLevels=10;

for i = 1:length(exp_paths)
    tic
    filepath=exp_paths{i}
    load(['exp_files/' filepath '/exp_settings.mat']);

    edge_props=struct;

    % [grad_m_1,grad_m_2,grad_m_4,grad_m_8,grad_m_16,...
    %     grad_o_1,grad_o_2,grad_o_4,grad_o_8,grad_o_16,...
    %     grad_p_1,grad_p_2,grad_p_4,grad_p_8,grad_p_16,...
    %     edge_props.npix_llr,...
    %     edge_props.ncon_llr,...
    %     edge_props.len_llr,...
    %     edge_props.pos_llr,...
    %     edge_props.pos_sum,...
    %     edge_props.or_llr,...
    %     edge_props.or_sum,...
    %     edge_props.curv_llr,...
    %     edge_props.curv_sum,...
    %     ep_1,ep_2,ep_4,ep_8,ep_16]=...

        [grad_m_1,grad_m_2,grad_m_4,grad_m_8,grad_m_16,...
        grad_o_1,grad_o_2,grad_o_4,grad_o_8,grad_o_16,...
        grad_p_1,grad_p_2,grad_p_4,grad_p_8,grad_p_16,...
        ]=...
        arrayfun(@(iTrial,iLevel,iSession) lib.edge_props_stim(ExpSettings.stimuli(:,:,iTrial,iLevel,iSession),...
        'grad_mag_bins',grad_m_bins,'grad_or_bins',grad_o_bins,'grad_prod_bins',grad_p_bins),Itrial, ILevel, ISession);

    % store edge power and gradient histograms across scales into single arrays
    grad_m=nan([30 10 4 n_scales]);
    grad_o=nan([30 10 4 n_scales]);
    grad_p=nan([30 10 4 n_scales]);
    % ep=nan([30 10 4 n_scales]);
    for i_scale=1:n_scales
        grad_m(:,:,:,i_scale)=eval(['grad_m_' num2str(2^(i_scale-1))]);
        grad_o(:,:,:,i_scale)=eval(['grad_o_' num2str(2^(i_scale-1))]);
        grad_p(:,:,:,i_scale)=eval(['grad_p_' num2str(2^(i_scale-1))]);
        % ep(:,:,:,i_scale)=eval(['ep_' num2str(2^(i_scale-1))]);
    end

    % edge_props.ep=ep;
    edge_props.grad_m=grad_m;
    edge_props.grad_o=grad_o;
    edge_props.grad_p=grad_p;

    % merge gradient histograms and edge powers across scales into combined decision variables
    % input_array_names={'grad_m','grad_o','grad_p','ep'};
    input_array_names={'grad_m','grad_o','grad_p'};

    for i_input=1:numel(input_array_names)
        this_input_array=eval(input_array_names{i_input});
        
        comb_dv=nan([30 10 4]);
        comb_dv_thislevel=nan([30 1 4]);
        for iLevel=1:nLevels
            targets_thislevel=ExpSettings.bTargetPresent(:,iLevel,:);
            feature_vectors_target=nan(nnz(targets_thislevel),n_scales);
            feature_vectors_blank=nan(nnz(~targets_thislevel),n_scales);
            for i_scale=1:n_scales
                feature_thislevel=this_input_array(:,iLevel,:,i_scale);
                feature_vectors_target(:,i_scale)=feature_thislevel(targets_thislevel);
                feature_vectors_blank(:,i_scale)=feature_thislevel(~targets_thislevel);
            end

            results=classify_normals(feature_vectors_target,feature_vectors_blank,'input_type','samp','samp_opt',false,'plotmode',0,'precision','basic');
            comb_dv_thislevel(targets_thislevel) = results.samp_dv{1};
            comb_dv_thislevel(~targets_thislevel) = results.samp_dv{2};
            comb_dv(:,iLevel,:)=comb_dv_thislevel;
        end
        edge_props.([input_array_names{i_input} '_comb'])=comb_dv;

        % edge_props.([input_array_names{i_input} '_comb'])=sum(this_input_array,4);
    end

    % save edge properties
    save(['exp_files/' filepath '/edge_props_raw_bins.mat'],'edge_props');
    toc
end

%% plot statistics of a feature
colors=colororder;
fields=fieldnames(edge_props_all_contours_b);

feature=fields{3}
figure; hold on
% xlim([0 4])
set(gca,'yscale','log')
histogram([edge_props_all_contours_b.(feature)],'normalization','pdf','edgecolor','none')
for iLevel=1:10
    if exist('h','var')
        delete(h)
    end
    h=histogram([edge_props_all_contours_t{iLevel}.(feature)],'normalization','pdf','facecolor',colors(2,:),'edgecolor','none');
    pause
end
