function setUpExperiment_all(subjectStr)
% Portilla-Simoncelli texture
addpath(genpath('por_sim_tx_synth'))

luminance=0.5;
contrast=0.15;
bg_size=256; % in px
target_radius=64; % in px
%     nLevels=10;
ppd=60; % in PPD

%% Session files
ExpSettings = experiment.sessionSettings_all(luminance, contrast, bg_size, target_radius, ppd);
folderOut= 'exp_files/all';
mkdir(folderOut);
fpOut = [folderOut '/exp_settings.mat'];
save(fpOut, 'ExpSettings');

%% Subject experiment files
%subjectStr = ['ad'; 'cw'; 'es'; 'wg'];

nSubjects = size(subjectStr, 1);

for iSubject = 1:nSubjects
    SubjectExpFile = experiment.subjectExperimentFile(ExpSettings);
    folderOut='exp_files/all/subject_out';
    mkdir(folderOut);
    fpOut = [folderOut '/' subjectStr(iSubject,:) '.mat'];
    save(fpOut, 'SubjectExpFile');
end
end
