function tsweep = getFMCWSweepTime(tdesired,tmax)
% This function takes tdesired (s) and tmax(s) and outputs tsweep (s) which
% contains a sweep time that is acceptable for the PLL. PLL sweep times
% must be in whole 2^p us. We try to round up, if this exceeds tmax we
% round down.

tdesiredus = tdesired*1e6;
tmaxus = tmax*1e6;
desiredpower2 = nextpow2(tdesiredus);
tdesiredusrounded = 2^desiredpower2;

if tdesiredusrounded > tmaxus
    tdesiredusrounded = 2^(desiredpower2-1);
end

tsweep = tdesiredusrounded / 1e6;

end