% Copyright 2023 The MathWorks, Inc.

%% Before doing any beamsteering, we need to calculate calibration weights for the antenna.
% Change this value to true if we need to calculate calibration
% weights.
needsCalibration = false;
if needsCalibration
    generateCalibrationWeights();
end

%% Clear and load calibration weights

clear; close all;
load('CalibrationWeights.mat','calibrationweights');

%% First, setup the system similarly to fmcwDemo.m

% Carrier frequency
fc = 10e9;
lambda = physconst("LightSpeed")/fc;

% See fmcw demo for these setup steps
[rx,tx,bf,bf_TDD,model] = setupFMCWRadar(fc);

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
    digitalWeights = digitalWeightsCalAdjustment(digitalWeights,calibrationweights.DigitalWeights);

    % Setup the analog beamformers
    setAnalogBfWeights(bf,analogWeights);

    % capture data
    data = captureTransmitWaveform(txWaveform,rx,tx,bf);

    % Apply digital weights
    data = data * conj(digitalWeights);

    % Arrange data into pulses
    data = arrangePulseData(data,rx,bf,bf_TDD);

    % Save the average amplitude of all of the pulses for the current angle
    amplitudes(azangle==steerangles) = calculateAmplitude(data);
end

% Plot the captures amplitude data
ax = axes(figure);
plot(steerangles,amplitudes);
xlabel("Steer Angle"); ylabel("Signal Amplitude");


%% Helpers

function amp = calculateAmplitude(data)
    % Calculate the average amplitude for a dataset by just taking the mean
    % of the magnitude
    amp = mean(mean(abs(data)));
end


