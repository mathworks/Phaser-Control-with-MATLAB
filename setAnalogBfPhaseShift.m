function setAnalogBfPhaseShift(bf,analogWeights)
    phases = getPhaseCodes(analogWeights);
    bf.RxPhase(:) = phases;
end

function phases = getPhaseCodes(analogWeights)
    sub1weights = analogWeights(:,1);
    sub2weights = analogWeights(:,2);
    sub1phase = getPhase(sub1weights);
    sub2phase = getPhase(sub2weights);
    phases = [sub1phase',sub2phase'];
    phases = phases - phases(1);
    phases = wrapTo360(phases);
end

function phase = getPhase(weights)
    phase = rad2deg(angle(weights));
end