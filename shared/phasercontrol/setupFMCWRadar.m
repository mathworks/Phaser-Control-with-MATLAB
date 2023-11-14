function [rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc)
% Setup the phaser for FMCW Radar Operation. These steps are derived in
% fmcwDemo.m.
% 
% Copyright 2023 The MathWorks, Inc.

% Put some requirements on the system
maxRange = 10;
rangeResolution = 1/3;
maxSpeed = 5;
speedResolution = 1/2;

% Determine some parameter values
lambda = physconst("LightSpeed") / fc;
rampbandwidth = ceil(rangeres2bw(rangeResolution)/1e6)*1e6;
fmaxdop = speed2dop(2*maxSpeed,lambda);
prf = 2*fmaxdop;
nPulses = ceil(2*maxSpeed/speedResolution);
tpulse = ceil((1/prf)*1e3)*1e-3;
tsweep = getFMCWSweepTime(tpulse,tpulse);
sweepslope = rampbandwidth / tsweep;
fmaxbeat = sweepslope * range2time(maxRange);
fs = max(ceil(2*fmaxbeat),520834);
nSamples = ceil(tpulse * nPulses * fs);

% Setup the entire system
[rx,bf,model,tx,plutoURI] = setupAntenna(fc);

% Setup pluto for radar
radarPlutoSetup(tx,rx,fs,nSamples);

% Setup the phaser for FMCW radar
radarPhaserSetup(bf,rampbandwidth,fc,tsweep);

% Setup the TDD engine
radarTddSetup()

end

