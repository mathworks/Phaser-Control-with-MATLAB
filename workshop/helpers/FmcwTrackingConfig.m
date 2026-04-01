classdef FmcwTrackingConfig
    % Store configuration for FMCW Tracking Lab

    properties
        PRF
        NumPulses
        Fc
        Fs
        SweepTime
        RampBandwidth
        SteerAngles
        SweepStartTime
        FrameTime
    end

    methods
        function obj = FmcwTrackingConfig(prf,npulses,fc,fs,sweeptime,rampbandwidth,steerangles,sweepstarttime,frametime)
            obj.PRF = prf;
            obj.NumPulses = npulses;
            obj.Fc = fc;
            obj.Fs = fs;
            obj.SweepTime = sweeptime;
            obj.RampBandwidth = rampbandwidth;
            obj.SteerAngles = steerangles;
            obj.SweepStartTime = sweepstarttime;
            obj.FrameTime = frametime;
        end
    end
end