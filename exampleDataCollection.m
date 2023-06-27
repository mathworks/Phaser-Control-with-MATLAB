% Copyright 2023 The MathWorks, Inc.

%% Calculate the transmitter frequency

fc_hb100 = findTxFrequency();

%% Measure and save antenna gain profile

saveGainProfile(fc_hb100);

%% Calibrate Antenna

CalibrationData = calibrationRoutine(fc_hb100);

finalcalweights = CalibrationData.CalibrationWeights.FinalCalibrationWeights;

%% Collect additional calibration data for the example

CalibrationData = collectExampleCalibrationData(CalibrationData,fc_hb100);

CalibrationData = CalibrationData.toStruct();

save('CalibrationData.mat','CalibrationData');

%% Antenna Impairment

ImpairmentData = antennaImpairment(fc_hb100,finalcalweights);

save('ImpairmentData.mat','ImpairmentData');

%% Tapering

nbar = 2; sll = -20;
AntennaTaperData = antennaTapering(fc_hb100,finalcalweights,nbar,sll);

save('AntennaTaperData.mat','AntennaTaperData');

%% Null steering

nullangle = 20;
NullSteeringData = nullCancellation(fc_hb100,finalcalweights,nullangle);

save('NullSteeringData.mat','NullSteeringData');

