function CalibrationData = calibrationRoutine(fc_hb100)

% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth. It should be
% sufficiently far from the antenna so that the wavefront is approximately
% planar.
%
% Notes:
% 
% The amplitude and phase of all 8 analog channels as well as the two
% digital channels must be calibrated so that the amplitudes in each
% channel are the same and the phase shifts align as expected during
% steering.
%
% The order of the calibration steps is described below.
%
% 1. Course Analog Amplitude Calibration: The first calibration step is an
% initial amplitude calibration so that the amplitude in each of the 4
% elements in each of the 2 subarrays are the same. This is done by
% independently measuring the signal amplitude in each channel when the gain
% is set to maximum.The gain is set so that all of the channel signal
% amplitudes match the lowest signal amplitude channel.
%
% 2. Analog Phase Calibration: The second calibration step is to account for
% the different phase shift in each analog channel. For each subarray, 
% select a reference channel. Then measure the phase of other channels
% within the subarray with respect to the reference channel. The search is
% brute force, by sweeping all the possible phases on the chip.
%
% 3. Fine Analog Amplitude Calibration: Changing the default phase shift in
% each analog channel in step (2) causes the amplitude of the signal in
% each channel to change. Therefore, the amplitude calibration is performed
% again.
%
% 4. Digital Amplitude Calibration: Once the analog channels have been
% calibrated, the difference in amplitude between the two digital channels
% is measured. Whenever the digital channel signals are combined, an
% amplitude adjustment is applied based on this different in amplitude.
%
% 5. Digital Phase Calibration: The signal phase into each of the two
% digital channels will not necessarily align. The phase difference is
% measured by shifting the phase of channel 2 until the amplitude of the
% combined signal is maximized. This phase shift is applied when the two
% digital signals are combined.

% Copyright 2023 The MathWorks, Inc.

%% Setup

% Setup antenna and model
[rx,bf,~,tx,bf_TDD] = setupAntenna(fc_hb100);

% Setup sampling properties
fs = 3e6;
nSamples = 1024;
rx.SamplingRate = fs;
rx.SamplesPerFrame = nSamples;

% Setup calibration data storage object
CalibrationData = CalibrationDataFormat();

% Setup the inital analog and digital antenna weights. These are the values
% that get adjusted during calibration. The amplitude and phase of the weights
% represent the gain and phase adjustments that will be made on each channel.
% Initially there is no phase shift or amplitude adjustment.
analogWeights = ones(4,2);
digitalWeights = ones(2,1);

% Store uncalibrated weights for later analysis
CalibrationData.CalibrationWeights.UncalibratedWeights.AnalogWeights = analogWeights;
CalibrationData.CalibrationWeights.UncalibratedWeights.DigitalWeights = digitalWeights;

%% Course Amplitude Calibration
% The amplitude in each analog channel is measured when the gain is
% set to the maximum level. Gain in each channel is adjusted to account
% for differences.

% Set the gain of all 8 channels to maximum.
bf.RxGain(:) = 127;

% Setup data variables
nCapture = 20;
rx1data = zeros(nSamples,nCapture,4);
rx2data = zeros(nSamples,nCapture,4);

for nCh = 1:4
    % Turn off all the channels.
    bf.RxPowerDown(:) = 1;
    
    % Turn on channels under test (subarray 1 and subarray 2)
    bf.RxPowerDown(nCh) = 0; 
    bf.RxPowerDown(nCh+4) = 0;
    bf.LatchRxSettings();

    % Capture multiple snapshots
    for ncapture = 1 : nCapture        
        rx();
        receivedSig = rx();
        rx1data(:,ncapture,nCh) = receivedSig(:,2);
        rx2data(:,ncapture,nCh) = receivedSig(:,1);
    end
end

% Turn all channels back on
bf.RxPowerDown(:) = 0;

% Calculate the average amplitude for each element in each subarray
avgamp1 = mean(max(abs(fft(rx1data))));
avgamp2 = mean(max(abs(fft(rx2data))));

