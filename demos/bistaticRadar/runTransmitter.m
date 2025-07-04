clear;
pause(3)

% Configure Signal
nSamples = 1e5;
sig = 2^15*exp(1i*2*pi*(rand(nSamples,1)-0.5));
fc = 10e9;
fs = 30e6;

% Setup Radar
[~,tx,~] = setupBistaticRadar(fc,fs,nSamples);

%% Begin Signal Transmit
disp('If logical 1 output, then you are transmitting:')
tx([sig sig])

