function calibrationweights = loadCalibrationWeights()
% Copyright 2023 The MathWorks, Inc.

filepath = fileparts(which('generateCalibrationWeights'));
calweights_filename = [filepath,'\','CalibrationWeights.mat'];
load(calweights_filename,'calibrationweights');

end
