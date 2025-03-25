function radarTddSetup(bf_TDD,tpulse,nPulses)
% Setup the TDD Engine for Radar
%
% Copyright 2023 The MathWorks, Inc.

tStartCollection = 0;
bf_TDD.PhaserEnable = 1;
bf_TDD.Enable = 0;
bf_TDD.EnSyncExternal = 1;
bf_TDD.StartupDelay = 0;
bf_TDD.SyncReset = 0;
bf_TDD.FrameLength = tpulse*1e3;
bf_TDD.BurstCount = nPulses;
bf_TDD.Ch0Enable = 1;
bf_TDD.Ch0Polarity = 0;
bf_TDD.Ch0On = 0;
bf_TDD.Ch0Off = 0.1;
bf_TDD.Ch1Enable = 1;
bf_TDD.Ch1Polarity = 0;
bf_TDD.Ch1On = tStartCollection;
bf_TDD.Ch1Off = tStartCollection+0.1;
bf_TDD.Ch2Enable = 1;
bf_TDD.Ch2Polarity = 0;
bf_TDD.Ch2On = 0;
bf_TDD.Ch2Off = bf_TDD.FrameLength*nPulses;
bf_TDD.Enable = 1;

end

