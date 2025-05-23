function outdata = arrangePulseData(indata,rx,bf,bf_TDD)
% Rearrange a full stream of data into an nSample x nPulse data matrix.
%
% Copyright 2023 The MathWorks, Inc.

% Combine data from channels with calibration weights
indata = applyDigitalCalWeights(indata);

% Extract timing from pluto and phaser setup
fs = rx.SamplingRate;
tsweep = double(bf.FrequencyDeviationTime) / 1e6;
tstartsweep = bf_TDD.Ch0On;
tpulse = bf_TDD.FrameLength / 1e3;
nPulses = bf_TDD.BurstCount;

% Get the number of samples into the pulse that the sweep starts
sweepoffsetsamples = ceil(tstartsweep * fs);

% Get indices within a pulse that contain the sweep data
sweepsamples = 1:ceil(tsweep * fs) + sweepoffsetsamples;

% Get end index of pulse
pulseendsample = round(tpulse * fs);

% Get all of the pulse start indices
pulsestartsamples = (0:nPulses-1)*pulseendsample;
allsweepsamples = repmat(sweepsamples',1,nPulses);
sampleidxs = allsweepsamples + pulsestartsamples;

% Get output data rearranged. If we are trying to index a value that is too
% high, return all zeros. Sometimes pluto can return incorrect number of
% samples.
nCollectedSamples = size(indata,1);
nRequiredSamples = max(sampleidxs,[],"all");
if nRequiredSamples > nCollectedSamples
    outdata = zeros(size(sampleidxs));
else
    outdata = indata(sampleidxs);
end

end