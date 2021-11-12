% Display example stimuli. Edge energy increases along row. Different rows are different samples.
bg_size=256;
target_radius=64;
pTarget=1;
nSessions=2;
nBlocks=10;
nTrials=1;
ml=0.5; cont=.15;
edgeEnergyBlockEdges=linspace(.1067,1.4671,nBlocks+1); %ratio of perp gradients
%edgeEnergyBlockEdges=linspace(.67,.95,nBlocks+1); %mag+dir/mag
%edgeEnergyLevels=linspace(36,139,nLevels);  %mag+dir
%edgeEnergyLevels=linspace(324,457,nLevels);  %dir
%edgeEnergyLevels=linspace(50,152,nLevels);  %mag
bTargetPresent=rand(nTrials,nBlocks,nSessions)<pTarget;
[stimuli, seeds, edgeEnergies]=experiment.generate_camouflage_stimuli(edgeEnergyBlockEdges,nTrials,nSessions,bg_size,target_radius,ml,cont,bTargetPresent);
figure
for iBlock=1:nBlocks
    for iTrial=1:nTrials
        subplot('Position',[(iBlock-1)/nBlocks (iTrial-1)/nTrials 1/nBlocks 1/nTrials])
        experiment.show_image(stimuli(:,:,iTrial,iBlock));
        colorbar off
        axis on
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
    end
end