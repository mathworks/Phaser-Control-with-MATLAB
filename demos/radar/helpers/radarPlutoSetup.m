function radarPlutoSetup(tx,rx,fs,nSamples)
% Setup pluto TX and RX for radar
%
% Copyright 2023 The MathWorks, Inc.

% Setup transmitter
tx.SamplingRate = fs;
tx.EnabledChannels = [1,2];
tx.CenterFrequency = rx.CenterFrequency;
tx.AttenuationChannel0 = -80;
tx.AttenuationChannel1 = -3;
tx.EnableCyclicBuffers = true;
tx.DataSource = "DMA";

% Setup receiver sampling
rx.SamplesPerFrame = nSamples;
rx.SamplingRate = fs;

end

