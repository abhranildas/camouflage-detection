function experimentStruct = gettestexperimentstruct(BlockStimuli)

experimentStruct.bFovea       = 1;

experimentStruct.stimulusPosX = BlockStimuli.stimPosPix(:,:,1);
experimentStruct.stimulusPosY = BlockStimuli.stimPosPix(:,:,2);

experimentStruct.fixcrossPosX = BlockStimuli.stimPosPix(:,:,1);
experimentStruct.fixcrossPosY = BlockStimuli.stimPosPix(:,:,2);

experimentStruct.stimulusDuration = 3;
experimentStruct.ppd = 120;
experimentStruct.correctResponse = BlockStimuli.bTargetPresent(:,1);
experimentStruct.nTrials = size(BlockStimuli.stimPosPix(:,:,1),1);
experimentStruct.target = zeros(21,21);
experimentStruct.backgroundcolour = 44.0609;
experimentStruct.STIMULUSDELAY = 1;

experimentStruct.nLevels = size(BlockStimuli.bTargetPresent,2);
end