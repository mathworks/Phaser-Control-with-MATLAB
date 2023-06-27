function ImpairmentData = antennaImpairment(fc_hb100,CalibrationData)
% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth. It should be
% sufficiently far from the antenna so that the wavefront is approximately
% planar.
%
% Notes:
% 
% This script disables certain antenna elements to see the effect that
% doing so has on the array factor. The measured data is compared to
% simulated data to show that the Phase Array System Toolbox can be used to
% model these kinds of effects.

% Copyright 2023 The MathWorks, Inc.

% Set up the antenna interactor which captures data from the ADI board
antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);
analogWeights = CalibrationData.AnalogWeights;

% Disable each element 1 by 1
element = 1:4;

% Setup tiled layout figure
f = figure; tiledlayout(f,2,2);

% Create an impairement data struct for later analysis
ImpairmentData = struct;

% Set steering angles
steerangles = -90:0.5:90;

% Steer the pattern impairing each element along the way
for iEl = element
    % Setup new tile axes
    ax = nexttile(); hold(ax,"on"); legend(ax,"Location","southwest");
    title(ax,['Disable Element ',num2str(iEl)]);

    % Update the analog weights to disable current element
    disabledAnalogWeights = analogWeights;
    disabledAnalogWeights(iEl,:) = 0;
    antennaInteractor.updateAnalogWeights(disabledAnalogWeights);

    % Capture the pattern with the element disabled
    patternData = antennaInteractor.capturePattern(steerangles);
    capturedamp = mag2db(helperGetAmplitude(patternData));

    % Simulate the collected data with the same elements impaired
    simpattern = mag2db(helperSimulateDisabledElement(fc_hb100,steerangles,iEl));

    plot(ax,steerangles,capturedamp-max(capturedamp),"DisplayName","Impaired Pattern");
    plot(ax,steerangles,simpattern-max(simpattern),"DisplayName","Simulated Impaired Pattern");

    % Save data
    ImpairmentData(iEl).SteerAngle = steerangles;
    ImpairmentData(iEl).Element = iEl;
    ImpairmentData(iEl).Pattern = patternData;
end

end

