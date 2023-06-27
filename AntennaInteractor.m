classdef AntennaInteractor < handle

    % Copyright 2023 The MathWorks, Inc.

    properties
        ArrayControl
        PlutoControl
        Model
        Fc
        SubSteer
        ArraySteer
        LastPhase
        LastGain
        AnalogWeights
        DigitalWeights
    end

    methods
        function this = AntennaInteractor(fc,calValues)
            [rx,bf,model] = setupAntenna(fc);
            this.ArrayControl = bf;
            this.PlutoControl = rx;
            this.Model = model;
            this.Fc = fc;
            this.SubSteer = phased.SteeringVector("SensorArray",this.Model.Subarray,'NumPhaseShifterBits',7);
            this.ArraySteer = phased.SteeringVector("SensorArray",this.Model);
            this.AnalogWeights = calValues.AnalogWeights;
            this.DigitalWeights = calValues.DigitalWeights;
        end

        function updateCalibration(this,calValues)
            this.updateAnalogWeights(calValues.AnalogWeights);
            this.updateDigitalWeights(calValues.DigitalWeights);
        end

        function updateAnalogWeights(this,analogWeights)
            this.AnalogWeights = analogWeights;
        end

        function updateDigitalWeights(this,digitalWeights)
            this.DigitalWeights = digitalWeights;
        end

        function [patternData,rxdata] = capturePattern(this,steerangles)
            patternData = zeros(1024,numel(steerangles));
            for ii = 1 : numel(steerangles)
                [analogweights,digitalweights] = this.getAllWeights(steerangles(ii));
                rxdata = this.steerAnalog(analogweights);
                patternData(:,ii) = rxdata * conj(digitalweights);
            end
        end

        function [sumdiffampdelta,sumdiffphasedelta,sumpatterndata,diffpatternData] = captureMonopulsePattern(this,steerangles)
            sumpatterndata = zeros(1024,numel(steerangles));
            diffpatternData = zeros(1024,numel(steerangles));
            for ii = 1 : numel(steerangles)
                % capture data
                [analogweights,digitalweights] = this.getAllWeights(steerangles(ii));
                rxdata = this.steerAnalog(analogweights);

                % sum
                sumpatterndata(:,ii) = rxdata * conj(digitalweights);

                % diff
                diffdigitalweights = digitalweights .* [1;-1];
                diffpatternData(:,ii) = rxdata * conj(diffdigitalweights);
            end

            % calulate sum and diff amplitude and phase deltas
            sumamp = mag2db(helperGetAmplitude(sumpatterndata));
            diffamp = mag2db(helperGetAmplitude(diffpatternData));
            sumdiffampdelta = sumamp-diffamp;

            sumphase = helperGetPhase(sumpatterndata);
            diffphase = helperGetPhase(diffpatternData);
            sumdiffphasedelta = sign(wrapTo180(sumphase-diffphase));
        end

        function patternData = capturePatternWithNull(this,steerangles,nullangle)
            patternData = zeros(1024,numel(steerangles));
            for ii = 1 : numel(steerangles)
                [analogweights,digitalweights] = this.getAllWeightsNull(steerangles(ii),nullangle);
                rxdata = this.steerAnalog(analogweights);
                patternData(:,ii) = rxdata * conj(digitalweights);
            end
        end

        function rxdata = steerAnalog(this,analogWeights)
            % Set analog phase shifter
            phases = this.getPhaseCodes(analogWeights);
            if ~isequal(this.LastPhase,phases)
                this.ArrayControl.RxPhase(:) = phases;
                this.LastPhase = phases;
            end
        
            % Set analog gain
            gainCode = this.getGainCodes(analogWeights);
            if ~isequal(this.LastGain,gainCode)
                this.ArrayControl.RxGain(:) = gainCode;
                this.LastGain = gainCode;
            end
        
            % receive data
            this.ArrayControl.LatchRxSettings();
            this.PlutoControl();
            rxdata = this.PlutoControl();
        end

        function phases = getPhaseCodes(this,analogWeights)
            sub1weights = analogWeights(:,1);
            sub2weights = analogWeights(:,2);
            sub1phase = this.getPhase(sub1weights);
            sub2phase = this.getPhase(sub2weights);
            phases = [sub1phase',sub2phase'];
            phases = phases - phases(1);
            phases = wrapTo360(phases);
        end

        function codes = getGainCodes(~,analogWeights)
            codes = helperGainCodes(analogWeights);
        end
    end

    methods (Access = private)
        function [analogweights,digitalweights] = getAllWeights(this,steerangle)
            defaultAnalogWeights = this.AnalogWeights;
            defaultDigitalWeights = this.DigitalWeights;

            % get analog weights
            analogweights = this.getWeights(steerangle,defaultAnalogWeights,this.SubSteer);

            % get digital weights, flip to ensure they are being applied to
            % the correct channel.
            flippedDigitalWeights = [defaultDigitalWeights(2);defaultDigitalWeights(1)];
            digitalweights = this.getWeights(steerangle,flippedDigitalWeights,this.ArraySteer);
            digitalweights = [digitalweights(2);digitalweights(1)];
        end

        function [analogweights,digitalweights] = getAllWeightsNull(this,steerangle,nullangle)
            defaultAnalogWeights = this.AnalogWeights;
            defaultDigitalWeights = this.DigitalWeights;
            
            % get analogweights
            analogweights = this.getWeightsNull(steerangle,nullangle,defaultAnalogWeights,this.SubSteer);

            % get digital weights
            flippedDigitalWeights = [defaultDigitalWeights(2);defaultDigitalWeights(1)];
            digitalweights = this.getWeightsNull(steerangle,nullangle,flippedDigitalWeights,this.ArraySteer);
            digitalweights = [digitalweights(2);digitalweights(1)];
        end

        function weights = getWeights(this,steerangle,defaultweights,sv)
            initialweights = sv(this.Fc,steerangle);
            weights = initialweights .* defaultweights;
        end

        function weights = getWeightsNull(this,steerangle,nullangle,defaultweights,sv)
            steerweight = sv(this.Fc,steerangle);
            nullweight = sv(this.Fc,nullangle);
            rn = nullweight'*steerweight/(nullweight'*nullweight);
            steernullweight = steerweight-nullweight*rn;
            weights = steernullweight .* defaultweights;
        end

        function phase = getPhase(~,weights)
            phase = rad2deg(angle(weights));
        end
    end
end