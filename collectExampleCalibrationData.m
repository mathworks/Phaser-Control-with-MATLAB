function CalibrationData = collectExampleCalibrationData(CalibrationData,fc_hb100)
arguments
    CalibrationData (1,1) CalibrationDataFormat
    fc_hb100 (1,1) double
end

% Copyright 2023 The MathWorks, Inc.

% Set the max data value
adcbits = 12;
maxdatavalue = 2^(adcbits-1);

% Antenna interactor steers the phaser
uncal = CalibrationData.CalibrationWeights.UncalibratedWeights;
antennaInteractor = AntennaInteractor(fc_hb100,uncal);

% Capture a snapshot of example data
[~,CalibrationData.ExampleData] = antennaInteractor.capturePattern(0);

% Capture the uncalibrated antenna pattern
steerangles = -90:0.5:90;
CalibrationData.AntennaPattern.SteeringAngle = steerangles;
CalibrationData.AntennaPattern.UncalibratedPattern = helperCalculateAmplitude(antennaInteractor.capturePattern(steerangles),maxdatavalue);

% Capture the analog fine amplitude calibration pattern
analogfineampcal = CalibrationData.CalibrationWeights.AnalogFineAmplitudeWeights;
antennaInteractor.updateCalibration(analogfineampcal);
CalibrationData.AntennaPattern.AnalogFineAmplitudeCalPattern = helperCalculateAmplitude(antennaInteractor.capturePattern(steerangles),maxdatavalue);

% Capture the final calibration pattern
finalcal = CalibrationData.CalibrationWeights.FinalCalibrationWeights;
antennaInteractor.updateCalibration(finalcal);
CalibrationData.AntennaPattern.FullCalibration = helperCalculateAmplitude(antennaInteractor.capturePattern(steerangles),maxdatavalue);

end

