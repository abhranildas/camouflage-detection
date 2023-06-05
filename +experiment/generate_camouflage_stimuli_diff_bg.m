function [stimuli, seeds, edgePowers, pClipped]=generate_camouflage_stimuli_diff_bg(target_exponent,bg_exponents,nTrials,nSessions,bg_size,target_radius,ml,cont,bTargetPresent)
texture_target.type='pink_noise';
texture_target.exponent=target_exponent;

[~,~,~,bdry_ribbon]=lib.target_mask('bg_size',bg_size,'target_radius',target_radius);
nLevels=length(bg_exponents);
stimuli=zeros(bg_size,bg_size,nTrials,nLevels,nSessions);
seeds=nan(nTrials,nLevels,nSessions);
edgePowers=nan(nTrials,nLevels,nSessions);
pClipped=zeros(nTrials,nLevels,nSessions);

% generate stimuli images
for iLevel=1:nLevels
    texture_bg.type='pink_noise';
    texture_bg.exponent=bg_exponents(iLevel);
    for iSession=1:nSessions
        parfor iTrial=1:nTrials
            fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
            if bTargetPresent(iTrial,iLevel,iSession) % if this is a target stimulus
                [stim,seed]=lib.stimulus('texture',texture_target,'texture_bg',texture_bg,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
            else % if this is a blank stimulus
                [stim,seed]=lib.stimulus('texture',texture_bg,'ml_b',ml,'cont_b',cont);
            end
            seeds(iTrial,iLevel,iSession)=seed;
            stimuli(:,:,iTrial,iLevel,iSession)=stim;
            edge=lib.edge_vector_ideal(stim,'mask',target_radius);
            edgePowers(iTrial,iLevel,iSession)=lib.edge_measures_ideal(edge);
            pClipped(iTrial,iLevel,iSession)=lib.compute_pClipped(stim(bdry_ribbon));
        end
    end
end