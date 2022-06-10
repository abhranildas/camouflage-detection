% compute edge group measures for the stimuli in an experiment

% load ExpSettings
% RENAME stimuliSeed to seeds

n_edge=1e3; % # of points in the edge vector

nTrials = ExpSettings.nTrials;
nLevels = ExpSettings.nLevels;
nSessions = ExpSettings.nSessions;

% stim_n_groups=nan(nTrials,nLevels,nSessions);
stim_l_groups=cell(nTrials,nLevels,nSessions);
stim_e_groups=cell(nTrials,nLevels,nSessions);

parfor iSession=1:nSessions
    for iLevel=1:nLevels
        for iTrial=1:nTrials
            stim=ExpSettings.stimuli(:,:,iTrial,iLevel,iSession);
            [~,~,l_groups,e_groups] = lib.edge(stim);
%             stim_n_groups(iTrial,iLevel,iSession)=n_groups;
            stim_l_groups{iTrial,iLevel,iSession}=l_groups;
            stim_e_groups{iTrial,iLevel,iSession}=e_groups;
            [iSession iLevel iTrial]
        end
    end
end

% ExpSettings.stim_n_groups=stim_n_groups;
ExpSettings.stim_l_groups=stim_l_groups;
ExpSettings.stim_e_groups=stim_e_groups;