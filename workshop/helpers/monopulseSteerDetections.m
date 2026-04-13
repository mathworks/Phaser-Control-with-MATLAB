function detectionsOut = monopulseSteerDetections(data,time,config,trueRange,args)
% Get detections in data by looking for the steer angle with the
% maximum SNR.
arguments
    data
    time
    config
    trueRange
    args.MtiFilter = false
end

% Get values out of config
prf = config.PRF;
nPulses = config.NumPulses;
fc = config.Fc;
fs = config.Fs;
tSweep = config.SweepTime;
rampBandwidth = config.RampBandwidth;
steerang = config.SteerAngles;
tStartSweep = config.SweepStartTime;
tFrame = config.FrameTime;

% Initialize detections out
nCaptures = size(data,1);
nAngles = size(data,2);
detectionsOut = cell(1,nCaptures);

% Setup CFAR
pfa = 1e-6;
guard = 2;
train = 2;
cfar = phased.CFARDetector2D(ProbabilityFalseAlarm=pfa,GuardBandSize=[guard guard],TrainingBandSize=[train train],NoisePowerOutputPort=true);

% Setup mti
if args.MtiFilter
    mti = [1 -2 1];
    nfilt = length(mti);
else
    mti = [];
    nfilt = 1;
end

% Get cells under test
minRange = 0.1;
maxRange = 10;
vmin = 0.25;
vmax = inf;
[cut,speed,range] = getCFARCUT(minRange,maxRange,vmin,vmax,guard,train,prf,nPulses-nfilt+1,fc,fs,tSweep,rampBandwidth);

% Define detection parameters
detParams = struct(Frame="spherical",HasElevation=false);
azErr = 30;
rangeErr = range(2)-range(1);
speedErr = speed(2)-speed(1);
measNoise = diag([azErr;rangeErr;speedErr]);

% Create the range-DopplerResponse
sweepSlope = rampBandwidth/tSweep;
rd = phased.RangeDopplerResponse(DopplerOutput="Speed",...
    OperatingFrequency=fc,SampleRate=fs,RangeMethod="FFT",...
    SweepSlope=sweepSlope,PRFSource="Property",PRF=prf,RangeWindow='Hamming',DopplerWindow='Hamming');