% Reshape into a vector
avgamp1 = reshape(avgamp1,[1 4]);
avgamp2 = reshape(avgamp2,[1 4]);

% Scale each amplitude value to the minimum measured amplitude value
sub1gain = min(avgamp1) ./ avgamp1;
sub2gain = min(avgamp2) ./ avgamp2;

% Plot the analog amplitude calibration values
helperPlotElementGainCalibration(avgamp1,sub1gain,avgamp2,sub2gain);

% Update analog weights with array gain calibration values
analogWeights = analogWeights .* [sub1gain',sub2gain'];

% Store the calibration data for later analysis
CalibrationData.AnalogAmplitudeCalibration.CourseSubarray1Data = rx1data;
CalibrationData.AnalogAmplitudeCalibration.CourseSubarray2Data = rx2data;
CalibrationData.CalibrationWeights.AnalogCourseAmplitudeWeights.AnalogWeights = analogWeights;
CalibrationData.CalibrationWeights.AnalogCourseAmplitudeWeights.DigitalWeights = digitalWeights;

%% Calibrate phase
% Place the emitter in front of the phased array.
% Turn on two adjacent channel. On the first channel put 0 phase, and on
% the adjacent channel sweep the phase shift setting from 0 to 360. Minimum
% signal strength occurs when the phase offset between channels is 180
% degrees. The calibration value is set such that the phase shift is
% actually 180 degrees when shifter is set to 180 degrees.

% Setup phase steps to test and variables to hold data
PhaseResolutionBits = 7;
phase_step_size = 360 / (2 ^ PhaseResolutionBits);
channel2phase = double(0:phase_step_size:360);
rawdata1 = zeros(rx.SamplesPerFrame,numel(channel2phase),3);
rawdata2 = zeros(rx.SamplesPerFrame,numel(channel2phase),3);

% Set the reference channel and channels under test
referencechannel = 1;
testchannels = 2:4;

% set the receiver gain based on the amplitude calibration. The gain codes
% are set based on data that was previously captured to determine gain code
% correspondance to actual gain.
bf.RxGain = helperGainCodes(analogWeights);

% Loop through each channel under test
for nChannel = testchannels
    % Set all phase shifts to 0
    bf.RxPhase(:) = 0;

    % Power down all elements
    bf.RxPowerDown(:) = 1;

    % Turn on element 1 and element under test subarray 1
    bf.RxPowerDown(referencechannel) = 0;
    bf.RxPowerDown(nChannel) = 0;

    % Turn on element 1 and element under test subarray 2
    bf.RxPowerDown(referencechannel+4) = 0;
    bf.RxPowerDown(nChannel+4) = 0;
    bf.LatchRxSettings();

    % Loop through each phase offset, set element under test phase shifter,
    % capture data.
    for ii = 1 : numel(channel2phase)
        % Set phase for subarray 1 and 2 element
        bf.RxPhase(nChannel) = channel2phase(ii);
        bf.RxPhase(nChannel+4) = channel2phase(ii);
        bf.LatchRxSettings();

        % Capture and store data
        rx();
        receivedSig_HW = rx();
        rawdata1(:,ii,nChannel-1) = receivedSig_HW(:,2);
        rawdata2(:,ii,nChannel-1) = receivedSig_HW(:,1);
    end
end

% Get signal amplitude for both subarrays
amp1 = max(abs(fft(rawdata1)),[],1);
amp2 = max(abs(fft(rawdata2)),[],1);

% Reshape into a 2d array which is Number Phases x Number Elements
sub1amplitudes = reshape(amp1,[numel(channel2phase) 3]);
sub2amplitudes = reshape(amp2,[numel(channel2phase) 3]);

% Get location of min amplitude
[~,phase1Idx] = min(sub1amplitudes,[],1);
[~,phase2Idx] = min(sub2amplitudes,[],1);

