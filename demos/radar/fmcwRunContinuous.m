% This script lets you run an FMCW Radar continuously for a certain number
% of steps.
% 
% % Setup:
%
% Connect the Vivaldi antenna to Phaser SMA Out2. Place the Vivaldi antenna
% in the field of view of the Phaser and point it at the Phaser.
%
% Notes:
%
% Run this script to continuously run the FMCW radar for demonstration.
%
% Copyright 2023 The MathWorks, Inc.

%% Clear workspace and load calibration weights

clear; close all;

%% First, setup the system similarly to fmcwDemo.m

% Carrier frequency
fc = 10e9;
lambda = physconst("LightSpeed")/fc;

% See fmcw demo for these setup steps
[rx,tx,bf,bf_TDD,model,fc,fs,sweepslope,prf,maxSpeed,maxRange] = setupFMCWRadar(fc);

% Clear cache
rx();

% Use constant amplitude baseband transmit data
amp = 0.9 * 2^15;
txWaveform = amp*ones(rx.SamplesPerFrame,2);

%% Next, run continuously for nCaptures

nCaptures = 100;

% Create a range doppler plot
rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
    SweepSlope=sweepslope,PRFSource="Property",PRF=prf);
ax = axes(figure);
for i = 1:nCaptures
    % capture data
    data = captureTransmitWaveform(txWaveform,rx,tx,bf);

    % Arrange data into pulses
    data = arrangePulseData(data,rx,bf,bf_TDD);

    % Plot the data
    rd.plotResponse(data);
    xlim(ax,[-maxSpeed,maxSpeed]); ylim(ax,[0,maxRange]);
    drawnow;
end

% Disable TDD Trigger so we can operate in Receive only mode
disableTddTrigger(bf_TDD)

