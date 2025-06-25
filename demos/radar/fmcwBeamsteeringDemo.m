% This script demonstrates how to control the Phaser for beamforming
% purposes when the system is configured as a radar.
% 
% % Setup:
%
% Connect the Vivaldi antenna to Phaser SMA Out2. Place the Vivaldi antenna
% in the field of view of the Phaser and point it at the Phaser.
%
% Notes:
%
% Run this script to generate a plot of the array factor when the transmit
% antenna is pointed towards the array. The received signal amplitude is
% highest when the receive beam is steered towards the transmit antenna. 
% The first time this script is run, the data collection may not occur
% properly.
%
% Before performing beamforming, the Phaser analog and digital channels
% must be calibrated for phase and amplitude errors. 
%
% Copyright 2023 The MathWorks, Inc.

%% Before doing any beamsteering, we need to calculate calibration weights for the antenna.

% Change this value to true if we need to calculate calibration
% weights. This only needs to be run once. The setup for calibration is
% different than the rest of the script. The HB100 needs to be placed at
% boresight for this function to work properly.
clear;
needsCalibration = false;
if needsCalibration
    generateCalibrationWeights();
end

%% Clear workspace and load calibration weights

clear; close all;

% This will only work if the generateCalibrationWeights() function has been
% run in the prior section. If you get an error, run the
% generateCalibrationWeights function.
calibrationweights = loadCalibrationWeights();

%% First, setup the system similarly to fmcwDemo.m

% Carrier frequency
fc = 10e9;
lambda = physconst("LightSpeed")/fc;

% Put some requirements on the system
maxRange = 10;
rangeResolution = 1/3;
maxSpeed = 5;
speedResolution = 1/2;

% Determine some parameter values
rampbandwidth = ceil(rangeres2bw(rangeResolution)/1e6)*1e6;
fmaxdop = speed2dop(2*maxSpeed,lambda);
prf = 2*fmaxdop;
nPulses = ceil(2*maxSpeed/speedResolution);
tpulse = ceil((1/prf)*1e3)*1e-3;
tsweep = getFMCWSweepTime(tpulse,tpulse);
sweepslope = rampbandwidth / tsweep;
fmaxbeat = sweepslope * range2time(maxRange);
fs = max(ceil(2*fmaxbeat),520834);

% See fmcw demo for these setup steps
[rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc,fs,tpulse,tsweep,nPulses,rampbandwidth);

% Clear cache
rx();

% Use constant amplitude baseband transmit data
amp = 0.9 * 2^15;
txWaveform = amp*ones(rx.SamplesPerFrame,2);

%% Next, steer from -90:90 while transmitting, plot the amplitude at each angle

analogPosition = model.Subarray.getElementPosition() / lambda;
digitalPosition = model.getSubarrayPosition() / lambda;

steerangles = -90:5:90;
amplitudes = zeros(numel(steerangles),1);
for azangle = steerangles
    
    % Get the beamforming weights for the current azimuth angle
    angle = [azangle;0];
    analogWeights = cbfweights(analogPosition,angle);
    digitalWeights = cbfweights(digitalPosition,angle);

    % Normalize the beamforming weights
    analogWeights = analogWeights / max(abs(analogWeights));
    digitalWeights = digitalWeights / max(abs(digitalWeights));

    % Adjust the beamforming weights with the calibration weights
    analogWeights = analogWeightsCalAdjustment(analogWeights,calibrationweights.AnalogWeights);

    % Setup the analog beamformers
    setAnalogBfWeights(bf,analogWeights);

    % capture data
    data = captureTransmitWaveform(rx,tx,bf,txWaveform);

    % Apply digital weights
    data = data .* digitalWeights.';

    % Arrange data into pulses
    data = arrangePulseData(data,rx,bf,bf_TDD);

    % Save the average amplitude of all of the pulses for the current angle
    amplitudes(azangle==steerangles) = calculateAmplitude(data);
end

% Plot the captures amplitude data
ax = axes(figure);
plot(steerangles,amplitudes);
xlabel("Steer Angle"); ylabel("Signal Amplitude");

% Disable TDD Trigger so we can operate in Receive only mode
disableTddTrigger(bf_TDD)


%% Helpers

function amp = calculateAmplitude(data)
    % Calculate the average amplitude for a dataset by just taking the mean
    % of the magnitude
    amp = mean(mean(abs(data)));
end


