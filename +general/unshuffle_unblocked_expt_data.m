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
