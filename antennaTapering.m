function AntennaTaperData = antennaTapering(fc_hb100,CalibrationData,nbar,sll)
% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth. It should be
% sufficiently far from the antenna so that the wavefront is approximately
% planar.
%
% Notes:
% 
% This script applies a taper to the antenna pattern in order to reduce the
% sidelobe levels.
%
% For information on nbar and sll, see https://www.mathworks.com/help/phased/ug/tapering-thinning-and-arrays-with-different-sensor-patterns.html

% Copyright 2023 The MathWorks, Inc.

% Setup the antenna interactor
antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);
analogWeights = CalibrationData.AnalogWeights;

% Capture the initial pattern data
steerangles = -90:0.5:90;
patternData = antennaInteractor.capturePattern(steerangles);
ampbeforetaper = mag2db(helperGetAmplitude(patternData));

% Apply a taper to the analog weights
nsubs = 2;
nels = 8;
taper = taylorwin(nels,nbar,sll);
taper = taper / max(taper);
taper = reshape(taper,[nels/nsubs,nsubs]);
analogTaperWeights = analogWeights .* taper;
analogTaperWeights = analogTaperWeights ./ max(abs(analogTaperWeights));
antennaInteractor.updateAnalogWeights(analogTaperWeights);

% Get pattern with taper
patternData = antennaInteractor.capturePattern(steerangles);
taperamp = mag2db(helperGetAmplitude(patternData));

% Get simulate taper data
rxpos = [0;0;0];
txpos = [0;10;0];
simpattern = mag2db(helperSimulateAntennaSteering(fc_hb100,rxpos,txpos,steerangles,taper));

ax = axes(figure); hold(ax,"on");
plot(ax,steerangles,ampbeforetaper-max(ampbeforetaper),"DisplayName","Without Taper")
plot(ax,steerangles,taperamp-max(taperamp),"DisplayName","With Taper");
plot(ax,[steerangles(1),steerangles(end)],[sll,sll],"DisplayName","Side Lobe Level","Color","k","LineStyle","--")
plot(ax,steerangles,simpattern-max(simpattern),"DisplayName","Simulated Taper")
legend(ax,Location="southeast"); title(ax,"Antenna Tapering")

% Save data for later analysis
AntennaTaperData.SteerAngles = steerangles;
AntennaTaperData.Taper = taper;
AntennaTaperData.PatternBeforeNull = patternData;
AntennaTaperData.TaperedPattern = patternData;

end

