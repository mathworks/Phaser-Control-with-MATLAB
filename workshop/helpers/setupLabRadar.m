function [rx,tx,bf,bf_TDD] = setupLabRadar(fc,prf,nPulses,fs,rampbandwidth)
% This function sets up the Phaser as an FMCW radar for the workshop radar
% labs.

% Pulse time has to be rounded to the nearest ms
%tpulse = ceil((1/prf)*1e3)*1e-3;
tpulse = 1/prf;

% We set up the sweep to occupy as much of the pulse as possible
tsweep = getFMCWSweepTime(tpulse,tpulse);

% Get the total number of samples in a pulse repetition period
nSamples = ceil(tpulse * nPulses * fs);

% Setup the pluto
[rx,tx] = setupPluto();

% Setup pluto receiver
rx.SamplesPerFrame = nSamples;
rx.SamplingRate = fs;

% Setup pluto transmitter
tx.SamplingRate = fs;
tx.EnabledChannels = [1,2];
tx.CenterFrequency = rx.CenterFrequency;
tx.AttenuationChannel0 = -80;
tx.AttenuationChannel1 = -3;
tx.EnableCyclicBuffers = true;
tx.DataSource = "DMA";

% Setup beamformers all to max gain with no phase shifts
calibrationweights = loadCalibrationWeights();
bf = setupPhaser(rx,fc);
bf.RxPowerDown(:) = 0;

% Load calibration data into beamformer
setAnalogBfWeights(bf,calibrationweights.AnalogWeights);

% Setup Phase Locked Loop (PLL)
bf.Frequency = (fc+rx.CenterFrequency)/4;
BW = rampbandwidth / 4;
num_steps = 2^9;
bf.FrequencyDeviationRange = BW;
bf.FrequencyDeviationStep = ((BW) / num_steps);
bf.FrequencyDeviationTime = tsweep*1e6;
bf.RampMode = "single_sawtooth_burst";
bf.TriggerEnable = true;
bf.EnablePLL = true;
bf.EnableTxPLL = true;
bf.EnableOut1 = false;

% Setup the TDD engine
bf_TDD = setupTddEngine();
tStartRamp = 0;
tStartCollection = 0;
bf_TDD.PhaserEnable = 1;
bf_TDD.Enable = 0;
bf_TDD.EnSyncExternal = 1;
bf_TDD.StartupDelay = 0;
bf_TDD.SyncReset = 0;
bf_TDD.FrameLength = tpulse*1e3;
bf_TDD.BurstCount = nPulses;
bf_TDD.Ch0Enable = 1;
bf_TDD.Ch0Polarity = 0;
bf_TDD.Ch0On = tStartRamp;
bf_TDD.Ch0Off = tStartRamp+0.1;
bf_TDD.Ch1Enable = 1;
bf_TDD.Ch1Polarity = 0;
bf_TDD.Ch1On = tStartCollection;
bf_TDD.Ch1Off = tStartCollection+0.1;
bf_TDD.Ch2Enable = 1;
bf_TDD.Ch2Polarity = 0;
bf_TDD.Ch2On = 0;
bf_TDD.Ch2Off = 0.1;
bf_TDD.Enable = 1;

