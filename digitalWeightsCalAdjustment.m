function adjustedWeights = digitalWeightsCalAdjustment(initialWeights,calibrationWeights)

% Need to flip our weights around because of how data is reported from the
% pluto
flippedCalibrationWeights = [calibrationWeights(2);calibrationWeights(1)];
adjustedWeights = weightsCalAdjustment(initialWeights,flippedCalibrationWeights);
adjustedWeights = [adjustedWeights(2);adjustedWeights(1)];    
end