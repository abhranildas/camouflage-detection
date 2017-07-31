          function [response,responseTimeMs] = runTrial(SessionSettings, trialNumber, levelNumber)
%SINGLETRIALDETECTION Runs a single trialNumber of the detection experiment
%
% Example: 
%   [response, responseOnsetMs] = SINGLETRIALDETECTION(experimentStruct, stimulus, levelNumber, trialNumber);
%   
%   See also PRESENTFIXATIONCROSS, DRAWSTIMULUS.
%
% v1.0, 1/20/2016, R. C. Walshe <calen.walshe@utexas.edu>

if(~SessionSettings.bFovea)      
    
    % Sending a 'TRIALID' message to mark the start of a trial in Data 
    % Viewer.  This is different than the start of recording message 
    % START that is logged when the trial recording begins. The viewer
    % will not parse any messages, events, or samples, that exist in 
    % the data file prior to this message. 
    % start recording eye position
    Eyelink('StartRecording');
    WaitSecs(.01);
    
    Eyelink('Message', 'TRIALID %d', trialNumber);
    Eyelink('Message', '!V TRIAL_VAR index %s',   num2str(trialNumber));
    Eyelink('Message', '!V TRIAL_VAR session %s', num2str(SessionSettings.currentSession));
    Eyelink('Message', '!V TRIAL_VAR level %s',   num2str(levelNumber));
    Eyelink('Message', '!V TRIAL_VAR bin %s',     num2str(SessionSettings.currentBin));
    Eyelink('Message', '!V TRIAL_VAR FIX_CROSS_X %s', num2str(SessionSettings.fixPosPix(trialNumber, levelNumber, 1)));
    Eyelink('Message', '!V TRIAL_VAR FIX_CROSS_Y %s', num2str(SessionSettings.fixPosPix(trialNumber, levelNumber, 2)));
             
    experiment.main.checkFixationCross(SessionSettings, SessionSettings.fixPosPix(trialNumber, levelNumber, :));
end

experiment.main.fixationInterval(SessionSettings, trialNumber, levelNumber);

experiment.main.stimulusInterval(SessionSettings, trialNumber, levelNumber);

[response, responseTimeMs] = experiment.main.responseInterval(SessionSettings, trialNumber, levelNumber);

experiment.main.giveFeedback(SessionSettings, response, trialNumber, levelNumber);

if(~SessionSettings.bFovea)
    Eyelink('Message', 'TRIAL_RESULT 0');
end