classdef MonopulsePattern
    
    % Holds collected monopulse data, calculates OBA

    % Copyright 2023 The MathWorks, Inc.
    
    properties
        SumDiffAmpDelta
        SumDiffPhaseDelta
        OBA
    end
    
    methods
        function this = MonopulsePattern(sumDiffAmpDelta,sumDiffPhaseDelta,Oba)
            this.SumDiffAmpDelta = sumDiffAmpDelta;
            this.SumDiffPhaseDelta = sumDiffPhaseDelta;
            this.OBA = Oba;
        end
        
        function oba = calculateOba(this,sumDiffAmpDelta,sumDiffPhaseDelta)
            phaseloc = this.SumDiffPhaseDelta == sumDiffPhaseDelta;
            amps = this.SumDiffAmpDelta(phaseloc);
            obas = this.OBA(phaseloc);
            oba = interp1(amps,obas,sumDiffAmpDelta);
        end
    end
end

