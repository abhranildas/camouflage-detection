function setUpExperiment_texture_exponent(exp_type,subjectStr)
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
    
    luminance=0.5;
    contrast=0.15;
    bg_size=256; % in px
    target_radius=64; % in px
    exponents=linspace(.8,2,10);
    monitor_distance=60; % in PPD
    
    % for checking clipping in boundary ribbon region
    kernel_size=[1 3];
    
    texture_params.type='pink_noise';
    
    global bdry_ribbon;
    [~,~,~,bdry_ribbon]=lib.circular_mask(bg_size,target_radius,'center',kernel_size);
    
    %% Session files
    ExpSettings = experiment.sessionSettings_texture_exponent(exp_type,texture_params, exponents, luminance, contrast, bg_size, target_radius, monitor_distance);
    folderOut= ['exp_files/' exp_type];
    mkdir(folderOut);
    fpOut = [folderOut '/exp_settings.mat'];
    save(fpOut, 'ExpSettings');
    
    %% Subject experiment files
    %subjectStr = ['ad'; 'cw'; 'es'; 'wg'];
    
    nSubjects = size(subjectStr, 1);
    
    for iSubject = 1:nSubjects
        SubjectExpFile = experiment.subjectExperimentFile_alpha(ExpSettings);
        folderOut= ['exp_files/' exp_type '/subject_out'];
        mkdir(folderOut);
        fpOut = [folderOut '/' subjectStr(iSubject,:) '.mat'];
        save(fpOut, 'SubjectExpFile');
    end
end
