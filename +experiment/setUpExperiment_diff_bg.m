function setUpExperiment_diff_bg(exp_type,subjectStr)
%SETUPEXPERIMENT Creates and saves all experimental stimuli and settings
%
% Example:
%  SETUPEXPERIMENT();
%
% Output:
%  None
%
% See also:
%   SESSIONSETTINGS
%
% v1.0, 2/18/2016, Steve Sebastian <sebastian@utexas.edu>

%% CAMOUFLAGE

ml=0.5;
cont=0.15;
bg_size=256; % in px
target_radius=64;
target_exponent=.5;
bg_exponents=linspace(0,1,10);
monitor_distance=60; % in PPD


global bdry_ribbon;
[~,~,~,bdry_ribbon]=lib.target_mask('bg_size',bg_size,'target_radius',target_radius);

%% Session files
ExpSettings = experiment.sessionSettings_diff_bg(exp_type, target_exponent, bg_exponents, ml, cont, bg_size, target_radius, monitor_distance);
folderOut= ['exp_files/' exp_type];
mkdir(folderOut);
fpOut = [folderOut '/exp_settings.mat'];
save(fpOut, 'ExpSettings');

%% Subject experiment files
%subjectStr = ['ad'; 'cw'; 'es'; 'wg'];

nSubjects = size(subjectStr, 1);

for iSubject = 1:nSubjects
    SubjectExpFile = experiment.subjectExperimentFile(ExpSettings);
    folderOut= ['exp_files/' exp_type '/subject_out'];
    mkdir(folderOut);
    fpOut = [folderOut '/' subjectStr(iSubject,:) '.mat'];
    save(fpOut, 'SubjectExpFile');
end