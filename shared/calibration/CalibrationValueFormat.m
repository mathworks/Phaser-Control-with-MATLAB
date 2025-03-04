classdef CalibrationValueFormat
    
    % Store the antenna calibration values

    % Copyright 2023 The MathWorks, Inc.
    
    properties
        AnalogWeights = ones(4,2);
        DigitalWeights = ones(2,1);
    end
    
    methods
        function s = toStruct(this)
            s.AnalogWeights = this.AnalogWeights;
            s.DigitalWeights = this.DigitalWeights;
        end
    end
end