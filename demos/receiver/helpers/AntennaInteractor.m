classdef AntennaInteractor < handle

    % Copyright 2023 The MathWorks, Inc.

    properties
        ArrayControl
        PlutoControl
        NumSamples
        Model
        Fc
        SubSteer
        ArraySteer
        LastAnalogWeight
        AnalogWeights
        DigitalWeights
    end

    methods
        function this = AntennaInteractor(fc,calValues)
            [rx,bf,model] = setupAntenna(fc);
            this.ArrayControl = bf;
            this.PlutoControl = rx;
            this.NumSamples = rx.SamplesPerFrame;
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
            patternData = zeros(this.NumSamples,numel(steerangles));
            for ii = 1 : numel(steerangles)
                [analogweights,digitalweights] = this.getAllWeights(steerangles(ii));
                rxdata = this.steerAnalog(analogweights);
                patternData(:,ii) = rxdata * conj(digitalweights);
            end
        end

        function [sumdiffampdelta,sumdiffphasedelta,sumpatterndata,diffpatternData] = captureMonopulsePattern(this,steerangles)
            nangles = length(steerangles);
            sumpatterndata = zeros(this.NumSamples,nangles);
            diffpatternData = zeros(this.NumSamples,nangles);
            sumdiffampdelta = zeros(1,nangles);
            sumdiffphasedelta = zeros(1,nangles);
            for ii = 1 : numel(steerangles)
                [sumdiffampdelta(ii),sumdiffphasedelta(ii),sumpatterndata(:,ii),diffpatternData(:,ii)] = captureMonopulseSnapshot(this,steerangles(ii));
            end
        end

        function [sumdiffampdelta,sumdiffphasedelta,sumpatterndata,diffpatternData] = captureMonopulseSnapshot(this,steerangle)
            % capture data
            [analogweights,digitalweights] = this.getAllWeights(steerangle);
            rxdata = this.steerAnalog(analogweights);

            % sum
            sumpatterndata = rxdata * conj(digitalweights);

            % diff
            diffdigitalweights = digitalweights .* [1;-1];
            diffpatternData = rxdata * conj(diffdigitalweights);

            % calulate sum and diff amplitude and phase deltas
            sumamp = mag2db(helperGetAmplitude(sumpatterndata));
            diffamp = mag2db(helperGetAmplitude(diffpatternData));
            sumdiffampdelta = sumamp-diffamp;

            sumphase = helperGetPhase(sumpatterndata);
            diffphase = helperGetPhase(diffpatternData);
            sumdiffphasedelta = sign(wrapTo180(sumphase-diffphase));
        end

        function patternData = capturePatternWithNull(this,steerangles,nullangle)
            patternData = zeros(this.NumSamples,numel(steerangles));
            for ii = 1 : numel(steerangles)
                [analogweights,digitalweights] = this.getAllWeightsNull(steerangles(ii),nullangle);
                rxdata = this.steerAnalog(analogweights);
                patternData(:,ii) = rxdata * conj(digitalweights);
            end
        end

        function rxdata = steerAnalog(this,analogWeights)
            % If the analog weights have changed, change beamformer
            % settings
            if isequal(this.LastAnalogWeight,analogWeights)
                % receive data
                this.PlutoControl();
                rxdata = this.PlutoControl();
                return
            end

            % Setup beamformer weights
            setAnalogBfWeights(this.ArrayControl,analogWeights);
            this.LastAnalogWeight = analogWeights;
        
            % receive data
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

        function cleanup(obj)
            obj.PlutoControl.release();
            obj.ArrayControl.release();
        end
    end

    methods (Access = private)
        function [analogweights,digitalweights] = getAllWeights(this,steerangle)
            defaultAnalogWeights = this.AnalogWeights;
            defaultDigitalWeights = this.DigitalWeights;

            % get steering weights
            analogweights = this.SubSteer(this.Fc,steerangle);
            digitalweights = this.ArraySteer(this.Fc,steerangle);

            % Apply calibration weights
            analogweights = analogWeightsCalAdjustment(analogweights,defaultAnalogWeights);
            digitalweights = digitalWeightsCalAdjustment(digitalweights,defaultDigitalWeights);
        end

        function [analogweights,digitalweights] = getAllWeightsNull(this,steerangle,nullangle)
            defaultAnalogWeights = this.AnalogWeights;
            defaultDigitalWeights = this.DigitalWeights;
            
            % get weights
            flippedDigitalWeights = [defaultDigitalWeights(2);defaultDigitalWeights(1)];
            [analogweights,digitalweights] = this.getWeightsNull(steerangle,nullangle,defaultAnalogWeights,flippedDigitalWeights);
            digitalweights = [digitalweights(2);digitalweights(1)];
        end

        function [analogweights,digitalweights] = getWeightsNull(this,steerangle,nullangle,defaultAnalogWeights,defaultDigitalWeights)
            % get steer and null weights
            analogsteerweights = this.SubSteer(this.Fc,steerangle);
            analognullweights = this.SubSteer(this.Fc,nullangle);
            digitalsteerweights = this.ArraySteer(this.Fc,steerangle);
            digitalnullweights = this.ArraySteer(this.Fc,nullangle);

            % insert null using analog steering
            analogfinalsteerweights = this.getSubNullSteer(analogsteerweights,digitalsteerweights,analognullweights,digitalnullweights);
            analogweights = analogfinalsteerweights .* defaultAnalogWeights;

            % if the weights are 0 (steer angle == null angle), make
            % digital weights 0, otherwise use digital weights to adjust
            % the amplitude, normalize analog weights
            maxanalog = max(max(abs(analogweights)));
            if maxanalog == 0
                digitalweights = [0;0];
            else
                analogweights = analogweights / maxanalog;
                digitalweights = defaultDigitalWeights .* maxanalog;
            end
        end

        function subnullsteer = getSubNullSteer(~,substeer,digitalsteer,subnull,digitalnull)
            fullsteer = substeer .* digitalsteer.';
            fullnull = subnull .* digitalnull.';
            rn = sum(diag(fullnull'*fullsteer))/sum(diag((fullnull'*fullnull)));
            subnullsteer = fullsteer-fullnull.*rn;
        end

        function phase = getPhase(~,weights)
            phase = rad2deg(angle(weights));
        end
    end
end