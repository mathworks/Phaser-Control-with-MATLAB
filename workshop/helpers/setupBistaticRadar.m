function [rx,tx,bf,bf_TDD] = setupBistaticRadar(fc,fs,nSamples)
% This function sets up the Phaser as a radar with a fixed LO frequency 

% Pulse time has to be rounded to the nearest ms
tpulse = nSamples/fs;%ceil((1/prf)*1e3)*1e-3;

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
bf.RampMode = "disabled";
bf.TriggerEnable = false;
% bf.EnablePLL = true;
% bf.EnableTxPLL = true;
% bf.EnableOut1 = false;
% From Jon:
BW = 500e6 / 4; num_steps = 1000;
bf.FrequencyDeviationRange = BW; % frequency deviation range in H1.  This is the total freq deviation of the complete freq ramp
bf.FrequencyDeviationStep = int16(BW / num_steps);  % frequency deviation step in Hz.  This is fDEV, in Hz.  Can be positive or negative
bf.DelayStartWord = 4095;
bf.DelayClockSource = "PFD";
bf.DelayStartEnable = false;  % delay start
bf.RampDelayEnable = false;  % delay between ramps.
bf.TriggerDelayEnable = false;  % triangle delay
bf.SingleFullTriangleEnable = false;  % full triangle enable/disable -- this is used with the single_ramp_burst mode


% % Setup the TDD engine
% bf_TDD = setupTddEngine();
% tStartRamp = 0;
% tStartCollection = 0;
% bf_TDD.PhaserEnable = 1;
% bf_TDD.Enable = 0;
% bf_TDD.EnSyncExternal = 1;
% bf_TDD.StartupDelay = 0;
% bf_TDD.SyncReset = 0;
% bf_TDD.FrameLength = tpulse*1e3;
% bf_TDD.BurstCount = 1;
% bf_TDD.Ch0Enable = 1;
% bf_TDD.Ch0Polarity = 0;
% bf_TDD.Ch0On = tStartRamp;
% bf_TDD.Ch0Off = tStartRamp+0.1;
% bf_TDD.Ch1Enable = 1;
% bf_TDD.Ch1Polarity = 0;
% bf_TDD.Ch1On = tStartCollection;
% bf_TDD.Ch1Off = tStartCollection+0.1;
% bf_TDD.Ch2Enable = 1;
% bf_TDD.Ch2Polarity = 0;
% bf_TDD.Ch2On = 0;
% bf_TDD.Ch2Off = 0.1;
% bf_TDD.Enable = 1;

