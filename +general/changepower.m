str='bark';
load([str,'/exp_settings.mat'])
load([str,'/subject_out/ad.mat'])

edgePowers=arrayfun(@(x,y) newpower(x,y,edge_powers), ExpSettings.stimuliSeed, ExpSettings.bTargetPresent);
edgePowerBlockEdges=linspace(min(edge_powers(:,2)),max(edge_powers(:,2)),11);
edgePowerBlockCenters=movmean(edgePowerBlockEdges,2,'Endpoints','discard');

ExpSettings.edgePowers=edgePowers;
ExpSettings.edgePowerBlockEdges=edgePowerBlockEdges;
ExpSettings.edgePowerBlockCenters=edgePowerBlockCenters;

SubjectExpFile.edgePowers=edgePowers;
SubjectExpFile.edgePowerBlockEdges=edgePowerBlockEdges;
SubjectExpFile.edgePowerBlockCenters=edgePowerBlockCenters;

save([str,'/exp_settings.mat'],'ExpSettings')
save([str,'/subject_out/ad.mat'],'SubjectExpFile')

function e=newpower(seed,btarget,edge_powers)
    if btarget
        e=edge_powers(seed,2);
    else
        e=edge_powers(seed,1);
    end
end