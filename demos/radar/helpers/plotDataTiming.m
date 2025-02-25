function plotDataTiming(data,tx,bf_TDD)
% Plot the timing for a pulse group.

fs = tx.SamplingRate;
tStartRamp = bf_TDD.Ch0On;
tSweep = bf_TDD.Ch0Off;
tPulse = bf_TDD.FrameLength/1e3;

plotSinglePulseTiming(data,fs,tStartRamp,tSweep,tPulse);
plotAllPulses(data,fs,tPulse);

end

function plotSinglePulseTiming(data,fs,tStartRamp,tSweep,tPulse)
    % Plot the data collection timing diagram. Only plot a single channel of data
    pulseSamples = floor(tPulse*fs);
    pulseTimes = 0:tPulse/(pulseSamples-1):tPulse;
    firstPulseReal = real(data(1:pulseSamples,1));
    minData = min(firstPulseReal);
    maxData = max(firstPulseReal);

    % Convert to ms
    scalefactor = 1e3;
    pulseTimes = pulseTimes * scalefactor;
    tStartRamp = tStartRamp * scalefactor;
    tSweep = tSweep * scalefactor;
    tPulse = tPulse * scalefactor;
    
    ax1 = axes(figure); hold(ax1,"on"); title(ax1,"Timing for a single pulse");
    plot(ax1,pulseTimes,firstPulseReal,DisplayName="Collected Data");
    plot(ax1,[tStartRamp,tStartRamp],[minData,maxData],DisplayName="Start Frequency Ramp",LineStyle="--");
    plot(ax1,[tSweep,tSweep],[minData,maxData],DisplayName="End Frequency Ramp",LineStyle="--");
    plot(ax1,[tPulse,tPulse],[minData,maxData],DisplayName="End Burst Frame",LineStyle="--");
    xlim(ax1,[0-tPulse/10 tPulse+tPulse/10]); xlabel(ax1,"Time (ms)"); legend(ax1,Visible="on");
    hold(ax1,"off");
end

function plotAllPulses(data,fs,tPulse)
    % Plot all of the data with ends of pulse periods
    
    % Get collected data to plot
    nSamples = size(data,1);
    tEnd = getEndTime(data,fs);
    allTimes = 0:tEnd/(nSamples-1):tEnd;
    dataReal = real(data(:,1));

    % Get pulse period ends to plot
    nPulses = getPulseNum(data,fs,tPulse);
    pulseIdx = 1:nPulses;
    tEndPulses = pulseIdx * tPulse;
    pulseEndTimes = [tEndPulses;tEndPulses];
    pulseEndY = repmat([min(dataReal);max(dataReal)],1,nPulses);

    % Convert to ms
    scalefactor = 1e3;
    allTimes = allTimes * scalefactor;
    pulseEndTimes = pulseEndTimes * scalefactor;
    
    ax1 = axes(figure); hold(ax1,"on"); title(ax1,"Timing for entire PRI");
    plot(ax1,allTimes,dataReal,DisplayName="Collected Data");
    plot(ax1,pulseEndTimes,pulseEndY,DisplayName="End of Burst Frame",Color="k",LineStyle="--");
    xlabel(ax1,"Time (ms)"); l = legend(ax1,Visible="on"); l.String = l.String(1:2);
    hold(ax1,"off");
end

function nPulses = getPulseNum(data,fs,tPulse)
    tEnd = getEndTime(data,fs);
    nPulses = round(tEnd / tPulse);
end

function tEnd = getEndTime(data,fs)
    nSamples = size(data,1);
    tEnd = nSamples/fs;
end
