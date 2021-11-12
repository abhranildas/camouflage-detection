function [stimuli, seeds, edgePowers, pClipped, bTargetPresent]=transform_camouflage_stimuli(ExpNameStr,ml,cont)
    load(['exp_files/' ExpNameStr '/exp_settings.mat']);
    ml_old=ExpSettings.luminance;
    cont_old=ExpSettings.contrast;
    stimuli=ExpSettings.stimuli;
    
    % scale and shift stimuli to have new ml and cont:
    stimuli=stimuli*ml*cont/(ml_old*cont_old);
    stimuli=stimuli+ml*(1-cont/cont_old);
    
    % report clipping of transformed stimuli:
    nTrials=ExpSettings.nTrials;
    nBlocks=ExpSettings.nBlocks;
    nSessions=ExpSettings.nSessions;
    pClipped=zeros(nTrials,nBlocks,nSessions);
    for iSession=1:nSessions
        for iBlock=1:nBlocks
            for iTrial=1:nTrials
                stimulus=stimuli(:,:,iTrial,iBlock,iSession);
                pClipped(iTrial,iBlock,iSession)=lib.compute_pClipped(stimulus);
            end
        end        
    end
    
    seeds=ExpSettings.stimuliSeed;
    edgePowers=ExpSettings.edgePowers;
    bTargetPresent=ExpSettings.bTargetPresent;
