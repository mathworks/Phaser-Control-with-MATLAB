fc = 10e9; % This must match the transmitter center frequency
load('CalibrationWeights.mat','calibrationweights');
ai = AntennaInteractor(fc,calibrationweights);
fs = ai.PlutoControl.SamplingRate;
df = fs/(ai.NumSamples-1);
fspan = -fs/2:df:fs/2;

ax = axes(figure);

for i = 1:1e6
    data = ai.capturePattern(0);
    F = fft(data);
    plot(ax,fspan,fftshift(abs(F)));
    drawnow;
end

clear;
close all;