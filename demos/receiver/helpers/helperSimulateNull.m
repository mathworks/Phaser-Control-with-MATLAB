function pattern = helperSimulateNull(fc_hb100,steerangles,nullangle)
    % Simulate the pattern with a null at the specified angle

    % Copyright 2023 The MathWorks, Inc.
    
    analogweights = ones(4,2);
    digitalweights = ones(2,1);
    rxpos = [0;0;0];
    txpos = [0;10;0];
    [pattern,~] = helperSimulateAntennaSteering(fc_hb100,rxpos,txpos,steerangles,analogweights,digitalweights,nullangle);
end