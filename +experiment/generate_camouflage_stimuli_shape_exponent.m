function [stimuli, seeds, edgePowers, pClipped]=generate_camouflage_stimuli_shape_exponent(alphas,nTrials,nSessions,bg_size,target_radius,ml,cont,bTargetPresent)
texture.type='pink_noise';
%     n_edge=1e4; kernel_sd=1;

%     [~,~,~,bdry_ribbon]=lib.circular_mask(bg_size,target_radius,'center');
nLevels=length(alphas);
stimuli=zeros(bg_size,bg_size,nTrials,nLevels,nSessions);
seeds=nan(nTrials,nLevels,nSessions);
edgePowers=nan(nTrials,nLevels,nSessions);
pClipped=zeros(nTrials,nLevels,nSessions);

% generate stimuli images
parfor iLevel=1:nLevels
    alpha=alphas(iLevel);
    for iSession=1:nSessions
        for iTrial=1:nTrials
            fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
            if bTargetPresent(iTrial,iLevel,iSession) % if this is a target stimulus%
                %                     [stim,seed]=lib.stimulus('texture',texture,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
                [stim,seed,mask,mask_edge,mask_normal,mask_strip]=lib.stimulus('texture',texture,'bg_size',bg_size,'target_shape',alpha,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
                [~,target_edge_power]=lib.edge(stim,'mask',mask,'mask_edge',mask_edge,'mask_normal',mask_normal,'kernel_size',[1 3]);
                %                 edge=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
                edgePowers(iTrial,iLevel,iSession)=target_edge_power;
                pClipped(iTrial,iLevel,iSession)=lib.compute_pClipped(stim(mask_strip));
            else % if this is a blank stimulus
                [stim,seed]=lib.stimulus('texture',texture,'bg_size',bg_size,'ml_b',ml,'cont_b',cont);
            end
            seeds(iTrial,iLevel,iSession)=seed;
            stimuli(:,:,iTrial,iLevel,iSession)=stim;
        end
    end
end