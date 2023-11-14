function [bf_TDD] = setupTddEngine()
% Setup the TDD Engine. By default no trigger is required to collect data.
%
% Copyright 2023 The MathWorks, Inc.

plutoURI = getPlutoURI();
bf_TDD = adi.PhaserTDD('uri', plutoURI);
bf_TDD();

end

