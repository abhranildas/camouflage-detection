function setUpExperiment(exp_type,subjectStr)
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
%     nLevels=10;
    monitor_distance=60; % in PPD
    transformExpName=''; % transform ml & cont of stimuli of existing experiment, or leave blank
    
    if strcmp(exp_type,'pink_noise')
        %         seed_energy_file='seed_energy_pn_gradbynorm';
        texture_params.type='pink_noise';
    else
        %         seed_energy_file='edge_strengths_bark';
        % for bark texture with portilla simoncelli:
        addpath(genpath('por_sim_tx_synth'))
        input_img=['global_data/images/',exp_type,'.png'];
        im0=double(im2gray(imread(input_img)));
        
        Nsc = 4; % Number of scales
        Nor = 4; % Number of orientations
        Na = 9;  % Spatial neighborhood is Na x Na coefficients
        Niter = 25;	% Number of iterations of synthesis loop
        
        texture_params=struct;
        texture_params.type='por_sim';
        texture_params.stats=textureAnalysis(im0, Nsc, Nor, Na);
        texture_params.Niter=Niter;
    end
    
    % load edge power file
    load(['global_data/edge_powers/',exp_type,'.mat'],'edgePowerBlockEdges');
    
    % find the widest span around the mean edge power,
    % such that 10 equal-width bins each have >=80 samples (to be safe; exp. needs
    % ~60 target samples in each bin).
%     dist_mean=mean(edge_powers(:,2));
%     dist_span=(max(edge_powers(:,2))-min(edge_powers(:,2)))/2;
%     while true
%         h=histcounts(edge_powers(:,2),linspace(dist_mean-dist_span,dist_mean+dist_span,nLevels+1));
%         if min(h)>80
%             break
%         else
%             dist_span=.9*dist_span;
%         end
%     end
    
%     edgePowerBlockEdges=linspace(dist_mean-dist_span,dist_mean+dist_span,nLevels+1);
%     edgePowerBlockEdges = linspace(min(edge_powers(:,2)),max(edge_powers(:,2)),nLevels+1);
        
    % for checking clipping in boundary ribbon region
    global bdry_ribbon;
    [~,~,~,bdry_ribbon]=lib.target_mask('bg_size',bg_size,'target_radius',target_radius);
    
    %% Session files
    %for iCondition = 1:nConditions
    ExpSettings = experiment.sessionSettings(exp_type, texture_params, luminance, contrast, bg_size, target_radius, edgePowerBlockEdges, monitor_distance, transformExpName);
%     if strcmp(exp_type,'pink_noise')
%         folderOut= ['exp_files/' exp_type '_L' num2str(luminance) '_C' num2str(contrast)];
%     else
        folderOut= ['exp_files/' exp_type];
%     end
    mkdir(folderOut);
    fpOut = [folderOut '/exp_settings.mat'];
    save(fpOut, 'ExpSettings');
    %end
    
    %% Subject experiment files
    %subjectStr = ['ad'; 'cw'; 'es'; 'wg'];
    
    nSubjects = size(subjectStr, 1);
    
    for iSubject = 1:nSubjects
        SubjectExpFile = experiment.subjectExperimentFile(ExpSettings);
        %             folderOut= ['exp_files/' exp_type '_L' num2str(luminance) '_C' num2str(contrast) '/subject_out'];
        folderOut= ['exp_files/' exp_type '/subject_out'];
        mkdir(folderOut);
        fpOut = [folderOut '/' subjectStr(iSubject,:) '.mat'];
        save(fpOut, 'SubjectExpFile');
    end
end
