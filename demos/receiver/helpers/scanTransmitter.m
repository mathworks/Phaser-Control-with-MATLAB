function scanTransmitter(fc_hb100,CalibrationData,scanangle,tscan)
    % Leave antenna steering to boresight and move the antenna to try to
    % capture the antenna pattern.

    % Copyright 2023 The MathWorks, Inc.

    antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);

    patternax = axes(figure);
    hold(patternax,"on"); title(patternax,['Measured Amplitude (Scan Angle = ',num2str(scanangle),')']); ylabel("Amplitude (dB)");

    tcurrent = 0;
    t = [];
    amp = [];
    l = plot(t,amp);
    tic;
    while tcurrent < tscan
        [patterndata,~] = antennaInteractor.capturePattern(scanangle);
        ampcurrent = mag2db(helperGetAmplitude(patterndata));
        amp = [amp,ampcurrent];
        tcurrent = toc;
        t = [t,tcurrent];
        delete(l);
        l = plot(patternax,t,amp,"Color","b");
        drawnow;
    end

end