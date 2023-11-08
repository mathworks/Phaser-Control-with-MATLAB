function adjustedWeights = weightsCalAdjustment(initialWeights,calibrationWeights)
    % Adjust the weights with the calibration values
    adjustedWeights = initialWeights .* calibrationWeights;
end