function calibGainCode = helperGainCodes(analogWeights)
    % Get gain code for each subarray

    % Copyright 2023 The MathWorks, Inc.

    sub1weights = analogWeights(:,1);
    sub2weights = analogWeights(:,2);
    sub1gain = getGain(sub1weights);
    sub2gain = getGain(sub2weights);

    % Loading the measured gain profiles. These are captured using the
    % script saveGainProfile.m.
    load('GainProfile.mat','subArray1_NormalizedGainProfile','subArray2_NormalizedGainProfile','gaincode'); 
    
    calibGainCode = zeros(1,8);
    for nch = 1 : 4
    
        xp = sub1gain(nch);
        if xp == -Inf
            calibGainCode(nch) = 0;
        else
            calibGainCode(nch) = round(interp1(subArray1_NormalizedGainProfile(:,nch),gaincode,xp));
        end
    
        xp = sub2gain(nch);
        if xp == -Inf
            calibGainCode(nch+4) = 0;
        else
            calibGainCode(nch+4) = round(interp1(subArray2_NormalizedGainProfile(:,nch),gaincode,xp));
        end
    end
    % Make sure the values of the gain code is always <= 127
    calibGainCode(calibGainCode>127 | isnan(calibGainCode)) = 127;

    function gain = getGain(weights)
        amp = abs(weights);
        gain = mag2db(amp);
    end
end

