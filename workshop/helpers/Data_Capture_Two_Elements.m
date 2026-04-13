% FMCW Data Collect

clear;
close all;
warning('off','MATLAB:system:ObsoleteSystemObjectMixin');
load('CalibrationWeights.mat','calibrationweights');

% For this lab, we use many of the same parameters that were used in previous labs.

% Setup Phaser
fc = 10e9;
prf = 500;
nPulses = 48;
fs = 1e6;
rampbandwidth = 500e6;
[rx,tx,bf,bf_TDD] = setupLabRadar(fc,prf,nPulses,fs,rampbandwidth);

% Setup the capture
nCapture = 20;
data = cell(1,nCapture);

% Setup truth info
truthRange = 3;
truthAngle = -15;

% Capture data
captureTransmitWaveform(rx,tx,bf);

tseed = tic;
t = zeros(1,nCapture);
for iCapture = 1:nCapture
    % Set beamformers to only have a single element on.
    analogsteer = analogWeightsCalAdjustment([1 0;0 0;0 0;0 1],calibrationweights.AnalogWeights);
    setAnalogBfWeights(bf,analogsteer);

    % Trigger burst pulse
    bf.Burst=false;bf.Burst=true;bf.Burst=false;

    % Capture pulse period
    data{iCapture} = rx();

    t(iCapture) = toc(tseed);
end

% Create configuration
tSweep = double(bf.FrequencyDeviationTime)/1e6;
tstartsweep = bf_TDD.Ch0On;
tframe = bf_TDD.FrameLength / 1e3;
config = FmcwTrackingConfig(prf,nPulses,fc,fs,tSweep,rampbandwidth,0,tstartsweep,tframe);

% Save data, configuration, and truth values for future analysis
save('datacapture_2_element_-15_deg_m.mat','data','config','truthRange','truthAngle','t');
