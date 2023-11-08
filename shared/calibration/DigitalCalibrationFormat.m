classdef DigitalCalibrationFormat

    % Copyright 2023 The MathWorks, Inc.
    
    properties
        MeasuredData
    end

    methods        
        function s = toStruct(this)
            s.AmplitudeCalData = this.MeasuredData;
        end

        function gain = channelGain(this)
            fReceive = max(abs(fft(this.MeasuredData)));
            gain = max(fReceive) ./ fReceive;
        end

        function channelWeights = getChannelPhaseOffset(this)
            phase = deg2rad(0:360);
            st_vec = [ones(size(phase)); exp(1i*phase)];
            sig = this.MeasuredData*conj(st_vec);
            sigfft = fft(sig);
            af = max(abs(sigfft));
            [~, ind_phase] = max(af);
            channelWeights = st_vec(:,ind_phase);
        end
    end
end

