function data = captureTransmitWaveform(rx,tx,bf,txWaveform)
% Capture the transmitted waveform, the system has to be set up for
% transmit in this case. If no waveform is specified, use a constant
% amplitude rectangle.
arguments
    rx
    tx
    bf
    txWaveform = []
end

% If no transmit waveform is specified, use a constaint amplitude
% rectangle.
if isempty(txWaveform)
    amp = 0.9 * 2^15;
    txWaveform = amp*ones(rx.SamplesPerFrame,2);
elseif size(txWaveform,2) == 1
    txWaveform = [txWaveform txWaveform];
end

% Set transmit waveform
tx(txWaveform);

% Trigger burst pulse
bf.Burst=false;bf.Burst=true;bf.Burst=false;

% Capture pulse period
data = rx();
end