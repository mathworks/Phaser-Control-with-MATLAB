function scanAntenna(fc_hb100,CalibrationData,steerangles,scans,showsubchannels)
% This script can be called to freely scan the antenna to the desired
% steerangles for the desired number of scans. The subchannel amplitude data can be
% plotted if desired.

% Copyright 2023 The MathWorks, Inc.

antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);

% Setup the axes
patternax = axes(figure); hold(patternax,"on"); title("Antenna Scanning");
xlabel(patternax,"Scan Azimuth"); ylabel(patternax,"Amplitude (dB)"); legend(patternax,"Location","southeast");

numangles = numel(steerangles);
angleidx = 0;
plotamps = nan(1,numangles);
plotampss1 = nan(1,numangles);
plotampss2 = nan(1,numangles);
lastline = plot(patternax,steerangles,plotamps);
if showsubchannels
    sub1line = plot(patternax,steerangles,plotampss1);
    sub2line = plot(patternax,steerangles,plotampss2);
end

currentScan = 0;
while currentScan <= scans
    currentangle = steerangles(angleidx+1);
    angleidx = mod(angleidx+1,numangles);
    if angleidx == 1
        currentScan = currentScan+1;
    end
    [patterndata,rxdata] = antennaInteractor.capturePattern(currentangle);
    amp = helperGetAmplitude(patterndata);
    seperatesubamp = helperGetAmplitude(rxdata);
    aidx = steerangles == currentangle;
    plotamps(aidx) = amp;
    delete(lastline);
    lastline = plot(patternax,steerangles,mag2db(plotamps),"Color",'r','DisplayName','Combined Channels');
    if showsubchannels
        plotampss1(aidx) = seperatesubamp(1);
        plotampss2(aidx) = seperatesubamp(2);
        delete(sub1line);
        delete(sub2line);
        sub1line = plot(patternax,steerangles,mag2db(plotampss1),"Color",'g','DisplayName','Subchannel 1');
        sub2line = plot(patternax,steerangles,mag2db(plotampss2),"Color",'b','DisplayName','Subchannel 2');
    end 
    drawnow;
end

end

