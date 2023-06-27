classdef AnalogPhaseCalibrationFormat

    % Copyright 2023 The MathWorks, Inc.
    
    properties
        PhaseSetting
        Subarray1Measurements
        Subarray2Measurements
    end
    
    methods
        function s = toStruct(this)
            s.PhaseSetting = this.PhaseSetting;
            s.Subarray1Measurements = this.Subarray1Measurements;
            s.Subarray2Measurements = this.Subarray2Measurements;
        end

        function [cal1,cal2] = getCalValues(this)
            cal1 = this.sub1Cal();
            cal2 = this.sub2Cal();
        end
    end

    methods (Access = private)
        function cal1 = sub1Cal(this)
            cal1 = this.subCal(this.Subarray1Measurements);
        end

        function cal2 = sub2Cal(this)
            cal2 = this.subCal(this.Subarray2Measurements);
        end

        function cal = subCal(this,data)
            % Get signal amplitude
            datafft = abs(fft(data));
            amp = max(datafft,[],1);

            % Get location of min amplitude
            [~,phaseIdx] = min(amp,[],2);
            
            % Get calibration phase
            calPhase = wrapTo360(this.PhaseSetting(phaseIdx)-180);
            cal = [0;calPhase.'];
        end
    end
end

