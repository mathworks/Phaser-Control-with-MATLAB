classdef CalibrationWeightFormat
    
    % Hold calibration weights at each step of the calibration process.

    % Copyright 2023 The MathWorks, Inc.
    
    properties
        UncalibratedWeights = CalibrationValueFormat()
        AnalogCourseAmplitudeWeights = CalibrationValueFormat()
        AnalogPhaseWeights = CalibrationValueFormat()
        AnalogFineAmplitudeWeights = CalibrationValueFormat()
        DigitalAmplitudeWeights = CalibrationValueFormat()
        FinalCalibrationWeights = CalibrationValueFormat()
    end
    
    methods
        function s = toStruct(this)
            s.UncalibratedWeights = this.UncalibratedWeights.toStruct();
            s.AnalogCourseAmplitudeWeights = this.AnalogCourseAmplitudeWeights.toStruct();
            s.AnalogPhaseWeights = this.AnalogPhaseWeights.toStruct();
            s.AnalogFineAmplitudeWeights = this.AnalogFineAmplitudeWeights.toStruct();
            s.DigitalAmplitudeWeights = this.DigitalAmplitudeWeights.toStruct();
            s.FinalCalibrationWeights = this.FinalCalibrationWeights.toStruct();
        end
    end
end

