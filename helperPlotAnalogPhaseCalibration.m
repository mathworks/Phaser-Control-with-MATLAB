function helperPlotAnalogPhaseCalibration(phasesetting,sub1amplitudes,sub2amplitudes)
    % Visualize the element-wise phase calibration data for the entire
    % array.

    % Copyright 2023 The MathWorks, Inc.
    
    figure; tiledlayout(1,2); nexttile();
    helperPlotPhaseSubarrayData("Subarray 1",phasesetting,mag2db(sub1amplitudes)); nexttile();
    helperPlotPhaseSubarrayData("Subarray 2",phasesetting,mag2db(sub2amplitudes));
end

function helperPlotPhaseSubarrayData(name, phasesetting, phaseOffsetAmplDb)
    % Visualize the element-wise phase calibration data for a subarray.
    lines = plot(phasesetting, phaseOffsetAmplDb);
    lines(1).DisplayName = "Element 2";
    lines(2).DisplayName = "Element 3";
    lines(3).DisplayName = "Element 4";
    title([name,' - Phase Calibration Data'])
    ylabel("Amplitude (dB) Element X + Element 1")
    xlabel("Test Element Phase Shift (deg)")
    legend("Location","southoutside")
end