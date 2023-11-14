function NullSteeringData = nullCancellation(fc_hb100,CalibrationData,nullangle)
% Setup:
%
% Place an HB100 in front of the Phaser - 0 degree azimuth.
%
% Notes:
% 
% This script applies a null at the angle specified. The results are
% compared agains simulated results

% Copyright 2023 The MathWorks, Inc.

antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);
steerangles = -90:0.5:90;

% Capture pattern with nulling
nullPatternData = antennaInteractor.capturePatternWithNull(steerangles,nullangle);
ampafter = helperGetAmplitude(nullPatternData);
ampafterdb = mag2db(ampafter);

% Simulate pattern with nulling
simpattern = helperSimulateNull(fc_hb100,steerangles,nullangle);
simdb = mag2db(simpattern);

% Plot the pattern with and without nulling
ax = axes(figure); hold(ax,"on"); title(ax,"Pattern Nulling")
plot(ax,steerangles,ampafterdb-max(ampafterdb),"DisplayName","Collected With Nulling");
plot(ax,steerangles,simdb-max(simdb),"DisplayName","Simulated Nulling")
legend(Location="southeast");

% Save data for later analysis
NullSteeringData.SteerAngles = steerangles;
NullSteeringData.NullAngle = nullangle;
NullSteeringData.PatternAfterNull = ampafterdb;

end
