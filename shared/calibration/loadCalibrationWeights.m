function calibrationweights = loadCalibrationWeights()
% Copyright 2023 The MathWorks, Inc.

filepath = fileparts(which('generateCalibrationWeights'));
calweights_filename = [filepath,'\','CalibrationWeights.mat'];
if isfile(calweights_filename)
    load(calweights_filename,'calibrationweights');
else
    calibrationweights = CalibrationValueFormat;
end
    

end
