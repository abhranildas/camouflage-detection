function giveFeedback(SessionSettings, response, trialNumber, levelNumber)

%% Sound parameters
sampleFreqHz = 22050;              
toneDurationS = 0.05;            
numSamples = sampleFreqHz * toneDurationS;   
soundData = (1:numSamples)/sampleFreqHz;         

correctFreqHz   = 900;                      
incorrectFreqHz = 300;                    
errorFreqHz     = 1500;                      

correctTone  = sin(2*pi*correctFreqHz *soundData);    
incorrectTone = sin(2*pi*incorrectFreqHz*soundData);  
errorTone    = sin(2*pi*errorFreqHz*soundData);    

% Feedback
if(response == -1)
    sound(errorTone, sampleFreqHz);
elseif(SessionSettings.bTargetPresent(trialNumber,levelNumber) == response)
    sound(correctTone, sampleFreqHz);
else
    sound(incorrectTone, sampleFreqHz);
end