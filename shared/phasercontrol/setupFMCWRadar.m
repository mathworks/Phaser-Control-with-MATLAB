function [rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc,fs,tpulse,tsweep,nPulses,rampbandwidth)
% Setup the phaser for FMCW Radar Operation. These steps are derived in
% fmcwDemo.m.
% 
% Copyright 2023 The MathWorks, Inc.

nSamples = ceil(tpulse * nPulses * fs);

% Setup the entire system
[rx,bf,model,tx,bf_TDD] = setupAntenna(fc);

% Setup pluto for radar
radarPlutoSetup(tx,rx,fs,nSamples);

% Setup the phaser for FMCW radar
radarPhaserSetup(bf,rx,rampbandwidth,fc,tsweep);

% Setup the TDD engine
radarTddSetup(bf_TDD,tpulse,nPulses,tsweep)

end

