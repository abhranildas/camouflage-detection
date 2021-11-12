% before running experiment
ExpSettings.bTargetPresent=flip(ExpSettings.bTargetPresent,2);
ExpSettings.stimuli=flip(ExpSettings.stimuli,4);

% after running experiment
SubjectExpFile.bTargetPresent=flip(SubjectExpFile.bTargetPresent,2);
SubjectExpFile.response=flip(SubjectExpFile.response,2);
SubjectExpFile.hit=flip(SubjectExpFile.hit,2);
SubjectExpFile.miss=flip(SubjectExpFile.miss,2);
SubjectExpFile.falseAlarm=flip(SubjectExpFile.falseAlarm,2);
SubjectExpFile.correct=flip(SubjectExpFile.correct,2);
SubjectExpFile.correctRejection=flip(SubjectExpFile.correctRejection,2);

ExpSettings.bTargetPresent=flip(ExpSettings.bTargetPresent,2);
ExpSettings.stimuli=flip(ExpSettings.stimuli,4);
