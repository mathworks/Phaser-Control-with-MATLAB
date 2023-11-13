%% Phaser as a receiver

% This script demonstrates how to control the Phaser when the system is
% configured only as a receiver.
% 
% % Setup:
%
% Most of these demonstrations require the HB100 to be placed at 0 degrees
% boresight. However, each of the functions in this data collection script
% have detailed decriptions and information about setup within the files.
%
% Copyright 2023 The MathWorks, Inc.

%% Add entire repository to the path

filepath = fileparts(which('workshopDataCollection'));
directoryIdxs = find(filepath == '\' | filepath == '/');
directoryIdx2Add = directoryIdxs(end-1);
addpath(genpath(filepath(1:directoryIdx2Add)));

%% Disable warnings

% Turn off obsolete system object warning
warning('off','MATLAB:system:ObsoleteSystemObjectMixin')

%% Calculate the HB100 transmitter frequency

% Run this function to measure the frequency of the HB100 transmitter. If
% you already know the frequency, just set the fc_hb100 variable to the
% correct value before running following scripts.
fc_hb100 = findTxFrequency();

%% Measure and save antenna gain profile

% Run this function to measure the gain profile for each element in the
% array. This creates a map from element gain setting to actual measured
% power. This function only needs to be run a single time for one Phaser
% board. If GainProfile.mat already exists, no need to run this.
saveGainProfile(fc_hb100);

%% Calibrate Antenna

% Run the calibration routine to get the desired analog and digital
% calibration weights.
CalibrationData = calibrationRoutine(fc_hb100);

% The calibration weights to be used for the remainder of the data
% collection exercises are extracted from CalibrationData. The calibration
% weights measured for a single Phaser Board can be saved and retrieved
% during a later session.
finalcalweights = CalibrationData.CalibrationWeights.FinalCalibrationWeights;

%% Tapering

% Taper the antenna pattern to reduce the sidelobe levels.
nbar = 2; % Number of constant level sidelobes
sll = -20; % Desired sidelobe level
antennaTapering(fc_hb100,finalcalweights,nbar,sll);

%% Grating lobes

% Illustrate the impact of antenna element spacing greater than 1/2
% wavelength
gratingLobes(fc_hb100,finalcalweights);

%% Null steering

% Insert a null into the steering pattern. This type of approach can be
% used for interference cancellation
nullangle = 20; % Null steering angle
NullSteeringData = nullCancellation(fc_hb100,finalcalweights,nullangle);

%% Create Monopulse Pattern

% Generate monopulse pattern.
targetangle = 0; % Transmitter angle
targetoffset = 10; % Pattern width to show
[monopulsePattern,~] = createMonopulsePattern(fc_hb100,finalcalweights,targetangle,targetoffset);

%% Monopulse follower

% Use the monopulse phase information to create a simple feedback mechanism
% to track the transmitter angle. Move the HB100 or rotate the antenna and
% watch the transmitter location be tracked.
runtime = 60; % runtime in seconds, adjust as necessary
monopulseFollower(fc_hb100,finalcalweights,runtime);

%% Scan antenna

% This will scan to the specified angles for the specified number of scans.
% Change showsubarrays to show or hide subarray patterns.
scanangles = -90:0.5:90; % Scan angles
nscans = 1; % Number of scans
showsubarrays = true; % Toggle whether to show subarray patterns
scanAntenna(fc_hb100,finalcalweights,scanangles,nscans,showsubarrays);

%% Point antenna in one direction, move transmitter

% This function will steer the array to a single direction, the user can
% move the transmitter around to get a sense for the antenna pattern.
scanangle = 0; % Scan angle
tscan = 20; % Scan time (seconds)
scanTransmitter(fc_hb100,finalcalweights,scanangle,tscan)