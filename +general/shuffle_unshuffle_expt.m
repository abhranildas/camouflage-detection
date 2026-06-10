%% shuffle pink noise experiment
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

%% shuffle the experiment
% load ExpSettings and shuffle indices
ExpSettings_shuffle=ExpSettings;
for idx_orig=1:ExpSettings_shuffle.nSessions*ExpSettings_shuffle.nLevels*ExpSettings_shuffle.nTrials
    ExpSettings_shuffle.bTargetPresent(idx_orig)=ExpSettings.bTargetPresent(idx(idx_orig));
    ExpSettings_shuffle.edgePowers(idx_orig)=ExpSettings.edgePowers(idx(idx_orig));
    ExpSettings_shuffle.seeds(idx_orig)=ExpSettings.seeds(idx(idx_orig));

    [iTrial,iLevel,iSession]=ind2sub([30 10 4],idx_orig);
    [iTrial_shuffle,iLevel_shuffle,iSession_shuffle]=ind2sub([30 10 4],idx(idx_orig));
    ExpSettings_shuffle.stimuli(:,:,iTrial,iLevel,iSession)=ExpSettings.stimuli(:,:,iTrial_shuffle,iLevel_shuffle,iSession_shuffle);
end


%% unshuffle the data

% load unblocked experiment, and rename SubjectExpFile to SubjectExpFile_unblocked
% load shuffle indices
% load blocked experiment

SubjectExpFile.response(idx)=SubjectExpFile_unblocked.response;
SubjectExpFile.hit(idx)=SubjectExpFile_unblocked.hit;
SubjectExpFile.miss(idx)=SubjectExpFile_unblocked.miss;
SubjectExpFile.falseAlarm(idx)=SubjectExpFile_unblocked.falseAlarm;
SubjectExpFile.correctRejection(idx)=SubjectExpFile_unblocked.correctRejection;
SubjectExpFile.correct(idx)=SubjectExpFile_unblocked.correct;

% save SubjectExpFile and SubjectExpFile_unblocked
