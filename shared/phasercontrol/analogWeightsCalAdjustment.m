function adjustedWeights = analogWeightsCalAdjustment(initialWeights,calibrationWeights)
% This function adjusts the analog steering weights by the analog
% calibration weights that were calculated for the Phaser. 
% 
% Copyright 2023 The MathWorks, Inc.

adjustedWeights = weightsCalAdjustment(initialWeights,calibrationWeights);

end