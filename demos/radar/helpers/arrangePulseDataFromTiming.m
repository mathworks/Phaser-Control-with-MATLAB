function outdata = arrangePulseDataFromTiming(indata,fs,tsweep,tstartsweep,tpulse,nPulses)
% Rearrange a full stream of data into an nSample x nPulse data matrix.
%
% Copyright 2026 The MathWorks, Inc.

% Extract timing from pluto and phaser setup

% Combine data from channels with calibration weights
indata = applyDigitalCalWeights(indata);

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