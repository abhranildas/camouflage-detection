function setUpExperiment_search(exp_type,subjectStr)

%% experiment settings
ExpSettings.monitorBit = 8;
ExpSettings.monitorGamma = 2.059;
ExpSettings.nTrials = 120;
ExpSettings.cue_on = .75;
ExpSettings.blank =.25;
ExpSettings.stim_on = .25;
ExpSettings.responseWait = 1.5;

% if strcmpi(exp_type,'detect')
    ExpSettings.nSessions = 19;
% elseif strcmpi(exp_type,'search')
    % ExpSettings.nSessions = 4;
% end


%% generate stimulus parameters
Stimulus.ppd = 60;
Stimulus.stimulus_sz = 1200;
Stimulus.nDirections = 6;
Stimulus.spotLength = 208;
Stimulus.spotResize = 2;
Stimulus.spotDistance = 240;
Stimulus.spotCenters = [Stimulus.stimulus_sz/2,Stimulus.stimulus_sz/2];
Stimulus.spotCenters = lib.find_spot_centers(Stimulus.spotCenters, Stimulus.spotCenters,...
    Stimulus.spotLength, Stimulus.spotDistance, Stimulus.stimulus_sz, Stimulus.nDirections);
Stimulus.nLocations = size(Stimulus.spotCenters,1);

texture=struct;
texture.type='pink_noise';
texture.exponent=1.3;
Stimulus.texture=texture;

Stimulus.target_radius=64;
Stimulus.ml=0.5;
Stimulus.cont=0.15;
Stimulus.clipTolerance = 0.001;
Stimulus.bgMean = 2^(ExpSettings.monitorBit-1);
Stimulus.bgContrast = 0.2;

Stimulus.seeds=nan(ExpSettings.nTrials, ExpSettings.nSessions);
Stimulus.stimuli=nan(Stimulus.stimulus_sz,Stimulus.stimulus_sz,ExpSettings.nTrials,ExpSettings.nSessions);

Stimulus.tLocation = nan(ExpSettings.nTrials, ExpSettings.nSessions);
for iSession = 1:ExpSettings.nSessions
    for iTrial = 1:ExpSettings.nTrials        
        % generate target location
        if rand < 0.5
            target_loc=0;
        else
            if strcmpi(exp_type,'detect')
                target_loc=1;
            elseif strcmpi(exp_type,'search')
                target_loc=randi(Stimulus.nLocations);
            end
        end
        Stimulus.tLocation(iTrial, iSession) = target_loc;
        [iSession iTrial target_loc]
        % create stimulus
        if target_loc % if there is a target
            if strcmpi(exp_type,'detect')
                target_loc=iSession;
            end
            target_coords=Stimulus.spotCenters(target_loc,:);
            [stim,~,seed]=lib.stimulus('texture',texture,'bg_size',Stimulus.stimulus_sz,'target_radius',Stimulus.target_radius,'target_loc',target_coords,'ml_b',Stimulus.ml,'cont_b',Stimulus.cont);
        else
            [stim,~,seed]=lib.stimulus('texture',texture,'bg_size',Stimulus.stimulus_sz,'ml_b',Stimulus.ml,'cont_b',Stimulus.cont);
        end
        stim=uint8(lib.gammaCorrect(stim,ExpSettings.monitorGamma,ExpSettings.monitorBit));
        Stimulus.stimuli(:,:,iTrial,iSession)=stim;
        Stimulus.seeds(iTrial,iSession)=seed;        
    end
end

%% store experiment and stimulus
folderOut= ['exp_files/search/' exp_type];
mkdir(folderOut);
fpOut = [folderOut '/exp_settings.mat'];
save(fpOut, 'ExpSettings', 'Stimulus', '-v7.3');

%% Subject result files
SubjectExpFile.expCompleted = false(ExpSettings.nSessions,1);
if strcmpi(exp_type,'detect')
    SubjectExpFile.response = false(ExpSettings.nTrials, ExpSettings.nSessions);
elseif strcmpi(exp_type,'search')
    SubjectExpFile.response = zeros(ExpSettings.nTrials, ExpSettings.nSessions);
end
SubjectExpFile.reactionTime = zeros(ExpSettings.nTrials, ExpSettings.nSessions);

folderOut= ['exp_files/search/' exp_type '/subject_out'];
mkdir(folderOut);
fpOut = [folderOut '/' subjectStr '.mat'];
save(fpOut, 'SubjectExpFile');
