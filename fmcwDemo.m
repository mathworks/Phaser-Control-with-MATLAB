% Copyright 2023 The MathWorks, Inc.

%% Clear, close figures, turn off warnings
clear; close all;
warning('off','MATLAB:system:ObsoleteSystemObjectMixin')

%% Put some requirements on the system

maxRange = 10; % 100 m max range, use the system in a room
rangeResolution = 1/3; % Range resolution of 1/3 m
maxSpeed = 5; % Max speed we expect is 5 m/s, somebody moving towards the radar
speedResolution = 1/2; % Speed resolution of 1/2 m/s

%% Determine some parameter values based on system requirements, based on the
% following example - https://www.mathworks.com/help/radar/ug/automotive-adaptive-cruise-control-using-fmcw-technology.html

fc = 10e9; % rf carrier frequency is ~10 GHz
lambda = physconst("LightSpeed") / fc;
rampbandwidth = ceil(rangeres2bw(rangeResolution)/1e6)*1e6; % get ramp bandwidth for required range resolution, conviniently this brings us close to the maximum for the Phaser
fmaxdop = speed2dop(2*maxSpeed,lambda); % Maximum doppler shift depends on max speed we want to resolve, multiply by 2 for 2 way propagation
prf = 2*fmaxdop; % PRF needs to be set to unambiguously resolve max speed
nPulses = ceil(2*maxSpeed/speedResolution); % Number of pulses set to for speed resolution
tpulse = ceil((1/prf)*1e3)*1e-3; % Pulse time, round up to the nearest ms
tsweep = getSweepTime(tpulse,tpulse); % Sweep across as much of the pulse as possible
sweepslope = rampbandwidth / tsweep; % Slope of the FMCW sweep
fmaxbeat = sweepslope * range2time(maxRange); % Max beat frequency in this case we only consider the f offset due to range delay. With faster targets, you need to consider doppler
fs = max(ceil(2*fmaxbeat),520834); % Set sample rate based on the maximum beat frequency or the minimum rate of the pluto.
nSamples = ceil(tpulse * nPulses * fs); % Get the total number of samples in a PRP

%% Setup pluto

% Setup the pluto
plutoURI = 'ip:192.168.2.1';
[rx,tx] = setupPluto(plutoURI);

% Setup receiver
rx.SamplesPerFrame = nSamples;
rx.SamplingRate = fs;

% Setup transmitter
tx.SamplingRate = fs;
tx.EnabledChannels = [1,2];
tx.CenterFrequency = rx.CenterFrequency;
tx.AttenuationChannel0 = -3;
tx.AttenuationChannel1 = -3;
tx.EnableCyclicBuffers = true;
tx.DataSource = "DMA";

% Create a sine wave to transmit, this will offset the output waveform from
% the center frequency to avoid issues with DC removal
amp = 0.9*2^15; % Max amplitude of the signal
% foffset = 0.1e6; % Sin wave offsets the carrier frequency by a small portion of the sampling rate
% phase = 0; % No phase offset
% sw = dsp.SineWave(amp,foffset,phase,ComplexOutput=true,SampleRate=fs,SamplesPerFrame=nSamples);
% singleWaveform = sw();
% txWaveform = [singleWaveform singleWaveform];
txWaveform = amp*ones(nSamples,2);
tx(txWaveform);

%% Setup the Phaser

% Beamformers
phaserURI = 'ip:phaser.local';
bf = setupPhaser(rx,phaserURI,fc);
bf.RxPowerDown(:) = 0;
bf.RxGain(:) = 127;

% ADF4159
bf.Frequency = (fc+rx.CenterFrequency)/4;
BW = rampbandwidth / 4; 
num_steps = 2^9;
bf.FrequencyDeviationRange = BW;
bf.FrequencyDeviationStep = ((BW) / num_steps);
bf.FrequencyDeviationTime = tsweep*1e6; % convert to us
bf.RampMode = "single_sawtooth_burst";
bf.TriggerEnable = true;  % start a ramp with TXdata
bf.EnablePLL = true;
bf.EnableTxPLL = true;
bf.EnableOut1 = false; % send transmit out of SMA2

%% Setup the TDD engine

tStartRamp = 0;
tStartCollection = 0;
bf_TDD = adi.PhaserTDD('uri', plutoURI);
bf_TDD();
bf_TDD.Enable = 0;   % TDD must be disabled before changing properties
bf_TDD.EnSyncExternal = 1;
bf_TDD.StartupDelay = 0;
bf_TDD.SyncReset = 0;
bf_TDD.FrameLength = tpulse*1e3;  %frame length in ms
bf_TDD.BurstCount = nPulses;
bf_TDD.Ch0Enable = 1;
bf_TDD.Ch0Polarity = 0;
bf_TDD.Ch0On = tStartRamp;
bf_TDD.Ch0Off = tsweep; % this doesn't need to be tsweep, this just ensures control pulse ends before next PLL pulse starts
bf_TDD.Ch1Enable = 1;
bf_TDD.Ch1Polarity = 0;
bf_TDD.Ch1On = tStartCollection;
bf_TDD.Ch1Off = tStartCollection+0.1;
bf_TDD.Enable = 1;

