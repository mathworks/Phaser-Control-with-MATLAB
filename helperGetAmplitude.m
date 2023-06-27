function [amp] = helperGetAmplitude(signal)
    % Copyright 2023 The MathWorks, Inc.
    amp = max(abs(fft(signal)));
end