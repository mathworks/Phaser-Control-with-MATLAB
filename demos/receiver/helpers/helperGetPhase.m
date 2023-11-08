function phase = helperGetPhase(signal)
    % Get the phase of the signal

    % Copyright 2023 The MathWorks, Inc.

    fsig = fft(signal);
    [~,ampidx] = max(fsig);
    phase = zeros(1,numel(ampidx));
    for i = 1:numel(ampidx)
        phase(i) = rad2deg(angle(fsig(ampidx(i),i)));
    end
end