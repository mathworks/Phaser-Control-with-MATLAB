classdef AnalogAmplitudeCalibrationFormat

    % Copyright 2023 The MathWorks, Inc.

    properties
        CourseSubarray1Data
        CourseSubarray2Data
        FineSubarray1Data
        FineSubarray2Data
    end
    
    methods
        function s = toStruct(this)
            s.CourseSubarray1Data = this.CourseSubarray1Data;
            s.CourseSubarray2Data = this.CourseSubarray2Data;
            s.FineSubarray1Data = this.FineSubarray1Data;
            s.FineSubarray2Data = this.FineSubarray2Data;
        end

        function [cal1,cal2] = getCourseCalValues(this)
            cal1 = this.getCourseCal1();
            cal2 = this.getCourseCal2();
        end

        function [cal1,cal2] = getFineCalValues(this)
            cal1 = this.getFineCal1();
            cal2 = this.getFineCal2();
        end
    end

    methods (Access = private)
        function cal1 = getCourseCal1(this)
            cal1 = this.getCal(this.CourseSubarray1Data);
        end

        function cal1 = getFineCal1(this)
            cal1 = this.getCal(this.FineSubarray1Data);
        end

        function cal2 = getCourseCal2(this)
            cal2 = this.getCal(this.CourseSubarray2Data);
        end

        function cal2 = getFineCal2(this)
            cal2 = this.getCal(this.FineSubarray2Data);
        end

        function cal = getCal(~,data)
            % get amplitudes
            amp = mean(max(abs(fft(data))));
            scaling = min(amp) ./ amp;
            cal = reshape(scaling,[1 4]);
        end
    end
end