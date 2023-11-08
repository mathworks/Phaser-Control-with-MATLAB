function data = captureTransmitWaveform(txWaveform,rx,tx,bf)
% Capture the transmitted waveform, the system has to be set up for
% transmit in this case.

% Set transmit waveform
tx(txWaveform);

% Trigger burst pulse
bf.Burst=false;bf.Burst=true;bf.Burst=false;

% Capture pulse period
data = rx();
end