%% Trigger TDD and Plot

rx();
tx(txWaveform);
bf.Burst=false;bf.Burst=true;bf.Burst=false;
data = rx();

% Rearrange data to be nSamples x nPulses, throw out samples when the PLL is not sweeping

% Show data timing
plotDataTiming(data,fs,tStartRamp,tsweep,tpulse);

% Remove excess data, rearrange into nSamples x nPulses
data = arrangeData(data,fs,tStartRamp,tsweep,tpulse);

% Demodulate the data

% Remove the frequency offset that was added to the data
%data = removeFreqShift(data,fs,foffset);

% Create a range doppler plot
rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
    SweepSlope=sweepslope,PRFSource="Property",PRF=prf);
axes(figure)
rd.plotResponse(data);
ax = gca;
xlim(ax,[-maxSpeed,maxSpeed]); ylim(ax,[0,maxRange]);

%% Helpers

function tsweep = getSweepTime(tdesired,tmax)
% This function takes tdesired (s) and tmax(s) and outputs tsweep (s) which
% contains a sweep time that is acceptable for the PLL. PLL sweep times
% must be in whole 2^p us. We try to round up, if this exceeds tmax we
% round down.

tdesiredus = tdesired*1e6;
tmaxus = tmax*1e6;
desiredpower2 = nextpow2(tdesiredus);
tdesiredusrounded = 2^desiredpower2;

if tdesiredusrounded > tmaxus
    tdesiredusrounded = 2^(desiredpower2-1);
end

tsweep = tdesiredusrounded / 1e6;

end

function plotDataTiming(data,fs,tStartRamp,tSweep,tPulse)

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

    % Get the start and end of data collection based on the ramp start time
    % and sweep time
    [tStartData,tEndData] = getDataStopStartTime(tStartRamp,tSweep);

    % Convert to ms
    scalefactor = 1e3;
    pulseTimes = pulseTimes * scalefactor;
    tStartRamp = tStartRamp * scalefactor;
    tSweep = tSweep * scalefactor;
    tPulse = tPulse * scalefactor;
    tStartData = tStartData * scalefactor;
    tEndData = tEndData * scalefactor;
    
    ax1 = axes(figure); hold(ax1,"on"); title(ax1,"Timing for a single pulse");
    plot(ax1,pulseTimes,firstPulseReal,DisplayName="Collected Data");
    plot(ax1,[tStartRamp,tStartRamp],[minData,maxData],DisplayName="Start Frequency Ramp",LineStyle="--");
    %plot(ax1,[tStartData,tStartData],[minData,maxData],DisplayName="Start Data Collection",LineStyle="--");
    plot(ax1,[tSweep,tSweep],[minData,maxData],DisplayName="End Frequency Ramp",LineStyle="--");
    %plot(ax1,[tEndData,tEndData],[minData,maxData],DisplayName="End Data Collection",LineStyle="--");
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

function outdata = arrangeData(indata,fs,tstartsweep,tsweep,tpulse)

nPulses = getPulseNum(indata,fs,tpulse); % get the number of pulses in the data set
sweepoffsetsamples = ceil(tstartsweep * fs); % get the number of samples into the pulse that the sweep starts
sweepsamples = 1:ceil(tsweep * fs) + sweepoffsetsamples; % got indices within a pulse that contain the sweep data
pulseendsample = ceil(tpulse * fs); % get end index of pulse
pulsestartsamples = (0:nPulses-1)*pulseendsample;
allsweepsamples = repmat(sweepsamples',1,nPulses);
sampleidxs = allsweepsamples + pulsestartsamples;
outdata = indata(sampleidxs);

end

function outdata = removeFreqShift(indata,fs,foffset)

% get number of samples to shift
nSamples = size(indata,1);
nShift = ceil(nSamples/fs*foffset);

% get signal in freq domain, shift, output
fInput = fft(indata,[],1);
fInputShift = circshift(fInput,-nShift,1);
outdata = ifft(fInputShift,[],1);

end

function [tStart,tStop] = getDataStopStartTime(tStartRamp,tSweep)
% Throw out some data on either end of the frequency ramp to avoid
% nonlinear ramp regions

startOffsetPercent = 0;
endOffsetPercent = 0;

tStart = tStartRamp + tSweep * startOffsetPercent;
tStop = tStartRamp + tSweep - tSweep * endOffsetPercent;

end



