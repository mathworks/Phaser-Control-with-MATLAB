function simpattern = helperSimulateDisabledElement(fc,steerangles,iEl)
    % Simulate what happens when we disable an element on each of the antenna
    % subarrays.

    % Copyright 2023 The MathWorks, Inc.
    
    disabletaper = ones(4,2);
    disabletaper(iEl,:) = 0;
    rxpos = [0;0;0];
    txpos = [0;10;0];
    simpattern = helperSimulateAntennaSteering(fc,rxpos,txpos,steerangles,disabletaper);
end