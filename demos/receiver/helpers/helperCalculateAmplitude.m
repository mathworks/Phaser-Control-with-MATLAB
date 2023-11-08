function amplitude = helperCalculateAmplitude(data,maxvalue)
    % Get the signal amplitude

    % Copyright 2023 The MathWorks, Inc.

    % Scale data
    datascaled = data / maxvalue;
    [nsamples,~] = size(data);

    % Convert the signal to the frequency domain
    fexampledata = mag2db(abs(fft(datascaled)) / nsamples);

    % Amplitude is the largest frequency value
    amplitude = max(fexampledata);
end
