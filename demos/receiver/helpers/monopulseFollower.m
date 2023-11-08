function monopulseFollower(fc_hb100,CalibrationData,runtime)
% Setup:
%
% Place the HB100 in front of the Phaser. Start the
% script. Once the script is running, move the location of the HB100 (or
% rotate the antenna). Watch the steering angle follow the location of the
% target based on the measured phase difference.
%
% Notes:
% 
%

% Copyright 2023 The MathWorks, Inc.

% Set the max data value
adcbits = 12;
maxdatavalue = 2^(adcbits-1);

% Set up the antenna interactor which captures data from the ADI board
antennaInteractor = AntennaInteractor(fc_hb100,CalibrationData);

% Setup steering angles
displayMeasurements = 500;
time = [];
steeringangles = [];
expired = false;

% setup the plot
ax = axes(figure);
title(ax,"Monopulse Follower"); xlabel(ax,"Steering Angle"); ylabel(ax,"Time");
xlim(ax,[-45 45]); hold(ax,"on");
datapoints = scatter(ax,steeringangles,time,"magenta");

% Get the initial target location by finding the max of the pattern
steerangles = -90:0.5:90;
initialpattern = antennaInteractor.capturePattern(steerangles);
initialpatternamp = helperCalculateAmplitude(initialpattern,maxdatavalue);
[~,targetlocation] = max(initialpatternamp);
currentsteeringangle = steerangles(targetlocation);

% Taper the antenna pattern by updating the magnitude of the default element
% weights
analogWeights = CalibrationData.AnalogWeights;
nsubs = 2; % number of subarrys
nels = 8; % number of elements
nbar = 2; sll = -20; % Taylor window taper parameters
taper = taylorwin(nels,nbar,sll);
taper = taper / max(taper);
taper = reshape(taper,[nels/nsubs,nsubs]);
analogTaperWeights = analogWeights .* taper;
analogTaperWeights = analogTaperWeights ./ max(abs(analogTaperWeights));
antennaInteractor.updateAnalogWeights(analogTaperWeights);

% run this loop until it is forcibly stopped or time runs out
tic;
while ~expired
    % get the current time
    time(end+1) = toc;

    % get the current steering angle by incrementing or decrementing the
    % last steering angle based on the monopulse phase
    [~,monopulsePhase,~,~] = antennaInteractor.captureMonopulsePattern(currentsteeringangle);
    if monopulsePhase > 0
        currentsteeringangle = currentsteeringangle - 1;
    else
        currentsteeringangle = currentsteeringangle + 1;
    end

    % save current steering angle
    steeringangles(end+1) = currentsteeringangle;


    % Only show a limited number of display measurements
    if numel(time) > displayMeasurements
        time(1) = [];
        steeringangles(1) = [];
    end

    % plot data
    delete(datapoints);
    datapoints = scatter(ax,steeringangles,time,"magenta");
    drawnow;

    if time(end) > runtime
        expired = true;
    end
end

end

