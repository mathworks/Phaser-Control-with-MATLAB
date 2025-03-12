function [monopulsePattern,MonopulseData] = createMonopulsePattern(fc_hb100,CalibrationData,targetangle,targetoffset)

% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth. It should be
% sufficiently far from the antenna so that the wavefront is approximately
% planar.
%
% Notes:
% 
% This function creates a monopulse pattern at targetangle +- targetoffset.
% This monopulse pattern can be used to approximate the location of the
% target with a single detection if the beam is steered in the general
% direction of the target.

% Copyright 2023 The MathWorks, Inc.

antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);

% steer angles generated based on target angle and offset
steerangles = targetangle-targetoffset:0.5:targetangle+targetoffset;

% Collect monopulse data
[sumdiffampdelta,sumdiffphasedelta,patternsumdata,patterndiffdata] = antennaInteractor.captureMonopulsePattern(steerangles);
sumampdb = mag2db(helperGetAmplitude(patternsumdata));
diffampdb = mag2db(helperGetAmplitude(patterndiffdata));

% Create monopulse pattern.
oba = steerangles-targetangle;
monopulsePattern = MonopulsePattern(sumdiffampdelta,sumdiffphasedelta,oba);

% Simulate monopulse pattern
[simsumamp,simdiffamp,simphasedelta] = helperSimulateMonopulse(fc_hb100,steerangles);
simsumdb = mag2db(simsumamp);
simdiffdb = mag2db(simdiffamp);

% Setup figure
f = figure; tiledlayout(f,1,2);

% Create a tile for the antenna pattern
patternax = nexttile();
hold(patternax,"on")
legend(patternax,"Location","southeast");
title(patternax,"Sum-Diff Amplitudes");
xlabel(patternax,"Azimuth Angle (Degrees)");
ylabel(patternax,"Normalized dB");
plot(patternax,steerangles,sumampdb-max(sumampdb),'DisplayName','Collected Sum Channel');
plot(patternax,steerangles,diffampdb-max(sumampdb),'DisplayName','Collected Diff Channel');
plot(patternax,steerangles,simsumdb-max(simsumdb),'DisplayName','Simulated Sum Channel');
plot(patternax,steerangles,simdiffdb-max(simsumdb),'DisplayName','Simulated Diff Channel');

% Create a tile for the phase diff pattern
phaseax = nexttile();
hold(phaseax,"on");
legend(phaseax,"Location","southeast");
title(phaseax,"Sum-Diff Phase Delta")
xlabel(patternax,"Azimuth Angle (Degrees)");
ylabel(patternax,"Phase Difference");
plot(phaseax,steerangles,sumdiffphasedelta,"DisplayName","Collected Phase Diff");
plot(phaseax,steerangles,simphasedelta,"DisplayName","Simulated Phase Diff");

% Save data for later analysis
MonopulseData.SumData = patternsumdata;
MonopulseData.DiffData = patterndiffdata;

end