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
