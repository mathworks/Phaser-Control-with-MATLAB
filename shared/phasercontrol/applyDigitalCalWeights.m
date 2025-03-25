function outdata = applyDigitalCalWeights(indata)
% Apply the digital calibration weights to the input data signal.

calweights = loadCalibrationWeights().DigitalWeights;
outdata = indata * conj(calweights);

end

