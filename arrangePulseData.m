function outdata = arrangePulseData(indata,rx,bf,bf_TDD)
% Rearrange a full stream of data into an nSample x nPulse data matrix for
% easier processing.

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
pulseendsample = ceil(tpulse * fs);

% Get all of the pulse start indices
pulsestartsamples = (0:nPulses-1)*pulseendsample;
allsweepsamples = repmat(sweepsamples',1,nPulses);
sampleidxs = allsweepsamples + pulsestartsamples;

% Get output data rearranged
outdata = indata(sampleidxs);

end