% Plot the range-Doppler response for each angle
for iCapture = 1:nCaptures
    t = time(iCapture);

    % Perform CFAR on each set of data
    nrange = length(range);
    nspeed = length(speed);
    rdprocessed = zeros(nrange,nspeed,nAngles);
    detblock = 1000;
    detectionMeasurements = zeros(4,detblock);
    startDetIdx = 1;

    for iAng = 1:nAngles
        % Get data
        cdata = data{iCapture,iAng};

        % Get rd response for sum and diff
        sumdata = cdata;
        diffdata = cdata .* [1 -1];
        
        % Arrange into pulses
        sumdatapulse = arrangePulseDataFromTiming(sumdata,fs,tSweep,tStartSweep,tFrame,nPulses);
        diffdatapulse = arrangePulseDataFromTiming(diffdata,fs,tSweep,tStartSweep,tFrame,nPulses);
        
        % MTI filter
        if args.MtiFilter
            sumdatapulse = filter(mti,1,sumdatapulse,[],2);
            sumdatapulse = sumdatapulse(:,nfilt:end);
            diffdatapulse = filter(mti,1,diffdatapulse,[],2);
            diffdatapulse = diffdatapulse(:,nfilt:end);
        end
        
        [sumrddata,~,~] = step(rd,sumdatapulse);
        [diffrddata,range,speed] = step(rd,diffdatapulse);
    
        % Save the steer angle
        cang = steerang(iAng);
    
        % Get index of detections on the sum data
        [d] = cfar(abs(sumrddata).^2,cut);
        detidx = cut(:,d');
    
        % Get the range, speed, steer angle, and SNR for the detections
        detRange = range(detidx(1,:))';
        detSpeed = speed(detidx(2,:))';
        sumdetpow = abs(arrayfun(@(row,col)sumrddata(row,col),detidx(1,:),detidx(2,:))).^2;
        diffdetpow = abs(arrayfun(@(row,col)diffrddata(row,col),detidx(1,:),detidx(2,:))).^2;
        detsdr = sumdetpow./diffdetpow;
        % 
        % tl = tiledlayout(figure,"horizontal");
        % plotrdImag(nexttile(tl),sumrddata,0,20,range,speed,detRange,detSpeed,['Angle = ',num2str(cang),', Sum']);
        % plotrdImag(nexttile(tl),diffrddata,0,20,range,speed,detRange,detSpeed,['Angle = ',num2str(cang),', Diff']);

        if isempty(detRange)
            continue
        end

        % Get cluster detections in range-Doppler for the current angle
        detClusters = dbscan([detRange' detSpeed'],1,3);

        % Create an objectDetection for each cluster
        singles = detClusters == -1;
        nSingles = sum(singles);
        clusters = unique(detClusters(detClusters > 0));
        nClusters = length(clusters);
        nDetections = nSingles + nClusters;
        clusterMeas = zeros(4,nDetections);
        didx = 1;
    
        % Create detections from the unclustered measurements
        unclustered = find(singles);
        for isingle = 1:nSingles
            cidx = unclustered(isingle);
            srange = detRange(cidx);
            sspeed = detSpeed(cidx);
            ssdr = detsdr(cidx);
            clusterMeas(:,didx) = [srange;sspeed;cang;ssdr];
            didx = didx + 1;
        end
    
        % Create detections from the clustered measurements. use sdr for
        % highest power detection.
        for icluster = 1:nClusters
            % Get values for current cluster
            crange = mean(detRange(detClusters == icluster));
            cspeed = mean(detSpeed(detClusters == icluster));
            [~,cpowidx] = max(sumdetpow);
            %csdr = mean(detsdr(detClusters == icluster));
            csdr = detsdr(cpowidx);
            clusterMeas(:,didx) = [crange;cspeed;cang;csdr];
            didx = didx + 1;
        end
    
        % Save detections and RD response for angle processing
        ndets = size(clusterMeas,2);
        endDetIdx = startDetIdx + ndets - 1;
    
        % Handle overflow if we exceed pre-allocated number of detections
        if endDetIdx > size(detectionMeasurements,2)
            newdetections = zeros(4,endDetIdx);
            newdetections(:,1:startDetIdx-1) = detectionMeasurements;
            detectionMeasurements = newdetections;
        end
    
        % Save detection values
        detectionMeasurements(:,startDetIdx:endDetIdx) = clusterMeas;
        startDetIdx = endDetIdx + 1;
        rdprocessed(:,:,iAng) = sumrddata;
    end

    % Get only the populated detection values
    if startDetIdx == 1
        continue
    else
        detectionMeasurements = detectionMeasurements(:,1:startDetIdx-1);
    end
    
    % Get cluster detections in range-Doppler
    detClusters = dbscan(detectionMeasurements(1:2,:).',1,3);

    % Create an objectDetection for each cluster
    singles = detClusters == -1;
    nSingles = sum(singles);
    clusters = unique(detClusters(detClusters > 0));
    nClusters = length(clusters);
    nDetections = nSingles + nClusters;
    detections = cell(nDetections,1);
    didx = 1;

    % Create detections from the unclustered measurements
    unclustered = detectionMeasurements(1:3,singles);
    for isingle = 1:nSingles
        daz = unclustered(3,isingle);
        drange = unclustered(1,isingle);
        dspeed = unclustered(2,isingle);
        measurement = [daz;drange;dspeed];
        detections{didx} = objectDetection(t,measurement,MeasurementNoise=measNoise,MeasurementParameters=detParams);
        didx = didx + 1;
    end

    % Create detections from the clustered measurements
    for icluster = 1:nClusters
        % Get values for current cluster
        clusterValues = detectionMeasurements(:,detClusters == icluster);

        % Range and speed are the means
        clusterRange = mean(clusterValues(1,:));
        clusterSpeed = mean(clusterValues(2,:));

        % AOA is the max SNR value
        [~, aoaIdx] = max(clusterValues(4,:));
        clusterAz = clusterValues(3,aoaIdx);

        % Save the measurements
        measurement = [clusterAz;clusterRange;clusterSpeed];
        detections{didx} = objectDetection(t,measurement,MeasurementNoise=measNoise,MeasurementParameters=detParams);
        didx = didx + 1;
    end

    % Get the detection nearest to the true range
    detectionsOut{iCapture} = getNearestDetection(detections,trueRange);
end

end

function dout = getNearestDetection(detections,truerange)
    % Return the detection that is closest to the true detection in range.
    % If closest is too far away, return empty.

    drange = cell2mat(cellfun(@(X)X.Measurement(2),detections,'UniformOutput',false));
    rangeErr = abs(drange-truerange);
    [minval,minidx] = min(rangeErr);
    if minval > 2
        dout = [];
    else
        dout = detections{minidx};
    end
end

function plotrdImag(ax,rddata,rmin,rmax,range,speed,detRange,detSpeed,axtitle)
    hold(ax,"on");
    keeprange = range >= rmin & range <= rmax;
    imagesc(ax,speed,range(keeprange),abs(rddata(keeprange,:)));
    scatter(ax,detSpeed,detRange);
    title(ax,axtitle);
end