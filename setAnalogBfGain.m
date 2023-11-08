function setAnalogBfGain(bf,analogWeights)
    % Set the gain codes in the beamformer
    gainCodes = helperGainCodes(analogWeights);
    bf.RxGain(:) = gainCodes;
end