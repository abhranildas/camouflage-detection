function [stimuli, seeds, edgePowers, pClipped]=generate_camouflage_stimuli(texture,exp_type,edgePowerBlockEdges,nTrials,nSessions,bg_size,target_radius,ml,cont,bTargetPresent)
    load(['vislab-common/data/edge_powers/',exp_type,'.mat'],'edge_powers')
    [~,~,~,bdry_ribbon]=lib.target_mask('bg_size',bg_size,'target_radius',target_radius);
    nLevels=size(edgePowerBlockEdges,1);
    stimuli=zeros(bg_size,bg_size,nTrials,nLevels,nSessions);
    % seeds=zeros(nTrials,nLevels,nSessions);
    seeds=nan(nTrials*nSessions,nLevels);
    edgePowers=zeros(nTrials,nLevels,nSessions);
    pClipped=zeros(nTrials,nLevels,nSessions);
    
    % convert bTargetPresent to 1 page
    bTarget = permute(bTargetPresent,[1 3 2]);
    bTarget = reshape(bTarget,[],size(bTargetPresent,2),1);
    
    % sample all blank seeds
    seeds(~bTarget)=randsample(size(edge_powers,1),sum(~bTarget(:)));
    
    % sample target seeds
    for iLevel=1:nLevels
        seeds_available=find((edge_powers(:,2)>=edgePowerBlockEdges(iLevel,1))&...
            (edge_powers(:,2)<=edgePowerBlockEdges(iLevel,2)));
        seeds(bTarget(:,iLevel),iLevel)=randsample(seeds_available,nnz(bTarget(:,iLevel)));
    end
    
    % split seeds matrix into pages for separate sessions
    seeds=permute(seeds,[2 1]);
    seeds=reshape(seeds,[nLevels nTrials nSessions]);
    seeds=permute(seeds,[2 1 3]);
    
    % generate stimuli images
    for iLevel=1:nLevels
        for iSession=1:nSessions
            parfor iTrial=1:nTrials
                fprintf('Level %d Session %d Trial %d\n', [iLevel iSession iTrial])
                if bTargetPresent(iTrial,iLevel,iSession) % if this is a with-target stimulus
                    % seed=randsample(seeds_available,1);
                    seed=seeds(iTrial,iLevel,iSession);
                    edgePowers(iTrial,iLevel,iSession)=edge_powers(seed,2);
                    stim=lib.stimulus('texture',texture,'seed',seed,'bg_size',bg_size,'target_radius',target_radius,'ml_b',ml,'cont_b',cont);
                else % if this is a without-target stimulus
                    %  seed=randi([1 size(edge_powers,1)]); % randomly pick from all seeds
                    seed=seeds(iTrial,iLevel,iSession);
                    edgePowers(iTrial,iLevel,iSession)=edge_powers(seed,1);
                    stim=lib.stimulus('texture',texture,'seed',seed,'bg_size',bg_size,'ml_b',ml,'cont_b',cont);
                end
                seeds(iTrial,iLevel,iSession)=seed;
                stimuli(:,:,iTrial,iLevel,iSession)=stim;
                pClipped(iTrial,iLevel,iSession)=lib.compute_pClipped(stim(bdry_ribbon));
            end
        end
        %else
        %fprintf('Cannot choose %d from %d available stimuli in level %d\n',[nTrials,length(seeds_energies_available),iLevel]);
        %break
        %end
    end