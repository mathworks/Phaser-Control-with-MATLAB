function cleanupAntenna(rx,tx,bf,bf_TDD)
% Cleanup the phaser components
%
% Copyright 2023 The MathWorks, Inc.

rx.release();
tx.release();
bf.release();
disableTddTrigger(bf_TDD);
bf_TDD.release();

end