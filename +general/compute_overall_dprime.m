% compute pmf parameters
[th,b,c]=experiment.analysis.computeThreshold_edgePower('pink_noise','neel',1,0);
mu=0;
a=th-mu;

% load edge powers
%load('global_data/edge_powers_pink_noise.mat','edge_powers')

[~,~,~,dprimes]=experiment.analysis.psychometricFun(edge_powers(:,2),mu,a,b,c);

figure; histogram(dprimes,'normalization','pdf')
d=mean(dprimes)
normcdf(d/2)

%% unblock/shuffle pink noise experiment
idx=randperm(numel(ExpSettings.stimuliSeed));

ExpSettings2.stimuliSeed=reshape(ExpSettings.stimuliSeed(idx), size(ExpSettings.stimuliSeed));
ExpSettings2.bTargetPresent=reshape(ExpSettings.bTargetPresent(idx), size(ExpSettings.bTargetPresent));
ExpSettings2.edgePowers=reshape(ExpSettings.edgePowers(idx), size(ExpSettings.edgePowers));
ExpSettings2.pClipped=reshape(ExpSettings.pClipped(idx), size(ExpSettings.pClipped));
stimuli=nan(size(ExpSettings.stimuli));

for iter=1:numel(idx)
    [i2,j2,k2]=ind2sub(size(ExpSettings.stimuliSeed),iter);
    [i,j,k]=ind2sub(size(ExpSettings.stimuliSeed),idx(iter));
    stimuli(:,:,i2,j2,k2)=ExpSettings.stimuli(:,:,i,j,k);
    iter=iter+1
end

ExpSettings2.stimuli=stimuli;

SubjectExpFile.stimuliSeed=ExpSettings.stimuliSeed;
SubjectExpFile.bTargetPresent=ExpSettings.bTargetPresent;
SubjectExpFile.edgePowers=ExpSettings.edgePowers;
SubjectExpFile.stimuli=ExpSettings.stimuli;