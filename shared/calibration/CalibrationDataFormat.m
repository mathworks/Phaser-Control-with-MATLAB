classdef CalibrationDataFormat
    
    % Store calibration data

    % Copyright 2023 The MathWorks, Inc.
    
    properties
        ExampleData
        CalibrationWeights = CalibrationWeightFormat();
        AntennaPattern = ArrayFactorDataFormat();
        AnalogPhaseCalibration = AnalogPhaseCalibrationFormat();
        AnalogAmplitudeCalibration = AnalogAmplitudeCalibrationFormat();
        DigitalCalibration = DigitalCalibrationFormat();
    end

    methods
        function s = toStruct(this)
            s.ExampleData = this.ExampleData;
            s.CalibrationValues = this.CalibrationWeights.toStruct();
            s.AntennaPattern = this.AntennaPattern.toStruct();
            s.AnalogPhaseCalibration = this.AnalogPhaseCalibration.toStruct();
            s.AnalogAmplitudeCalibration = this.AnalogAmplitudeCalibration.toStruct();
            s.DigitalCalibration = this.DigitalCalibration.toStruct();
        end
    end
end

