function setAnalogBfGain(bf,analogWeights)
    % Set the gain codes in the beamformer
    gainCodes = helperGainCodes(analogWeights);
    if ~isequal(bf.RxGain,gainCodes)
        bf.RxGain(:) = gainCodes;
    end
end