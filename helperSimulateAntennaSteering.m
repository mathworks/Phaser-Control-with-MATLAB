function [rxamp,rxphase] = helperSimulateAntennaSteering(fctransmit,rxpos,txpos,steerangle,analogweight,digitalweight,nullangle)
% This helper function simulates antenna steering for the ADI workshop.
% analogweight and digitalweight are optional inputs that default to 1.
arguments
    fctransmit (1,1) double
    rxpos (3,1) double
    txpos (3,1) double
    steerangle (1,:) double
    analogweight (4,2) double = ones(4,2)
    digitalweight (2,1) double = ones(2,1)
    nullangle = []
end

% Copyright 2023 The MathWorks, Inc.

% Setup the transmitter
txelement = phased.IsotropicAntennaElement;
radiator = phased.Radiator("Sensor",txelement,"OperatingFrequency",fctransmit);

% Setup the Phased Array Receiver based on the Phaser specs
frange = [10.0e9 10.5e9];
sampleRate = 30e6;
nsamples = 1024;
element = phased.IsotropicAntennaElement('FrequencyRange',frange);
hRange = freq2wavelen(frange);
spacing = hRange(2)/2;
subarrayElements = 4;
subarray = phased.ULA('Element',element,'NumElements',subarrayElements,'ElementSpacing',spacing);
array = phased.ReplicatedSubarray('Subarray',subarray,'GridSize',[1,2],"SubarraySteering","Custom");
collector = phased.Collector("Sensor",array,"OperatingFrequency",fctransmit,"WeightsInputPort",true);

% CW signal is used
signal = ones(nsamples,1);

% Set up a channel for radiating signal
channel = phased.FreeSpace("OperatingFrequency",fctransmit,"SampleRate",sampleRate);

% Setup geometry
rxvel = [0;0;0];
txvel = [0;0;0];
[~,ang] = rangeangle(rxpos,txpos);

% Radiate signal
sigtx = radiator(signal,ang);

% Propagate signal
sigtx = channel(sigtx,txpos,rxpos,txvel,rxvel);

% Create steering vector for the two subarray channels
steervec = phased.SteeringVector("SensorArray",array);
substeervec = phased.SteeringVector("SensorArray",subarray);

% Receive signal while steering beam
rxphase = zeros(1,numel(steerangle));
rxamp = zeros(1,numel(steerangle));
for steer = steerangle
    % Create the subarray weights.
    singlesubweight = substeervec(fctransmit,steer);

    % Create the replicated array weights
    repweight = steervec(fctransmit,steer);

    % insert a null if a null angle was passed in
    if ~isempty(nullangle)
        % Null the subarray
        nullsubweight = substeervec(fctransmit,nullangle);
        singlesubweight = getNullSteer(singlesubweight,nullsubweight);

        % null the replicated array
        nullrepweight = steervec(fctransmit,nullangle);
        repweight = getNullSteer(repweight,nullrepweight);
    end

    % Create the full subarray weights
    subweight = [singlesubweight,singlesubweight] .* analogweight;

    % Receive the signal
    sigreceive = collector(sigtx,[0;0],repweight,subweight) * digitalweight;
    rxphase(steer == steerangle) = mean(rad2deg(angle(sigreceive)));
    rxamp(steer == steerangle) = mean(abs(sigreceive));
end

end

function nullsteer = getNullSteer(steerweight,nullweight)
    rn = nullweight'*steerweight/(nullweight'*nullweight);
    nullsteer = steerweight-nullweight*rn;
end