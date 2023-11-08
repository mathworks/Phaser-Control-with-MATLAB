function setAnalogBfWeights(bf,analogWeights)
    % Set phase shifter and gain values in the beamformer
    setAnalogBfPhaseShift(bf,analogWeights);
    setAnalogBfGain(bf,analogWeights);
    bf.LatchRxSettings();
end