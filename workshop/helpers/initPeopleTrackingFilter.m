function filter = initPeopleTrackingFilter(detection)
% Create 3-D filter first
filter3D = initcvekf(detection);

% Create 2-D filter from the 3-D
state = filter3D.State(1:4);
stateCov = filter3D.StateCovariance(1:4,1:4);

% Reduce uncertainty in cross range-rate to 5 m/s
velCov = stateCov([2 4],[2 4]);
[v, d] = eig(velCov);
D = diag(d);
D(2) = 1;
stateCov([2 4],[2 4]) = v*diag(D)*v';

% Process noise in a slowly changing environment
Q = 0.25*eye(2);

filter = trackingEKF(State = state,...
    StateCovariance = stateCov,...
    StateTransitionFcn = @constvel,...
    StateTransitionJacobianFcn = @constveljac,...
    HasAdditiveProcessNoise = false,...
    MeasurementFcn = @cvmeas,...
    MeasurementJacobianFcn = @cvmeasjac,...
    ProcessNoise = Q,...
    MeasurementNoise = detection.MeasurementNoise);

end