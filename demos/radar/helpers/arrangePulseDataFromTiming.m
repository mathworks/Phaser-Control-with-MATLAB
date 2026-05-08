function outdata = arrangePulseDataFromTiming(indata,fs,tsweep,tstartsweep,tpulse,nPulses)
% Rearrange a full stream of data into an nSample x nPulse data matrix.
%
% Copyright 2026 The MathWorks, Inc.

% Extract timing from pluto and phaser setup

% Combine data from channels with calibration weights
indata = applyDigitalCalWeights(indata);

% Arrange the combined data
outdata = arrangeSinglePulseDataFromTiming(indata,fs,tsweep,tstartsweep,tpulse,nPulses);

end