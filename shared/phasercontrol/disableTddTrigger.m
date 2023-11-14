function disableTddTrigger(bf_TDD)
% Run this to disable TDD trigger enabled mode, this will allow us to
% capture data in receive only mode.
%
% Copyright 2023 The MathWorks, Inc.
arguments
    bf_TDD = setupTddEngine()
end

phaserEnable = 0;
bf_TDD.PhaserEnable = phaserEnable;
bf_TDD.Enable = 0;
bf_TDD.Ch1Polarity = double(~phaserEnable);
bf_TDD.Ch2Polarity = double(phaserEnable);
bf_TDD.Enable = 1;
bf_TDD.Enable = 0;

end

