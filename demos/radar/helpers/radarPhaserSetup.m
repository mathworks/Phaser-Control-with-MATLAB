function radarPhaserSetup(bf,rampbandwidth,fc,tsweep)
% Setup phaser beamformer and pll for radar
%
% Copyright 2023 The MathWorks, Inc.

BW = rampbandwidth / 4; 
nSteps = 2^9;
bf.Frequency = (fc+rx.CenterFrequency)/4;
bf.RxPowerDown(:) = 0;
bf.RxGain(:) = 127;
bf.FrequencyDeviationRange = BW;
bf.FrequencyDeviationStep = ((BW) / nSteps);
bf.FrequencyDeviationTime = tsweep*1e6;
bf.RampMode = "single_sawtooth_burst";
bf.TriggerEnable = true;
bf.EnablePLL = true;
bf.EnableTxPLL = true;
bf.EnableOut1 = false;

end

