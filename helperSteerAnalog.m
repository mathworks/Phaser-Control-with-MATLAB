function rxdata = helperSteerAnalog(bf,rx,analogWeights)
    
    % Copyright 2023 The MathWorks, Inc.

    sub1weights = analogWeights(:,1);
    sub2weights = analogWeights(:,2);

    % Set analog phase shifter
    sub1phase = getPhase(sub1weights);
    sub2phase = getPhase(sub2weights);
    phases = [sub1phase',sub2phase'];
    if ~isequal(bf.RxPhase,phases)
        bf.RxPhase(:) = phases;
    end

    % Set analog gain
    gainCode = helperGainCodes(analogWeights);
    if ~isequal(bf.RxGain,gainCode)
        bf.RxGain(:) = gainCode;
    end

    % receive data
    bf.LatchRxSettings();
    rx();
    rxdata = rx();
end

function phase = getPhase(weights)
    phase = wrapTo360(rad2deg(angle(weights)));
end