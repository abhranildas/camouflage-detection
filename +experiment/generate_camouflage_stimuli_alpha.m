function [stimuli, seeds, edgePowers, pClipped]=generate_camouflage_stimuli_alpha(alphas,nTrials,nSessions,bg_size,target_radius,ml,cont,bTargetPresent)
    texture.type='pink_noise';
    n_edge=1e4; kernel_sd=1;
    
    [~,~,~,bdry_ribbon]=lib.circular_mask(bg_size,target_radius,'center');
    nLevels=length(alphas);
    stimuli=zeros(bg_size,bg_size,nTrials,nLevels,nSessions);
    seeds=nan(nTrials,nLevels,nSessions);
    edgePowers=nan(nTrials,nLevels,nSessions);
    pClipped=zeros(nTrials,nLevels,nSessions);
    
    % generate stimuli images
    for iLevel=1:nLevels
        texture.alpha=alphas(iLevel);
        for iSession=1:nSessions
            parfor iTrial=1:nTrials
                fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
                if bTargetPresent(iTrial,iLevel,iSession) % if this is a target stimulus%                     
                    [stim,seed]=lib.stimulus('texture',texture,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
                else % if this is a blank stimulus
                    [stim,seed]=lib.stimulus('texture',texture,'ml_b',ml,'cont_b',cont);                    
                end
                seeds(iTrial,iLevel,iSession)=seed;
                stimuli(:,:,iTrial,iLevel,iSession)=stim;
                edge=lib.edge_vector(stim,target_radius,n_edge,kernel_sd);
                edgePowers(iTrial,iLevel,iSession)=lib.edge_measures(edge);
                pClipped(iTrial,iLevel,iSession)=lib.compute_pClipped(stim(bdry_ribbon));
            end
        end
    end