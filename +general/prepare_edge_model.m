%% precompute stimulus cues

% load edge model
exp_idx=numel(edge_model)+1;
edge_model(exp_idx).name='natural/soil';

% load ExpSettings
nTrials=ExpSettings.nTrials;
nLevels=ExpSettings.nLevels;
nSessions=ExpSettings.nSessions;
stimulus_size=ExpSettings.stimulus_size;

% pool all sessions
target=reshape(permute(ExpSettings.bTargetPresent,[1 3 2]),[nTrials*nSessions nLevels]);

stimuli=reshape(permute(ExpSettings.stimuli,[1 2 3 5 4]),[stimulus_size stimulus_size nTrials*nSessions nLevels]);
stimuli=squeeze(num2cell(stimuli,[1 2]));

% stimuli=squeeze(num2cell(ExpSettings.stimuli,[1 2]));

[txtr_edge_density,n_bdry_edge_pixels]=cellfun(@(stim) lib.edge_measures(stim),stimuli);

edge_model(exp_idx).target=target;
edge_model(exp_idx).txtr_edge_density=txtr_edge_density;
edge_model(exp_idx).n_bdry_edge_pixels=n_bdry_edge_pixels;

%% gather subject data

% load SubjectExpFile
if ~exist('subject_data','var')
    subject_data=struct;
    subj_idx=1;
else
    subj_idx=numel(subject_data)+1;
end

subject_data(subj_idx).name='adriana';

subject_data(subj_idx).response=reshape(permute(SubjectExpFile.response,[1 3 2]),[nTrials*nSessions nLevels]);
subject_data(subj_idx).hit=reshape(permute(SubjectExpFile.hit,[1 3 2]),[nTrials*nSessions nLevels]);
subject_data(subj_idx).miss=reshape(permute(SubjectExpFile.miss,[1 3 2]),[nTrials*nSessions nLevels]);
subject_data(subj_idx).falseAlarm=reshape(permute(SubjectExpFile.falseAlarm,[1 3 2]),[nTrials*nSessions nLevels]);
subject_data(subj_idx).correctRejection=reshape(permute(SubjectExpFile.correctRejection,[1 3 2]),[nTrials*nSessions nLevels]);
subject_data(subj_idx).correct=reshape(permute(SubjectExpFile.correct,[1 3 2]),[nTrials*nSessions nLevels]);

edge_model(exp_idx).subject_data=subject_data;
