clear all
pause(3)

% Configure Signal
nSamples = 1e5;
sig = 2^15*exp(1i*2*pi*(rand(nSamples,1)-0.5));
fc = 10e9;
fs = 30e6;

% Setup Radar
[rx,tx,bf] = setupBistaticRadar(fc,fs,nSamples);
tx.RFBandwidth = fs; % Reduce effect of filter on our Tx waveform

%% Begin Signal Transmit
tx([sig sig])

