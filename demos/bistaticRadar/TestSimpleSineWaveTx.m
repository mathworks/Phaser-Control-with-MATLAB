clear all
pause(3)

% Configure Signal
nSamples = 1e5;
fc = 10e9;
fs = 30e6;

%% Generate tone (from ADI doc) - Used for confirming Tx functional and
% Rx functional
amplitude = 2^15; frequency = 5e6;
swv1 = dsp.SineWave(amplitude, frequency);
swv1.ComplexOutput = true;
swv1.SamplesPerFrame = 2^14;
swv1.SampleRate = fs;
y = swv1();


% Setup Radar
[rx,tx,bf] = setupBistaticRadar(fc,fs,nSamples);
tx.RFBandwidth = fs; % Reduce effect of filter on our Tx waveform

%% Begin Signal Transmit
tx([y y])
