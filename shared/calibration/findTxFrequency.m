function txFrequency = findTxFrequency()
% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth.
%
% Notes:
% 
% The frequency of the phaser is swept between 10 and 10.5 GHz. The peak
% frequency is measured. This is assumed to be the frequency of the HB100.
%

% Copyright 2023 The MathWorks, Inc.

% Setup the frequencies to scan.
f_start = 10.e9;
f_stop = 10.5e9;
f_step = 5e6; 
fvec = f_start : f_step : f_stop;

% Setup the antenna, setting the frequency to f_start.
[rx,bf,~,tx,bf_TDD] = setupAntenna(f_start);

% Setup variables for capturing scan amplitude and frequency.
full_ampl = [];
full_freqs = [];
N = rx.SamplesPerFrame;

% Loop through the frequency vector and save receive data at each center
% frequency.
for centerfrequency = fvec
    % The LO is set to 4x the Frequency setting.
    bf.Frequency = (centerfrequency + rx.CenterFrequency)/4;
    rx();

    % Capture the data, sum the channels, and convert to the frequency domain
    data = rx();
    data = sum(data,2);
    famplitude = mag2db(1/N * fftshift(abs(fft(data))));
    full_ampl = [full_ampl, famplitude];

    % Get the frequency span for this data sample
    df = rx.SamplingRate/N;
    band = (-rx.SamplingRate/2 : df : rx.SamplingRate/2 - df);
    freqspan = centerfrequency-band;
    full_freqs = [full_freqs, freqspan'];
end

% Get the max amplitude for each measurement
[maxamplitudes,maxidxs] = max(full_ampl);

% Get the max amplitude in the whole dataset
[~,maxframeidx] = max(maxamplitudes);
maxdatapointidx = maxidxs(maxframeidx);

txFrequency = full_freqs(maxdatapointidx,maxframeidx);

ax = axes(figure);
plot(ax,full_freqs/1e9,full_ampl); xlabel('Frequency (GHz)'); ylabel('Amplitude (dB)');
title(ax,['HB100 Frequency = ' num2str(txFrequency/1e9) 'GHz']);

cleanupAntenna(rx,tx,bf,bf_TDD);

end
