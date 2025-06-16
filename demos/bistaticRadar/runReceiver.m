% Run this script while runTransmitter.m is running from a different Phaser
% board and location. Ensure that the calibration script  in
% shared\calibration\generateCalibrationWeights has been run so that
% calibration weights have been saved.

% The first part of this script locations the transmitter direction. This
% is critical so that the reference and surveillance channels can be
% steered accordingly.

% The second part of this script runs the bistatic radar and saves the data
% after running.

%% Search for the transmitter location by sweeping the beamformer

% Setup our antenna interactor
fc = 10e9; % This must match the transmitter center frequency
lambda = freq2wavelen(fc);
load('CalibrationWeights.mat','calibrationweights');
ai = AntennaInteractor(fc,calibrationweights);

% Steer across our field of view, searching for the transmitter
searchAngles = -90:0.5:90;
pattern = ai.capturePattern(searchAngles);
patternMag = mean(abs(pattern),1);

% Plot captured pattern
ax = axes(figure);
plot(ax,searchAngles,patternMag);
title(ax,'Captured Pattern');
xlabel(ax,'Angle (deg)');
ylabel(ax,'Magnitude');

% Calculate location of transmitter
[~,angIdx] = max(patternMag);
txAng = searchAngles(angIdx);

% Release internal objects
clear ai;
ai = AntennaInteractor(fc,calibrationweights);

% Set the surveillance steering angle
survAng = 0;

% Get steering weights
refWeights = steervec(getElementPosition(ai.Model.Subarray)/lambda,txAng);

% Generate null weights
survWeights = nullweights(getElementPosition(ai.Model.Subarray)/lambda,survAng,txAng);

% Save the steering weights
steerWeights = [refWeights survWeights];

% Set the number of samples to collect.
nSamples = 1e6;
ai.NumSamples = nSamples;

%% Run the bistatic radar receiver

% Look for targets max 200 m, 40 m/s
maxRange = 100;
maxVel = 40;

% Create scope
scope = phased.RangeDopplerScope(IQDataInput=false,DopplerLabel='Velocity (m/s)');

% Can turn processing on or off. Turn it off for pure data collection.
processData = true;

% Run bistatic radar
nRuns = 60;
savedData = cell(nRuns,1);
t = tic;
time = zeros(nRuns,1);
for i = 1:nRuns
    % Capture data
    rxdata = ai.steerAnalog(steerWeights);
    savedData{i} = rxdata;
    time(i) = toc(t);

    if processData
        % Get ref and surv
        ref = rxdata(:,2);
        surv = rxdata(:,1);
    
        % Least squares adaptive filtering
        nTaps = 100;
        survfilt = helperFrequencyDomainFilter(ref,surv,nTaps);
    
        % Calculate range-Doppler Response
        [resp,range,speed] = helperBistaticRangeDoppler(survfilt,ref,ai.Fs,ai.Fc,maxRange,maxVel,false);
    
        % Plot range-Doppler
        scope(resp,range',speed');
    end
end

% Save data
fs = ai.Fs;
fc = ai.Fc;
t = char(datetime("now","Format",'ss_mm_hh_dd_MM'));
filename = sprintf('BistaticData_%s.mat',t);
save(filename,"savedData","fs","fc","maxRange","maxVel");

% Cleanup the antenna interactor
ai.cleanup();

%% Helper functions

function weights = nullweights(pos,dsteer,dnull)
    % Calculate the steering vector for null directions
    wn = steervec(pos,dnull);
    
    % Calculate the steering vectors for lookout directions
    wd = steervec(pos,dsteer);
    
    % Compute the response of desired steering at null direction
    rn = wn'*wd/(wn'*wn);
    
    % Sidelobe canceler - remove the response at null direction
    weights = wd-wn*rn;
end

function survest = helperFrequencyDomainFilter(ref,surv,M)
    % Compute the weights
    weights = ifft(fft(surv)./fft(ref));

    % Apply the first M weights
    survest = surv-filter(weights(1:M),1,ref);
end

function [resp,range,speed] = helperBistaticRangeDoppler(surv,ref,fs,fc,maxRange,maxSpeed,mtifilter)
    % Rearrange data into columns
    ns = length(surv);
    prf = ceil(2*speed2dop(maxSpeed,freq2wavelen(fc)));
    nSamplePerPulse = ceil(fs/prf);
    nCol = floor(ns/nSamplePerPulse);
    ns = nCol*nSamplePerPulse;
    surv = surv(1:ns);
    ref = ref(1:ns);
    survMat = reshape(surv,[nSamplePerPulse nCol]);
    refMat = reshape(ref,[nSamplePerPulse nCol]);

    % Get the Doppler freq shifts and speeds
    prf = 1/(nSamplePerPulse/fs);
    dopFreqs = -prf/2:prf/(nCol-1):prf/2;
    speed = dop2speed(dopFreqs,freq2wavelen(fc));

    % Get the bistatic ranges
    rangeRes = physconst('LightSpeed')/fs;
    nLag = ceil(maxRange/rangeRes);
    range = (-nLag:nLag)*rangeRes;

    % Cross correlate each surveillance with reference
    resp = zeros(length(range),nCol);
    for iCol = 1:nCol
        resp(:,iCol) = xcorr(survMat(:,iCol),refMat(:,iCol),nLag);
    end

    if mtifilter
        h = [1 -2 1];
        resp = filter(h,1,resp,[],2);
        resp = resp(:,3:end);
        speed = speed(2:end-1);
    end

    % FFT slow time for Doppler shift
    resp = abs(fftshift(fft(resp,[],2),2));
end