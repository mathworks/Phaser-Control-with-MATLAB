function bf = setupPhaser(rx,phaserURI,fc_hb100)

% Copyright 2023 The MathWorks, Inc.

% Configure phaser
bf = adi.Phaser;
bf.uri = phaserURI;
bf.SkipInit = true; % Bypass writing all initial attributes to speed things up
bf();
bf.ElementSpacing = 0.014;
% Put device in Rx mode
bf.TxRxSwitchControl = {'spi','spi'};
bf.Mode(:) = {'Disabled'};
bf.BeamMemEnable(:) = false;
bf.BiasMemEnable(:) = false;
bf.PolState(:) = false;
bf.PolSwitchEnable(:) = false;
bf.TRSwitchEnable(:) = true;
bf.ExternalTRPolarity(:) = true;

bf.RxVGAEnable(:) = true;
bf.RxVMEnable(:) = true; %?
bf.RxLNABiasCurrent(:) = 8;
bf.RxVGABiasCurrentVM(:) = 22;

% Self bias LNAs
bf.LNABiasOutEnable(:) = false;

% Fire them up
bf.RxPowerDown(:) = false;
bf.Mode(:) = {'Rx'};

% Set up PLL
bf.Frequency = (fc_hb100 + rx.CenterFrequency) / 4;
BW = 500e6 / 4; num_steps = 1000;
bf.FrequencyDeviationRange = BW; % frequency deviation range in H1.  This is the total freq deviation of the complete freq ramp
bf.FrequencyDeviationStep = int16(BW / num_steps);  % frequency deviation step in Hz.  This is fDEV, in Hz.  Can be positive or negative
bf.RampMode = "disabled";
bf.DelayStartWord = 4095;
bf.DelayClockSource = "PFD";
bf.DelayStartEnable = false;  % delay start
bf.RampDelayEnable = false;  % delay between ramps.
bf.TriggerDelayEnable = false;  % triangle delay
bf.SingleFullTriangleEnable = false;  % full triangle enable/disable -- this is used with the single_ramp_burst mode
bf.TriggerEnable = false;  % start a ramp with TXdata

% Flatten phaser phase/gain
bf.RxGain(:) = 127;
bf.RxAttn(:) = 0;
bf.RxPhase(:) = 0;
bf.RxLNAEnable(:) = true;
bf.LatchRxSettings();
end
