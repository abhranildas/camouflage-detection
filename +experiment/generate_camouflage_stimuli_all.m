function [stimuli, textures, seeds, bTargetPresent, pClipped]=generate_camouflage_stimuli_all(texture_list,nTex,nTrials_eachtx,nTrials,nLevels,nSessions,bg_size,target_radius,ml,cont,bTargetPresent)

[~,~,~,bdry_ribbon]=lib.target_mask('bg_size',bg_size,'target_radius',target_radius);
stimuli_flat=zeros(bg_size,bg_size,nTrials_eachtx,nTex);
seeds=nan(nTrials_eachtx,nTex);
pClipped=zeros(nTrials_eachtx,nTex);

% create target present array (exactly equal targets and blanks)
bTargetPresent=[true(nTrials_eachtx/2,nTex);false(nTrials_eachtx/2,nTex)];

% generate stimuli images
for iTex=1:nTex
    texture=texture_list(iTex);
    for iTrial=1:nTrials_eachtx
        fprintf('Texture %d trial %d\n', [iTex iTrial])
        if bTargetPresent(iTrial,iTex) % if this is a with-target stimulus
            [stim,~,seed]=lib.stimulus('texture',texture,'bg_size',bg_size,'target_radius',target_radius,'ml_b',ml,'cont_b',cont,'ml_t',ml,'cont_t',cont);
        else % if this is a without-target stimulus
            [stim,~,seed]=lib.stimulus('texture',texture,'bg_size',bg_size,'ml_b',ml,'cont_b',cont,'ml_t',ml,'cont_t',cont);
        end
        seeds(iTrial,iTex)=seed;
        stimuli_flat(:,:,iTrial,iTex)=stim;
        pClipped(iTrial,iTex)=lib.compute_pClipped(stim(bdry_ribbon));
    end
end

% reshape the trials to the usual experiment array
trialidx=reshape(randperm(numel(seeds)),[nTrials nLevels nSessions]);
seeds=seeds(trialidx);
pClipped=pClipped(trialidx);
bTargetPresent=bTargetPresent(trialidx);
stimuli=nan(bg_size,bg_size,nTrials,nLevels,nSessions);
textures=struct('type',{},'img',{},'scale',{},'exponent',{});

for iTrial=1:nTrials
    for iLevel=1:nLevels
        for iSession=1:nSessions
            [stim_iTrial,stim_iTex]=ind2sub([nTrials_eachtx nTex], trialidx(iTrial,iLevel,iSession));
            stimuli(:,:,iTrial,iLevel,iSession)=stimuli_flat(:,:,stim_iTrial,stim_iTex);
            textures(iTrial,iLevel,iSession)=texture_list(stim_iTex);
        end
    end
end

