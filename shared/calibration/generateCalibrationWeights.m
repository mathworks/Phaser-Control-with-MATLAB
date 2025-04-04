function generateCalibrationWeights()
% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth. It should be
% sufficiently far from the antenna so that the wavefront is approximately
% planar.
%
% Notes:
% 
% Generate calibration weights for the phaser and save in
% CalibrationWeights.mat. These can be reused at a later time.
%
% Copyright 2023 The MathWorks, Inc.

% Turn off obsolete system object warning
warning('off','MATLAB:system:ObsoleteSystemObjectMixin');

% Find the hb100 center frequency and save it
fc_hb100 = findTxFrequency();
filepath = fileparts(which('generateCalibrationWeights'));
hb100_filename = [filepath,'\','HB100_Fc.mat'];
save(hb100_filename,"fc_hb100");

pause(5);

% Save the gain profile for the antenna.
saveGainProfile(fc_hb100);

pause(5);

% Get the calibration data
CalibrationData = calibrationRoutine(fc_hb100);

% Save the final calibration weights
calibrationweights = CalibrationData.CalibrationWeights.FinalCalibrationWeights;
filepath = fileparts(which('generateCalibrationWeights'));
calweights_filename = [filepath,'\','CalibrationWeights.mat'];
save(calweights_filename,"calibrationweights");

end