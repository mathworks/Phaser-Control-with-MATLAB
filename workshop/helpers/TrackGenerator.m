classdef TrackGenerator < handle
    properties (Access = private)
        Tracker
    end

    methods
        function obj = TrackGenerator()
            % Setup Tracker
            tracker = trackerJPDA(TrackLogic="Integrated");
            tracker.FilterInitializationFcn = @initPeopleTrackingFilter;
            
            % Further, specify clutter density, birth rate, and detection probability 
            % of the radar in the tracker. In this example, you use prior knowledge to
            %  calculate these numbers. The volume of the sensor in measurement space 
            % can be calculated using the measurement limits in each dimension. You 
            % assume that on average there 8 false alarms per step and 1 new target 
            % appearing in the field of view every 100 steps.
            % Volume of measurement space
            azSpan = 60;
            rSpan = 25;
            dopplerSpan = 5;
            V = azSpan*rSpan*dopplerSpan;
            
            % Number of false alarms per step
            nFalse = 8;
            
            % Number of new targets per step
            nNew = 0.01;
            
            % Probability of detecting the object
            Pd = 0.9;
            
            tracker.ClutterDensity = nFalse/V;
            tracker.NewTargetDensity = nNew/V;
            tracker.DetectionProbability = Pd;
            
            % Lastly, you specify the track management properties of the tracker to 
            % allow the tracker to discriminate between false and true objects and to 
            % create and delete tracks when they enter and exit the field of view, respectively.
            % Confirm a track with more than 95 percent
            % probability of existence
            tracker.ConfirmationThreshold = 0.95; 
            
            % Delete a track with less than 0.0001
            % probability of existence
            tracker.DeletionThreshold = 1e-4;

            obj.Tracker = tracker;
        end

        function tracks = track(obj,dets,t)
            tracker = obj.Tracker;

            % Track centroid returns
            if isLocked(tracker) || ~isempty(dets)
                tracks = tracker(dets, t);
            else
                tracks = objectTrack.empty(0,1);
            end
        end
    end
end