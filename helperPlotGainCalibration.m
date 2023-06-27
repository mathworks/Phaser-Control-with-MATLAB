function gain = helperPlotGainCalibration(name, amplitudes)

% Copyright 2023 The MathWorks, Inc.

% Normalize amplitude for each element in the array
dbNormAmplitudes = mag2db(amplitudes./max(amplitudes));

% Calculate gain adjustment
gain = -mag2db(amplitudes./min(amplitudes));

% Plot normalized amplitudes and gain adjustments
b = bar([dbNormAmplitudes',gain'],'stacked');
b(1).DisplayName = "Initial Normalized Amplitude";
b(2).DisplayName = "Gain Adjustment";
xlabel('Antenna Element')
ylabel('dB');
title([name ' - Gain Calibration'])
legend('Location','southoutside')

end

