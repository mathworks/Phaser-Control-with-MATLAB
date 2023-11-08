function [rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc)
% The following setup steps are derived in fmcwDemo.m

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

% Setup the phaser
[rx,bf,model,tx,plutoURI] = setupAntenna(fc);

% Setup receiver sampling
rx.SamplesPerFrame = nSamples;
rx.SamplingRate = fs;

% Setup transmitter
tx.SamplingRate = fs;
tx.EnabledChannels = [1,2];
tx.CenterFrequency = rx.CenterFrequency;
tx.AttenuationChannel0 = -3;
tx.AttenuationChannel1 = -3;
tx.EnableCyclicBuffers = true;
tx.DataSource = "DMA";

% Setup the beamformer and ADF4159
BW = rampbandwidth / 4; 
num_steps = 2^9;
bf.Frequency = (fc+rx.CenterFrequency)/4;
bf.RxPowerDown(:) = 0;
bf.RxGain(:) = 127;
bf.FrequencyDeviationRange = BW;
bf.FrequencyDeviationStep = ((BW) / num_steps);
bf.FrequencyDeviationTime = tsweep*1e6; % convert to us
bf.RampMode = "single_sawtooth_burst";
bf.TriggerEnable = true;  % start a ramp with TXdata
bf.EnablePLL = true;
bf.EnableTxPLL = true;
bf.EnableOut1 = false; % send transmit out of SMA2

% Setup the TDD engine

tStartRamp = 0;
tStartCollection = 0;
bf_TDD = adi.PhaserTDD('uri', plutoURI);
bf_TDD();
bf_TDD.Enable = 0;   % TDD must be disabled before changing properties
bf_TDD.EnSyncExternal = 1;
bf_TDD.StartupDelay = 0;
bf_TDD.SyncReset = 0;
bf_TDD.FrameLength = tpulse*1e3;  %frame length in ms
bf_TDD.BurstCount = nPulses;
bf_TDD.Ch0Enable = 1;
bf_TDD.Ch0Polarity = 0;
bf_TDD.Ch0On = tStartRamp;
bf_TDD.Ch0Off = tsweep; % this doesn't need to be tsweep, this just ensures control pulse ends before next PLL pulse starts
bf_TDD.Ch1Enable = 1;
bf_TDD.Ch1Polarity = 0;
bf_TDD.Ch1On = tStartCollection;
bf_TDD.Ch1Off = tStartCollection+0.1;
bf_TDD.Enable = 1;

end

