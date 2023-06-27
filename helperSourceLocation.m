function sourceaz = helperSourceLocation(CalibrationData)

% Copyright 2023 The MathWorks, Inc.

[rx,bf,fc_hb100,phaseCal,channelWeights,steeringVec,~] = setupAntenna(CalibrationData);

% Capture the initial pattern data, find the location of the interferer -
% assumed to be higher power
steerangles = -90:0.5:90;
patternData = helperCapturePattern(steerangles,steeringVec,fc_hb100,bf,rx,phaseCal,channelWeights);
amp = helperGetAmplitude(patternData);
smoothamp = smooth(amp,20);
[~,azidx] = max(smoothamp);
sourceaz = steerangles(azidx);

ax = axes(figure); hold(ax,"on");
plot(ax,steerangles,amp,"DisplayName","Scan Pattern")
scatter(ax,sourceaz,amp(azidx),"DisplayName","Source Location");
legend();

cleanupAntenna(rx,bf);

end