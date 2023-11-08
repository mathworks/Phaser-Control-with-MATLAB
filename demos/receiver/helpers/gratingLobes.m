function gratingLobes(fc_hb100,CalibrationData)
% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth. It should be
% sufficiently far from the antenna so that the wavefront is approximately
% planar.
%
% Notes:
% 
% This script disables antenna elements 1 and 3 on each subarray. This 
% is meant to simulate a 4 element array with 1 lambda element spacing
% to show the presence of grating lobes.

% Copyright 2023 The MathWorks, Inc.

% Set the max data value
adcbits = 12;
maxdatavalue = 2^(adcbits-1);

% Set up the antenna interactor which captures data from the ADI board
antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);
analogWeights = CalibrationData.AnalogWeights;

% Disable element 1 and 3
disableelement = [1,3];
disabledAnalogWeights = analogWeights;
disabledAnalogWeights(disableelement,:) = 0;

% Set steering angles
steerangles = -90:0.5:90;

% Capture the pattern with the element disabled
antennaInteractor.updateAnalogWeights(disabledAnalogWeights);
patternData = antennaInteractor.capturePattern(steerangles);
capturedamp = helperCalculateAmplitude(patternData,maxdatavalue);

% Simulate the collected data with the same elements impaired
simpattern = mag2db(helperSimulateDisabledElement(fc_hb100,steerangles,disableelement));


% Setup figure
ax = axes(figure);
hold(ax,"on")
title(ax,"Grating Lobes (1 lambda spacing)")
plot(ax,steerangles,capturedamp-max(capturedamp),"DisplayName","Collected Data");
plot(ax,steerangles,simpattern-max(simpattern),"DisplayName","Simulated Data");
legend(ax);
end

