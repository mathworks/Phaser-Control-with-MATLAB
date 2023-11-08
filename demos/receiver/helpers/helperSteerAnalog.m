function rxdata = helperSteerAnalog(bf,rx,analogWeights)
% Set analog beamforming weights and capture receive data.
%
% Copyright 2023 The MathWorks, Inc.

setAnalogBfWeights(bf,analogWeights);
rx();
rxdata = rx();

end