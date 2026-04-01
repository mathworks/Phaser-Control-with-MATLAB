function outdata = arrangePulseData(indata,rx,bf,bf_TDD)
% Rearrange a full stream of data into an nSample x nPulse data matrix.
%
% Copyright 2023 The MathWorks, Inc.

% Extract timing from pluto and phaser setup
fs = rx.SamplingRate;
tsweep = double(bf.FrequencyDeviationTime) / 1e6;
tstartsweep = bf_TDD.Ch0On;
tpulse = bf_TDD.FrameLength / 1e3;
nPulses = bf_TDD.BurstCount;

outdata = arrangePulseDataFromTiming(indata,fs,tsweep,tstartsweep,tpulse,nPulses);

end