% Get calibration phase by substracting 180 from the minimum phase location
cal1phase = [0;wrapTo360(channel2phase(phase1Idx)-180)'];
cal2phase = [0;wrapTo360(channel2phase(phase2Idx)-180)'];

% Plot the analog phase shift information
helperPlotAnalogPhaseCalibration(channel2phase,sub1amplitudes,sub2amplitudes);

% Convert calibration phase to a phase shift for the element weights, and
% update analog weights
phaseSteer = exp(deg2rad([cal1phase,cal2phase])*1i);
analogWeights = analogWeights .* phaseSteer;

% Store recorded data for later analysis
CalibrationData.AnalogPhaseCalibration.PhaseSetting = channel2phase;
CalibrationData.AnalogPhaseCalibration.Subarray1Measurements = rawdata1;
CalibrationData.AnalogPhaseCalibration.Subarray2Measurements = rawdata2;
CalibrationData.CalibrationWeights.AnalogPhaseWeights.AnalogWeights = analogWeights;
CalibrationData.CalibrationWeights.AnalogPhaseWeights.DigitalWeights = digitalWeights;

%% Fine Grain Calibration Data

% The amplitude in each analog channel is measured when the gain is
% set to the maximum level with the new default phase shifts applied.
% Gain in each channel is adjusted to account for differences. This is the
% exact same process that was used for the analog course amplitude
% calibration, although now the phase shifter values are set to the default
% determined in the previous section.

% Set the gain of all 8 channels to maximum.
bf.RxGain(:) = 127;

% Set the phase shifts based on the new analog weights
phaseshifts = wrapTo360(rad2deg(angle(analogWeights)));
bf.RxPhase(:) = [phaseshifts(:,1)',phaseshifts(:,2)'];

% Setup data variables
nCapture = 20;
rx1data = zeros(nSamples,nCapture,4);
rx2data = zeros(nSamples,nCapture,4);

for nCh = 1:4
    % Turn off all the channels.
    bf.RxPowerDown(:) = 1;
    
    % Turn on channels under test (subarray 1 and subarray 2)
    bf.RxPowerDown(nCh) = 0; 
    bf.RxPowerDown(nCh+4) = 0;
    bf.LatchRxSettings();

    % Capture multiple snapshots
    for ncapture = 1 : nCapture
        rx();
        receivedSig = rx();
        rx1data(:,ncapture,nCh) = receivedSig(:,2);
        rx2data(:,ncapture,nCh) = receivedSig(:,1);
    end
end

% Turn all channels back on
bf.RxPowerDown(:) = 0;

% Calculate the average amplitude for each element in each subarray
avgamp1 = mean(max(abs(fft(rx1data))));
avgamp2 = mean(max(abs(fft(rx2data))));

% Reshape into a vector
avgamp1 = reshape(avgamp1,[1 4]);
avgamp2 = reshape(avgamp2,[1 4]);

% Scale each amplitude value to the minimum measured amplitude value
sub1gain = min(avgamp1) ./ avgamp1;
sub2gain = min(avgamp2) ./ avgamp2;

% Normalize the weights back to amplitude 1
analogWeights = analogWeights ./ abs(analogWeights);

% Update analog weights with array gain calibration values
analogWeights = analogWeights .* [sub1gain',sub2gain'];

% Store the calibration data for later analysis
CalibrationData.AnalogAmplitudeCalibration.FineSubarray1Data = rx1data;
CalibrationData.AnalogAmplitudeCalibration.FineSubarray2Data = rx2data;
CalibrationData.CalibrationWeights.AnalogFineAmplitudeWeights.AnalogWeights = analogWeights;
CalibrationData.CalibrationWeights.AnalogFineAmplitudeWeights.DigitalWeights = digitalWeights;

%% Calibrate the two digital channels on Pluto
% After the analog channels have been calibrated, collect data with
% analog calibration value settings and calibrate the digital channels for
% amplitude and phase.

% Collect data with analog weight settings
analogcaldata = helperSteerAnalog(bf,rx,analogWeights);

% Store calibration data for later analysis
CalibrationData.DigitalCalibration.MeasuredData = analogcaldata;

% Calculate the channel calibration gain by normalizing the channel
% amplitudes to the max channel amplitude
channelamplitude = max(abs(fft(analogcaldata)));
gain = max(channelamplitude) ./ channelamplitude;
digitalWeights = digitalWeights .* gain';

% Save the weights for later analysis
CalibrationData.CalibrationWeights.DigitalAmplitudeWeights.AnalogWeights = analogWeights;
CalibrationData.CalibrationWeights.DigitalAmplitudeWeights.DigitalWeights = digitalWeights;

% Calculate the channel calibration phase by steering channel 2 from 0 to
% 360 and finding the maximum combined channel amplitude
channel2phase = deg2rad(0:360);
st_vec = [ones(size(channel2phase)); exp(1i*channel2phase)];
sig = analogcaldata*conj(st_vec);
sigfft = fft(sig);
combinedamplitude = max(abs(sigfft));
[~, phaseIdx] = max(combinedamplitude);

% Plot the digital phase offset pattern and calibration value
ax = axes(figure); hold(ax,"on");
title(ax,"Digital Phase Calibration"); ylabel(ax,"dB"); xlabel(ax,"Channel 2 Phase Offset (deg)");
plot(ax,channel2phase,combinedamplitude,"DisplayName","Combined Channel Power");
scatter(ax,channel2phase(phaseIdx),combinedamplitude(phaseIdx),"DisplayName","Selected Phase Offset");
legend('location','southeast');

% Set the new digital weights
defaultsteervec = st_vec(:,phaseIdx);
digitalWeights = digitalWeights .* defaultsteervec;

% Save the final calibration weights
CalibrationData.CalibrationWeights.FinalCalibrationWeights.AnalogWeights = analogWeights;
CalibrationData.CalibrationWeights.FinalCalibrationWeights.DigitalWeights = digitalWeights;

%% Release Hardware

% Cleanup resources
cleanupAntenna(rx,tx,bf,bf_TDD);

%% Plot final data: uncalibrated data vs. calibrated data vs. simulated data

% Use a custom class called AntennaInteractor to help steer the antenna
initialcalvalues = CalibrationData.CalibrationWeights.UncalibratedWeights;
antennaInteractor = AntennaInteractor(fc_hb100,initialcalvalues);
steerangles = -90:0.5:90;

% Capture the pattern with the initial calibration values
[initialpattern,~] = antennaInteractor.capturePattern(steerangles);
initialamp = mag2db(helperGetAmplitude(initialpattern));

% Capture the pattern with the final calibration values
finalcalvalues = CalibrationData.CalibrationWeights.FinalCalibrationWeights;
antennaInteractor.updateCalibration(finalcalvalues);
[finalpattern,~] = antennaInteractor.capturePattern(steerangles);
finalamp = mag2db(helperGetAmplitude(finalpattern));

% Simulate the expected antenna pattern
rxpos = [0;0;0]; % phaser at 0
txpos = [0;10;0]; % transmitter 10 meters away at 0 boresight
simpattern = mag2db(helperSimulateAntennaSteering(fc_hb100,rxpos,txpos,steerangles));

% Plot data
patternax = axes(figure); hold(patternax,"on"); legend(patternax);
xlabel(patternax,"Steer Angle (deg)"); ylabel(patternax,"Amplitude (dB)"); title(patternax,"Calibration Effect");
plot(patternax,steerangles,initialamp - max(initialamp),'DisplayName','Uncalibrated Array Factor');
plot(patternax,steerangles,finalamp - max(finalamp),'DisplayName','Calibrated Array Factor');
plot(patternax,steerangles,simpattern - max(simpattern),'DisplayName','Simulated Array Factor');

end
