function [cut,speed,range] = getCFARCUT(minRange,maxRange,vmin,vmax,guard,train,prf,nPulses,fc,fs,tSweep,rampbandwidth)
    % Exclude cells to close to the border
    nexclude = guard+train;

    % Get speed region for testing
    df = prf/nPulses;
    fdop = -prf/2:df:prf/2-df;
    speed = dop2speed(fdop,freq2wavelen(fc))/2;
    keepSpeed = abs(speed) >= vmin & abs(speed) <= vmax;
    keepSpeed(1:nexclude) = false;
    keepSpeed(end-nexclude+1:end) = false;
    speedidxs = find(keepSpeed);

    % Get range region for testing - assume that we will not run into the
    % border at higher ranges
    nSamples = ceil(tSweep * fs);
    dr = physconst('LightSpeed')*(fs/nSamples)*tSweep/(rampbandwidth*2);
    maxAvailRange = nSamples*dr;
    range = -maxAvailRange/2:dr:maxAvailRange/2-dr;
    keepRange = range >= minRange & range <= maxRange;
    keepRange(1:nexclude) = false;
    keepRange(end-nexclude+1:end) = false;
    rangeidxs = find(keepRange);

    % Generate cells under test
    nspeed = length(speedidxs);
    nrange = length(rangeidxs);
    cut = zeros(2,nspeed*nrange);
    cidx = 1;
    for iRange = 1:nrange
        for iSpeed = 1:nspeed
            cut(1,cidx) = rangeidxs(iRange);
            cut(2,cidx) = speedidxs(iSpeed);
            cidx = cidx + 1;
        end
    end
end
